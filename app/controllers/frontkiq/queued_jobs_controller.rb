class Frontkiq::QueuedJobsController < Frontkiq::FrontkiqController
  include Sidekiq::Paginator

  def index
    render locals: { queues: Sidekiq::Queue.all }
  end

  def show
    name = queue_params[:id]
    count = (queue_params[:count] || 25).to_i
    queue = Sidekiq::Queue.new(name)
    render status: 404 unless queue
    (current_page, total_size, messages) = page("queue:#{name}", params[:page], count)
    messages = messages.map { |msg| Sidekiq::Job.new(msg, name) }
    render locals: { current_page: current_page,
                     total_size:   total_size,
                     messages:     messages,
                     name:         name,
                     queue:        queue,
                     count:        count }
  end

  def delete_queue
    Sidekiq::Queue.new(params[:name]).clear
    redirect_to frontkiq_queued_jobs_url 
  end

  def delete_job
    Sidekiq::Job.new(params[:key_val], params[:name]).delete
    redirect_to frontkiq_queued_jobs_url 
  end

  private

  def job_params
    params.require(:key_val)
  end

  def queue_params
    params.permit(:id,:name,:count,:page)
  end
end
