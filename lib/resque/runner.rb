module Resque
  class Runner < Worker
    def work(interval = 5, &block)
      $0 = "resque: Starting - #{Process.pid}"
      startup

      if not @paused and job = reserve
        log "got: #{job.inspect}"
        run_hook :before_fork
        working_on job

        procline "Processing #{job.queue} since #{Time.now.to_i} - #{Process.pid}"
        perform(job, &block)
        exit! unless @cant_fork

        done_working
        @child = nil
      else
        break if interval.to_i == 0
        log! "Sleeping for #{interval.to_i} - #{Process.pid}"
        procline @paused ? "Paused" : "Waiting for #{@queues.join(',')}"
        sleep interval.to_i
      end

    ensure
      unregister_worker
    end
    
    def empty?
      queues.any?{|queue| Resque.size(queue).zero? }
    end
  end
end