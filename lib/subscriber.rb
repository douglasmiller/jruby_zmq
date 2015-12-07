require 'ov_service/zmq/foreman'

class Subscriber
  include OvService::Zmq::Foreman

  def stop
    stop_foreman
  end

  def start
    puts 'Starting subscribers'
    options = {
      :uri => 'tcp://127.0.0.1:5555',
      :type => ZMQ::SUB,
      :count => 5,
      :sockopts => [
        :option => ZMQ::SUBSCRIBE,
        :value => 'Heartbeat'
      ]
    }
    start_foreman(options) do |socket|
      run_loop(socket)
    end
    @subscribers.each(&:join)
    stop
  end

  def run_loop(socket)
    loop do
      topic = ''
      message = ''
      rc = socket.recv_string(topic)
      break if error_check(rc)
      rc = socket.recv_string(message) if socket.more_parts?
      break if error_check(rc)

      puts "#{Thread.current[:name]}: Incoming #{message}"
    end
  end

end

