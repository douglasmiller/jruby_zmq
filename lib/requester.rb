require 'ov_service/zmq/foreman'

class Requester
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    options = {
      :sockets => {
        :req => {
          :uri => 'tcp://127.0.0.1:5559',
          :type => ZMQ::REQ
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
      rc = sockets[:req].send_string("Request from: #{Thread.current}")
      break if error_check(rc)

      rc = sockets[:req].recv_string(response = '')
      break if error_check(rc)
      log("Received '#{response}'")
      sleep(rand(10))
    end
  end

end

