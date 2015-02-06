require 'bundler'
Bundler.require
require 'rack'
require 'base64'

  EM.run do

    class Streamer < EM::Connection

      def initialize socket
        @socket = socket
        @data = []
      end

      def receive_data data
        @data << data
      end

      def unbind
        send_data = Proc.new {@socket.send Base64.encode64(@data.join(""))}
        clear_data = Proc.new {@data.clear}
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

      EM::PeriodicTimer.new(0.5) do
        cmd = "convert x:root -quality 20 jpg:-"
        EM.popen(cmd, Streamer, ws)
      end

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





