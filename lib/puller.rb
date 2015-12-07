require 'ov_service/zmq/foreman'

class Puller
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    options = {
      :uri => 'tcp://127.0.0.1:5556',
      :type => ZMQ::PULL,
      :count => 1
    }
    start_foreman(options) do |socket|
      run_loop(socket)
    end
  end

  def run_loop(socket)
    loop do
      rc = socket.recv_strings(responses = [])
      break if error_check(rc)
      log("Received '#{responses}'")
    end
  end
end

