require 'ov_service/zmq/proxy'

class Proxy
  include OvService::Zmq::Proxy
  def stop
    stop_proxy
  end

  def start
    puts "Starting the proxy..."
    start_proxy('tcp://127.0.0.1:5559', 'tcp://127.0.0.1:5560')
  end

end

