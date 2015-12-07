require 'ffi-rzmq'

module OvService
  module Zmq
    module Base

      def log(message, type = :info)
        puts "#{type.to_s}: #{message}"
      end

      def zmq_context
        @context ||= ZMQ::Context.new
      end


      def error_check(rc)
        if ZMQ::Util.resultcode_ok?(rc)
          false
        else
          log("Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]", :error)
          caller(1).each { |callstack| log(callstack, :error) }
          true
        end
      end

    end
  end
end

