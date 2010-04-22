module Resque
  class Ranger
    include Raemon::Worker
  
    def start
      logger.info "=> Starting worker #{Process.pid}"
    end
  
    def stop
      logger.info "=> Stopping worker #{Process.pid}"
    
      EM.stop_event_loop if EM.reactor_running?
    end
  
    def run
      queues = Choice.choices[:queue].to_s.split(',')
      
      begin
        worker = Runner.new(*queues)
        worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
        worker.very_verbose = ENV['VVERBOSE']
      rescue Resque::NoQueueError
        abort "set QUEUE env var, e.g. $ QUEUE=critical,high rake resque:work"
      end

      puts "*** Starting worker #{worker}"

      worker.work(ENV['INTERVAL'] || 5) # interval, will block
    end
  end
end