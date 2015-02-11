require 'bundler'
Bundler.require

class SocketConnection
  def initialize socket
    @socket = socket
  end
  def push message
    @socket.send message
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
end

class Server < SocketConnection
  attr_accessor :clients
  def initialize socket
    super socket
    @clients = []
    puts "Server Connected"
    @socket.onmessage do |message|
      puts "Message received from server"
      @clients.each do |client|
      # EM::Iterator.new(@clients) do |client|
        puts "Message sent to client"
        client.push message
      end
    end
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

      @is_server = handshake.query.has_key?("server")
      server_name = handshake.query["channel"]
      @node.servers[server_name] ||= Server.new(ws) if @is_server
      server = @node.servers[server_name]

      if @is_server
        channel = server
      else
        channel = Client.new ws, server
        server.clients << channel
      end


      # server = @servers[server_name]["server"] ||= EM::Channel.new
      # clients = @servers[server_name]["clients"] ||= []

      # if @is_server = handshake.query.has_key?("server")
      #   puts "user is a server"
      #   channel = server
      # else
      #   puts "user is a client"
      #   client = EM::Channel.new
      #   channel = client
      #   clients << client
      # end

      # sid = channel.subscribe do |message|
      #   ws.send message
      # end

      # ws.onmessage do |msg|
      #   if @is_server
      #     EM::Iterator.new(clients).each do |client|
      #       client.push msg
      #     end
      #   else
      #     server.push msg
      #   end
      # end

      # ws.onclose do
      #   channel.unsubscribe(sid)
      #   if @is_server
      #     @servers[server_name].delete
      #   else
      #     clients.delete(channel)
      #   end
      # end
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





