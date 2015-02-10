require 'bundler'
Bundler.require

EM.run do

  mouse = RuMouse.new
  EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|

    servers = {}
    @server = false

    ws.onopen do |handshake|

      if server_name = handshake.query["server"]
        @channel = servers[server_name] = EM::Channel.new
        @server = true
      else
        server_name = handshake.query["remote"]
        @channel = servers[server_name]
      end

      sid = @channel.subscribe do |message| 
        ws.send message
      end

      puts "#{sid} connected!"

      ws.onmessage do |message|
        @channel.push message
      end

      ws.onclose do
        puts "disconnected!"
        @channel.unsubscribe(sid)
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





