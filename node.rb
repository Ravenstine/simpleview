require 'bundler'
Bundler.require :node

class SocketConnection
  def initialize socket
    @socket = socket
  end
  def push message
    @socket.send message
  rescue
    puts "Could not push to socket."
  end
  def disconnect
    @socket.close_connection
    @socket = nil
  rescue
  end
end

class Client < SocketConnection
  def initialize socket, server
    super socket
    @server = server
    puts "Client Connected"
    @socket.onmessage do |message|
      @server.push message
    end
  end
  def disconnect
    super
    @server.clients.delete self
  end
end

class Server < SocketConnection
  attr_accessor :clients
  def initialize socket=nil
    self.socket = socket
    @clients = []
  end

  def socket= socket=nil
    @socket ||= socket
    puts "Server Connected"
    @socket.onmessage do |message|
      @clients.each do |client|
        client.push message
      end
    end
  rescue NoMethodError
    puts "Server was given no socket."
  ensure
    @socket  
  end

  def connected?
    @socket.state == :connected rescue false
  end
end

class Node
  attr_accessor :servers
  def initialize
    @servers = {}
  end
end

EM.run do

  @node = Node.new

  ## Server Socket
  EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|

    ws.onopen do |handshake|

      channel_name = handshake.query["channel"]
      server = @node.servers[channel_name] ||= Server.new
      server.socket = ws

      ws.onclose do
        server.disconnect
      end

    end

  end

  ## Client Socket
  EM::WebSocket.run host: "0.0.0.0", port: 9494 do |ws|

    ws.onopen do |handshake|

      channel_name = handshake.query["channel"]
      server = @node.servers[channel_name] ||= Server.new

      client = Client.new ws, server
      server.clients << client

      ws.onclose do
        client.disconnect
      end

    end

  end

  class WebServer  < EventMachine::Connection
    include EventMachine::HttpServer

    def process_http_request
      resp = EventMachine::DelegatedHttpResponse.new( self )
      resp.status = 200
      resp.content = IO.binread("#{Dir.pwd}#{@http_path_info}") rescue "I dunno, dawg."
      resp.send_response
    end
  end

  EventMachine::start_server("0.0.0.0", 1337, WebServer)

end





