require 'ov_service/zmq/foreman'
require 'ov_service/zmq/proxy'

class Publisher
  include OvService::Zmq::Foreman
  include OvService::Zmq::Proxy

  def stop
    stop_foreman
    stop_proxy
  end

  def start
    puts 'Starting publisher'
    start_proxy
    options = {
      :uri => 'tcp://127.0.0.1:5555',
      :type => ZMQ::PUB,
      :count => 1
    }
    start_foreman(options) do |socket|
      run_loop(socket)
    end
  end

  def run_loop(socket)
    puts "Sending heartbeat from #{Thread.current[:name]}"

    socket.send_string('Heartbeat', ZMQ::SNDMORE)
    socket.send_string("Heartbeat from: #{Thread.current[:name]}")

    sleep(2)
  end

end

