require 'ffi-rzmq'

class Proxy

  def initialize
    #@context = ZMQ::Context.new
  end

  def stop
    puts 'Shutting down the proxy'
    @proxy[:router].setsockopt(ZMQ::LINGER, 1)
    @proxy[:router].close
    @proxy[:dealer].setsockopt(ZMQ::LINGER, 1)
    @proxy[:dealer].close
    @context.terminate
  end

  def start
    puts "Starting the proxy..."
    @context = ZMQ::Context.new

    @proxy = Thread.new do
      Thread.current[:router] = @context.socket(ZMQ::ROUTER)
      Thread.current[:router].bind('tcp://*:5559')

      Thread.current[:dealer] = @context.socket(ZMQ::DEALER)
      Thread.current[:dealer].bind('tcp://*:5560')

      poller = ZMQ::Proxy.new(Thread.current[:router], Thread.current[:dealer])
    end
    @proxy.join
  end

end

