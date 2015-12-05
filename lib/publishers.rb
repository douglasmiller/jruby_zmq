require 'ffi-rzmq'

class Publishers

  def initialize
    @publishers = []
    @context = ZMQ::Context.new
  end

  def stop
    puts 'Shutting down publishers'
    @publishers.each do |thread|
      thread[:socket].close
      thread.exit
    end
    @context.terminate
  end

  def start
    2.times do |i|
      @publishers << Thread.new do
        Thread.current[:name] = "Thread #{i}"
        Thread.current[:socket] = @context.socket(ZMQ::PUB)
        Thread.current[:socket].bind('tcp://127.0.0.1:2200')
        run_loop
      end
    end
    @publishers.each(&:join)
  end

  def run_loop
    5.times do
      puts "Sending heartbeat from #{Thread.current[:name]}"

      Thread.current[:socket].send_string('Heartbeat', ZMQ::SNDMORE)
      Thread.current[:socket].send_string("Message from: #{Thread.current[:name]}")

      sleep(2)
    end
  end

end

