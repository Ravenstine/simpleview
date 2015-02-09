require 'bundler'
Bundler.require

EM.run do

  mouse = RuMouse.new
  EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|

    ws.onopen do |handshake|
      puts "WebSocket connection open"
    end

    ws.onclose do
      puts "Connection closed"
    end

    ws.onmessage do |message|
      message = JSON.parse(message)
      case message["event"]
      when "mousemove"
        mouse.move message["data"][0], message["data"][1]
      when "click"
        mouse.click message["data"][0], message["data"][1]
      end
    end

    EM::PeriodicTimer.new 1 do
      screenshot_command = "xwd -root | convert xwd:- -quality 20 jpg:- | base64"
      # screenshot_command = "import -window root -quality 20 jpg:- | base64 -"
      grab_desktop = Proc.new {POSIX::Spawn.send(:`, screenshot_command)}
      send_image = Proc.new do |result|
        unless result == @previous_frame
          ws.send(result)
        end
        @previous_frame = result
      end
      EM.defer grab_desktop, send_image
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





