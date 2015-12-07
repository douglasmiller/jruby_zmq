require 'ov_service/zmq/foreman'

class Subscriber
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    options = {
      :sockets => {
        :sub => {
          :uri => 'tcp://127.0.0.1:5555',
          :type => ZMQ::SUB,
          :sockopts => [
            :option => ZMQ::SUBSCRIBE,
            :value => 'Heartbeat'
          ]
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
      rc = sockets[:sub].recv_strings(messages = [])
      break if error_check(rc)

      log("#{Thread.current}: Incoming #{messages[1]}")
    end
  end

end

