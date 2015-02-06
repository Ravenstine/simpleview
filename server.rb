require 'bundler'
Bundler.require
require 'rack'
require 'base64'

  EM.run do

    class Streamer < EM::Connection

      def initialize socket
        @socket = socket
        @data = ""
      end

      def receive_data data
        puts "whutup dog"
        @data += data
      end

      def unbind
        # send_data = Proc.new {@socket.send Base64.encode64(@data)}

        send_data = Proc.new {@socket.send @data}
        clear_data = Proc.new do 
          @data.clear
          # cmd = "convert x:root -quality 70 jpg:-"
          cmd = "convert x:root -quality 20 jpg:- | base64 -"
          EM.popen(cmd, self.class, @socket)    
        end
        EM.defer send_data, clear_data    
      end

    end

    class App
      def call env
        [200, {}, 'Hello World']
      end
    end

    mouse = RuMouse.new
    EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|

      ws.onopen do |handshake|
        puts "WebSocket connection open"
        # ws.send `convert x:root -quality 20 jpg:- | base64 -`
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

      # sender = Proc.new do
      #   EM.defer Proc.new{ ws.send(`convert x:root -quality 20 jpg:- | base64 -`)}, sender
      # end

        sender = Proc.new do
          ws.send(`convert x:root -quality 20 jpg:- | base64 -`)
        end

      EM::PeriodicTimer.new(1) do
        # EM.defer sender
        Thread.new do
          sender.call
        end
      end

      # sender.call


      # cmd = "convert x:root -quality 20 jpg:- | base64 -"
      # EM.popen(cmd, Streamer, ws)


    end

    app = Rack::Builder.app do
      use Rack::Static, :urls => ["/client.html", "/style.css", "/application.js"], :root => "./"
      run App.new
    end

    Rack::Server.start({
      app:    app,
      server: 'thin',
      Host:   '0.0.0.0',
      Port:   '5353'
    })

  end





