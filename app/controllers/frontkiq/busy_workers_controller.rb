class Frontkiq::BusyWorkersController < Frontkiq::FrontkiqController 
  def index
  end

  def update
    processes = params.has_key?('identity') ?
      [Sidekiq::Process.new('identity' => params['identity'])] :
      Sidekiq::ProcessSet.new

    processes.each { |p| update_process(p, params) }

    redirect_to action: :index
  end

  private

  def update_process(p, h)
    p.quiet! if h[:quiet]
    p.stop! if h[:stop]
  end
end
