require 'ffi-rzmq'

class Subscriber

  def initialize
    @context = ZMQ::Context.new
  end

  def stop
    puts 'Shutting down subscriber'
    @subscriber[:socket].close
    @subscriber.exit
    @context.terminate
  end

  def start
    @subscriber = Thread.new do
      puts "Starting subscriber..."
      Thread.current[:socket] = @context.socket(ZMQ::SUB)
      Thread.current[:socket].setsockopt(ZMQ::SUBSCRIBE,'Heartbeat')
      Thread.current[:socket].connect('tcp://127.0.0.1:2200')

      loop do
        topic = ''
        body = ''
        Thread.current[:socket].recv_string(topic)
        Thread.current[:socket].recv_string(body) if Thread.current[:socket].more_parts?

        puts "Incoming heartbeat: '#{body}'"
      end
    end
    @subscriber.join
  end

end

