require 'ov_service/zmq/base'

module OvService
  module Zmq
    module Proxy
      include OvService::Zmq::Base

      def stop_proxy
        log('Stopping the proxy')
        @proxy[:router].setsockopt(ZMQ::LINGER, 0)
        @proxy[:router].close
        @proxy[:dealer].setsockopt(ZMQ::LINGER, 0)
        @proxy[:dealer].close
        if @proxy[:pub]
          @proxy[:pub].setsockopt(ZMQ::LINGER, 0)
          @proxy[:pub].close
        end
      end

      def start_proxy(router_uri, dealer_uri, pub_uri = nil)
        log("Starting the proxy")
        @proxy = Thread.new do
          Thread.current[:router] = zmq_context.socket(ZMQ::ROUTER)
          Thread.current[:router].bind(router_uri)

          Thread.current[:dealer] = zmq_context.socket(ZMQ::DEALER)
          Thread.current[:dealer].bind(dealer_uri)

          if pub_uri
            Thread.current[:pub] = zmq_context.socket(ZMQ::PUSH)
            Thread.current[:pub].bind(pub_uri)
          end

          poller = ZMQ::Proxy.new(Thread.current[:router], Thread.current[:dealer], Thread.current[:pub])
        end
      end

    end
  end
end

