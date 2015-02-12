require 'bundler'
Bundler.require

class SocketConnection
  def initialize socket
    @socket = socket
  end
  def push message
    @socket.send message
  end
  def disconnect
    @socket.close_connection
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
  attr_accessor :clients, :node, :channel
  def initialize socket=nil, node, channel
    self.socket = socket
    @clients = []
    @node = node
  end

  def socket= socket=nil
    @socket = socket
    if @socket
      puts "Server Connected"
      @socket.onmessage do |message|
        puts "Message received from server"
        @clients.each do |client|
          puts "Message sent to client"
          client.push message
        end
      end
    end  
    @socket  
  end

  def disconnect
    super
    @node.servers.delete[@channel]
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

  EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|

    ws.onopen do |handshake|

      is_server = handshake.query.has_key?("server")
      channel_name = handshake.query["channel"]
      server = @node.servers[channel_name] ||= Server.new(nil, @node, channel_name)

      if is_server
        server.socket = ws
      else
        client = Client.new ws, server
        server.clients << client
      end

      ws.onclose do
        (client || server).disconnect
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

  EventMachine::start_server("0.0.0.0", 5353, WebServer)

end





