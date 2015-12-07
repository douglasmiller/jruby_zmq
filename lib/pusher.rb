require 'ov_service/zmq/foreman'

class Pusher
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    options = {
      :sockets => {
        :push => {
          :uri => 'tcp://127.0.0.1:5556',
          :type => ZMQ::PUSH,
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
      log('Sending pulse')
      rc = sockets[:push].send_string('Pulse')
      break if error_check(rc)
      sleep(rand(5))
    end
  end
end

