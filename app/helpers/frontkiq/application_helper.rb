module Frontkiq::ApplicationHelper

  def sidekiq_decorator
    @sidekiq_decorator ||= Frontkiq::SidekiqDecorator.new
  end

  delegate :current_status, :stats, :workers, :processes, 
    :redis_connection, :namespace,
    to: :sidekiq_decorator

  def frontkiq_tabs
    @frontkiq_tabs ||= {
      "Dashboard" => frontkiq_root_path,
      "Busy Workers" => frontkiq_busy_workers_path,
      "Queued Jobs" => frontkiq_queued_jobs_path,
      "Pending Retries" => frontkiq_pending_retries_path,
      "Scheduled Jobs" => frontkiq_scheduled_jobs_path,
      "Abandoned Jobs" => frontkiq_abandoned_jobs_path
    }.freeze
  end

  def relative_time(time)
    %{<time datetime="#{time.getutc.iso8601}">#{time}</time>}
  end

  def truncate(text, truncate_after_chars = 2000)
    truncate_after_chars && text.size > truncate_after_chars ? "#{text[0..truncate_after_chars]}..." : text
  end

  def display_args(args, truncate_after_chars = 2000)
    args.map do |arg|
      h(truncate(to_display(arg)))
    end.join(", ")
  end

  def to_display(arg)
    begin
      arg.inspect
    rescue
      begin
        arg.to_s
      rescue => ex
        "Cannot display argument: [#{ex.class.name}] #{ex.message}"
      end
    end
  end

  def job_key(job, score)
    "#{score}-#{job['jid']}"
  end

  def display_args(args, truncate_after_chars = 1000)
    args.map do |arg|
      h(truncate(to_display(arg)))
    end.join(", ")
  end
end
