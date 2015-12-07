require 'ov_service/zmq/foreman'
require 'ov_service/zmq/proxy'

class Publisher
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    options = {
      :sockets => {
        :pub => {
          :uri => 'tcp://127.0.0.1:5555',
          :type => ZMQ::PUB,
          :bind => true
        }
      },
      :workers => 1
    }
    start_foreman(options) do |sockets|
      run_loop(sockets)
    end
  end

  def run_loop(sockets)
    loop do
      log('Sending heartbeat')
      strings = [
        'Heartbeat',
        "Heartbeat from: #{Thread.current}"
      ]
      rc = sockets[:pub].send_strings(strings)
      break if error_check(rc)

      sleep(2)
    end
  end

end

