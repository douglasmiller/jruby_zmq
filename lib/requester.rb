require 'ov_service/zmq/foreman'

class Requester
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    options = {
      :uri => 'tcp://127.0.0.1:5559',
      :type => ZMQ::REQ,
      :count => 5
    }
    start_foreman(options) do |socket|
      run_loop(socket)
    end
  end

  def run_loop(socket)
    loop do
      rc = socket.send_string("Request from: #{Thread.current}")
      break if error_check(rc)

      rc = socket.recv_string(response = '')
      break if error_check(rc)
      log("Received '#{response}'")
      sleep(rand(10))
    end
  end

end

