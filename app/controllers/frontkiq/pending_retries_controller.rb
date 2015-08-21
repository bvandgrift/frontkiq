class Frontkiq::PendingRetriesController < Frontkiq::FrontkiqController
  include Sidekiq::Paginator

  def index
    count = (params[:count] || 25).to_i
    (current_page, total_size, messages) = page("retry", params[:page], count)
    retries = messages.map { |msg, score| Sidekiq::SortedEntry.new(nil, score, msg) }

    render locals: { current_page: current_page,
                     total_size:   total_size,
                     retries:      retries,
                     count:        count }
  end

  def show_job
    @retry = Sidekiq::RetrySet.new.fetch(*job_key).first
    if @retry.present?
      render :show
    else
      flash[:alert] = "job not found"
      redirect_to action: :index
    end
  end

  def job_flash(job, section, task)
    flash[section] = "job [#{job.to_s}] #{task}"
  end

  def kill_job
    job = fetch_job(job_params['score'], job_params['jid'])
    send_job(job, :kill, 'killed')

    redirect_to action: :index
  end

  def delete_job
    job = fetch_job(job_params['score'], job_params['jid'])
    send_job(job, :delete, 'deleted')

    redirect_to action: :index
  end

  def delete_all
    Sidekiq::RetrySet.new.clear

    redirect_to action: :index
  end

  def send_job(job, m, msg)
    if job.present?  
      job.send(m)
      job_flash(job, :notice, msg)
    else
      job_flash(job_params, :alert, 'not found')
    end
  end

  def retry_job
    job = fetch_job(job_params['score'], job_params['jid'])
    send_job(job, :retry, 'retried')

    redirect_to action: :index
  end

  def retry_all
    Sidekiq::RetrySet.new.retry_all

    redirect_to action: :index
  end

  def update_selected
    keys = job_update_params[:keys]
    task = job_update_params[:do]

    if %w(kill delete retry).include? task
      jobs = keys.map { |key| fetch_job(parse_key(key)) }
      jobs.each(&task.to_sym)
    else
      flash[:alert] = 'selected update failed: no task defined'
    end

    redirect_to action: :index
  end

  private

  def fetch_job(score, jid)
    Sidekiq::RetrySet.new.fetch(score, jid).first
  end

  def job_update_params
    @jkeys ||= params.permit(:keys, :do)
  end

  def job_key
    @jkey ||= parse_key(params.permit(:key)['key'])
  end

  def job_params
    @jparams ||= params.permit(:jid, :score)
  end
end
