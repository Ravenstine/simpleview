require 'bundler'
Bundler.require
require 'rack'
require 'rack/stream'

  EM.run do

    class Streamer < EM::Connection

      def initialize stream
        @stream = stream
      end

      def receive_data data
        @stream << data
      end

    end

    class Video
      def self.handler stream=nil
        if @handler
          stop
          @handler = nil
        end
        cmd = "ffmpeg -y -f x11grab -s 1600x900 -r 5 -i :0.0 -tune fastdecode -b:v 256k -threads 4 -f ogg -"    
        @handler = EM.popen(cmd, Streamer, stream)
      end

      def self.stop
        @handler.close_connection if @handler
      end
    end


    class App
      include Rack::Stream::DSL

        mouse = RuMouse.new
        EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|

          ws.onopen do |handshake|
            puts "WebSocket connection open"
            
          end

          ws.onclose do
            puts "Connection closed"
            Video.stop
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

        end

        stream do
          after_open do
            Video.handler env['rack.stream']
          end
          [200, {'Content-Type' => "video/ogg", 'Cache-Control' => 'no-cache', 'Content-Transfer-Encoding' => 'binary', 'Content-Disposition' => "inline; filename='stream.ogg'"}, []]
        end

    end

    app = Rack::Builder.app do
      use Rack::Static, :urls => ["/client.html", "/style.css", "/application.js"], :root => "./"
      use Rack::Stream
      run App.new
    end

    Rack::Server.start({
      app:    app,
      server: 'thin',
      Host:   '0.0.0.0',
      Port:   '5353'
    })

  end





