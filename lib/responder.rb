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
    start_proxy('tcp://127.0.0.1:5559', 'tcp://127.0.0.1:5560', 'tcp://127.0.0.1:5556')
    options = {
      :uri => 'tcp://127.0.0.1:5560',
      :type => ZMQ::REP,
      :count => 5
    }
    start_foreman(options) do |socket|
      run_loop(socket)
    end
  end

  def run_loop(socket)
    loop do
      rc = socket.recv_string(message = '')
      break if error_check(rc)
      log("Incoming '#{message}'")

      rc = socket.send_string("Response from: #{Thread.current}")
      break if error_check(rc)
    end
  end

end
