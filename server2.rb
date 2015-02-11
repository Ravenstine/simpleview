require 'bundler'
Bundler.require

EM.run do

  mouse = RuMouse.new

  ws = WebSocket::EventMachine::Client.connect(uri: 'ws://127.0.0.1:9393?server&channel=gimpler')

    ws.onopen do |handshake|
      puts "Connection to node acquired."
    end

    ws.onclose do
      puts "Node connection closed."
    end

    ws.onmessage do |message|
      message = JSON.parse(message)
      case message["event"]
      when "mousemove"
        mouse.move message["data"][0], message["data"][1]
      when "mousedown"
        mouse.press message["data"][0], message["data"][1]
      when "mouseup"
        mouse.release message["data"][0], message["data"][1]
      when "keydown"
        puts 'keydown'
        # POSIX::Spawn.send(:`, "xdotool keydown #{message['data']}")
      when "keyup"
        puts 'keyup'
       # POSIX::Spawn.send(:`, "xdotool keyup #{message['data']}")
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




