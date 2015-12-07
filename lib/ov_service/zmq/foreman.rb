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
            log("I have #{living_workers} / #{options[:workers]} workers")
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
        options[:workers].times do |i|
          next if @workers[i] && @workers[i].alive?

          log("Starting worker #{i}")
          @workers[i] = start_worker(options) do |*args|
            yield(*args)
          end
        end
      end

      def stop_workers
        @workers.each do |thread|
          thread[:sockets].each do |key, socket|
            socket.setsockopt(ZMQ::LINGER, 0)
            socket.close
          end
        end
      end

      def start_worker(options)
        Thread.new do
          sockets = {}

          options[:sockets].each do |key, socket_options|
            socket_options = { :sockopts => [] }.merge(socket_options)

            socket = zmq_context.socket(socket_options[:type])
            socket_options[:sockopts].each do |sockopt|
              socket.setsockopt(sockopt[:option], sockopt[:value])
            end
            if socket_options[:bind]
              socket.bind(socket_options[:uri])
            else
              socket.connect(socket_options[:uri])
            end

            sockets[key] = socket
          end
          Thread.current[:sockets] = sockets

          yield(sockets)

          log('Death comes to us all; we can only choose how to face it when it comes.')
          Thread.current[:sockets].each(&:close)
        end
      end

    end
  end
end

