module Raemon
  class Runner < Master
    def self.queues=(queues)
      @queues ||= queues.to_s.split(',')
    end
    
    def self.queues; @queues end
    
    def maintain_worker_count
      # check if any jobs are available
      logger.info "** Checking if any jobs are available on #{self.class.queues.inspect}"
      worker = Resque::Runner.new(self.class.queues)
      if worker.empty?
        logger.info "** No Jobs available, sleeping for #{Choice.choices[:interval]}"
        sleep Choice.choices[:interval]
      else
        logger.info "** Job found, starting worker"
        super
      end
    end
  end
end