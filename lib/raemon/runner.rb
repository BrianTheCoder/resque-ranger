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
    
    # monitors children and receives signals forever
    # (or until a termination signal is sent).  This handles signals
    # one-at-a-time time and we'll happily drop signals in case somebody
    # is signalling us too often.
    def master_loop!
      # this pipe is used to wake us up from select(2) in #join when signals
      # are trapped.  See trap_deferred
      init_self_pipe!
      @respawn = true

      QUEUE_SIGS.each { |sig| trap_deferred(sig) }
      trap(:CHLD) { |sig_nr| awaken_master }
      
      process_name 'master'
      logger.info "master process ready"
      
      # Spawn workers for the first time
      maintain_worker_count
      
      begin
        loop do
          monitor_memory_usage
          reap_all_workers

          case SIG_QUEUE.shift
          when nil
            murder_lazy_workers
            maintain_worker_count if @respawn
            master_sleep
          when :QUIT # graceful shutdown
            break
          when :TERM, :INT # immediate shutdown
            stop(false)
            break
          when :USR1
            kill_each_worker(:USR1)
          when :USR2
            kill_each_worker(:USR2)
          when :WINCH
            if Process.ppid == 1 || Process.getpgrp != $$
              @respawn = false
              logger.info "gracefully stopping all workers"
              kill_each_worker(:QUIT)
            else
              logger.info "SIGWINCH ignored because we're not daemonized"
            end
          when :TTIN
            @num_workers += 1
          when :TTOU
            @num_workers -= 1 if @num_workers > 0
          when :HUP
            # TODO: should restart the workers, but a :QUIT could stall
            # respawn = true
            # kill_each_worker(:QUIT)
          end
        end
      rescue Errno::EINTR
        retry
      rescue => ex
        logger.error "Unhandled master loop exception #{ex.inspect}."
        logger.error ex.backtrace.join("\n")
        retry
      end
      
      # Gracefully shutdown all workers on our way out
      stop
      logger.info "master complete"
      
      # Close resources
      unlink_pid_safe(pid_file) if pid_file
      logger.close
    end
  end
end