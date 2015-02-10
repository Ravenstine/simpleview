require 'bundler'
Bundler.require

EM.run do

  @servers = {}

  EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|

    ws.onopen do |handshake|

      server_name = handshake.query["channel"]

      @servers[server_name] ||= {}

      if @is_server = handshake.query.has_key?("server")
        puts "user is a server"
        channel = @servers[server_name]["server"] ||= EM::Channel.new
      else
        puts "user is a client"
        clients = @servers[server_name]["clients"] ||= []
        channel = EM::Channel.new
        clients << channel
      end

      sid = channel.subscribe do |message|
        ws.send message
      end

      ws.onmessage do |msg|
        if @is_server
          clients = @servers[server_name]["clients"]
          EM::Iterator.new(clients).each do |client|
            client.push msg
          end
        else
          @servers[server_name]["server"].push msg
        end
      end

      ws.onclose do
        channel.unsubscribe(sid)
        if @is_server
          @servers[server_name].delete
        else
          @servers[server_name]["clients"].delete(channel)
        end
      end
    end

  end

  class Server  < EventMachine::Connection
    include EventMachine::HttpServer

    def process_http_request
      resp = EventMachine::DelegatedHttpResponse.new( self )
      resp.status = 200
      resp.content = IO.binread("#{Dir.pwd}#{@http_path_info}") rescue "I dunno, dawg."
      resp.send_response
    end
  end

  EventMachine::start_server("0.0.0.0", 5353, Server)

end





