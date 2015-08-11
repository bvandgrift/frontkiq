class Frontkiq::QueuedJobsController < Frontkiq::FrontkiqController
  def index
    render locals: { queues: Sidekiq::Queue.all }
  end

  def show
    render status: 404 unless queue
    halt 404 unless params[:name]
    @count = (params[:count] || 25).to_i
    @name = params[:name]
    @queue = Sidekiq::Queue.new(@name)
    (@current_page, @total_size, @messages) = page("queue:#{@name}", params[:page], @count)
    @messages = @messages.map { |msg| Sidekiq::Job.new(msg, @name) }

  end

  private

  def job_params
    params.require(:key_val)
  end

  def queue_params
    params.require(:id)
  end

  def find_queue(name)
    Sidekiq::Queue.new(name)
  end
end
