require 'bundler'
Bundler.require :server

class Server
  def initialize
    @mouse = RuMouse.new
    establish_connection
  end

  def establish_connection
    @socket = WebSocket::EventMachine::Client.connect(uri: 'ws://54.200.180.86:9393?server&channel=gimpler')
    @socket.onopen do |handshake|
      puts "Connected to node."
      cast_screen
    end
    @socket.onclose do |code, reason|
      if code == 1002
        puts "Server contacted but node not found.  Retrying in 3 seconds..."
        EM::Timer.new(3){ establish_connection }
      else
        puts "Node connection closed."
      end
      @screencaster.cancel if @screencaster
    end
    @socket.onmessage do |message|
      message = JSON.parse(message)
      case message["event"]
      when "mousemove"
        @mouse.move message["data"][0], message["data"][1]
      when "mousedown"
        @mouse.press message["data"][0], message["data"][1]
      when "mouseup"
        @mouse.release message["data"][0], message["data"][1]
      when "keydown"
        POSIX::Spawn.send(:`, "xdotool keydown #{message['data']}")
      when "keyup"
        POSIX::Spawn.send(:`, "xdotool keyup #{message['data']}")
      end
    end
  rescue ConnectionError
    puts "Error connecting to websocket.  Retrying..."
    EM::Timer.new 3 do
      establish_connection
    end
  end

  def cast_screen
    @screencaster = EM::PeriodicTimer.new 1 do
      screenshot_command = "xwd -root | convert xwd:- -quality 20 jpg:- | base64"
      # screenshot_command = "import -window root -quality 20 jpg:- | base64 -"
      grab_desktop = Proc.new {POSIX::Spawn.send(:`, screenshot_command)}
      send_image = Proc.new do |result|
        unless result == @previous_frame
          @socket.send(result)
        end
        @previous_frame = result
      end
      EM.defer grab_desktop, send_image
    end
  end

end


EM.run do

  Server.new

end





