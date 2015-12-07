require 'ov_service/zmq/foreman'

class Puller
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    options = {
      :sockets => {
        :pull => {
          :uri => 'tcp://127.0.0.1:5556',
          :type => ZMQ::PULL
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
      rc = sockets[:pull].recv_strings(responses = [])
      break if error_check(rc)
      log("Received '#{responses}'")
    end
  end
end

