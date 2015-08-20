class Frontkiq::PendingRetriesController < Frontkiq::FrontkiqController
  include Sidekiq::Pagination

  def index
    count = (params[:count] || 25).to_i
    (current_page, total_size, messages) = page("retry", params[:page], count)
    retries = messages.map { |msg, score| Sidekiq::SortedEntry.new(nil, score, msg) }

    render locals: { current_page: current_page,
                     total_size:   total_size,
                     retries:      retries,
                     count:        count }
  end

  def show
  end

  def kill
    jid = job_params['jid']
    score = job_params['score']

    job = Sidekiq::RetrySet.new.fetch(score, jid).first
    puts job.inspect
    if job.nil? 
      flash[:error] = "job not found"
    else
      job.kill
    end

    redirect_to action: :index
  end

  def delete
    redirect_to action: :index
  end

  def delete_all
    redirect_to action: :index
  end

  def retry
    redirect_to action: :index
  end

  def retry_all
    redirect_to action: :index
  end

  private

  def job_params
    @jparams ||= params.permit(:jid, :score)
  end
end
