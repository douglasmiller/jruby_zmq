require 'ov_service/zmq/foreman'
require 'ov_service/zmq/proxy'

class Publisher
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    puts 'Starting publisher'
    options = {
      :uri => 'tcp://127.0.0.1:5555',
      :type => ZMQ::PUB,
      :count => 1,
      :bind => true
    }
    start_foreman(options) do |socket|
      run_loop(socket)
    end
  end

  def run_loop(socket)
    loop do
      log('Sending heartbeat')
      strings = [
        'Heartbeat',
        "Heartbeat from: #{Thread.current}"
      ]
      rc = socket.send_strings(strings, ZMQ::SNDMORE)
      break if error_check(rc)

      sleep(2)
    end
  end

end

