require 'ov_service/zmq/base'

module OvService
  module Zmq
    module Foreman
      include OvService::Zmq::Base

      def stop_foreman
        log('Stopping the foreman')
        @foreman[:running] = false
      end

      # This is a blocking method
      def start_foreman(options)
        @workers = []
        @foreman = Thread.new do
          Thread.current[:running] = true

          while Thread.current[:running] do 
            living_workers = @workers.select(&:alive?).size
            log("I have #{living_workers} / #{options[:count]} workers")
            kick_workers(options) do |*args|
              yield(*args)
            end
            sleep(5)
          end

          log('Stopping workers')
          stop_workers
          zmq_context.terminate
        end
        @foreman.join
      end

      def kick_workers(options)
        options[:count].times do |i|
          next if @workers[i] && @workers[i].alive?

          log("Starting worker #{i}")
          @workers[i] = start_worker(options) do |*args|
            yield(*args)
          end
        end
      end

      def stop_workers
        @workers.each do |thread|
          thread[:socket].setsockopt(ZMQ::LINGER, 0)
          thread[:socket].close
        end
      end

      def start_worker(options)
        options = { :sockopts => [] }.merge(options)
        Thread.new do
          Thread.current[:socket] = zmq_context.socket(options[:type])
          options[:sockopts].each do |sockopt|
            Thread.current[:socket].setsockopt(sockopt[:option], sockopt[:value])
          end
          if options[:bind]
            log("Binding to #{options[:uri]}")
            Thread.current[:socket].bind(options[:uri])
          else
            log("Connecting to #{options[:uri]}")
            Thread.current[:socket].connect(options[:uri])
          end

          yield(Thread.current[:socket])

          log('Death comes to us all; we can only choose how to face it when it comes.')
          Thread.current[:socket].close
        end
      end

    end
  end
end

