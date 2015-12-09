require 'ov_service/zmq/foreman'
require 'ov_service/zmq/proxy'

class Responder
  include OvService::Zmq::Foreman
  include OvService::Zmq::Proxy

  def stop
    stop_foreman
    stop_proxy
  end

  def start
    start_proxy('tcp://127.0.0.1:5559', 'inproc://workers')
    options = {
      :sockets => {
        :rep => {
          :uri => 'inproc://workers',
          :type => ZMQ::REP
        }
      },
      :workers => 5
    }
    start_foreman(options) do |sockets|
      run_loop(sockets)
    end
  end

  def run_loop(sockets)
    loop do
      rc = sockets[:rep].recv_string(message = '')
      break if error_check(rc)
      log("Incoming '#{message}'")

      sleep(10)

      rc = sockets[:rep].send_string("Response from: #{Thread.current}")
      break if error_check(rc)
    end
  end

end
