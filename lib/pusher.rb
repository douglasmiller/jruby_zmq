require 'ov_service/zmq/foreman'

class Pusher
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    options = {
      :uri => 'tcp://127.0.0.1:5556',
      :type => ZMQ::PUSH,
      :count => 1,
      :bind => true
    }
    start_foreman(options) do |socket|
      run_loop(socket)
    end
  end

  def run_loop(socket)
    loop do
      log('Sending pulse')
      rc = socket.send_string('Pulse')
      break if error_check(rc)
      sleep(rand(5))
    end
  end
end

