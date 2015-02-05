require 'bundler'
Bundler.require
require 'rack'
require 'rack/stream'

EM.run do
  mouse = RuMouse.new
  EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|

    ws.onopen do |handshake|
      puts "WebSocket connection open"
    end

    ws.onclose do
      puts "Connection closed"
      @handler.kill('TERM', true) if @handler
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

  # class SimpleView < Sinatra::Base
  #   set :public_folder, './'
  #   configure do
  #     set :threaded, false
  #   end
  #   get '/' do
  #     "root folder"
  #   end
  # end


  EM.run do

    class Streamer < EM::Connection

      def self.header
        @header
      end

      def self.add_header head
        @header = head
      end

      def self.add_callback &callback
        callbacks << callback
      end

      def self.callbacks
        @callbacks ||= []
      end

      def receive_data data
        EM::Iterator.new(self.class.callbacks).each do |callback|
          self.class.add_header data if self.class.header.nil?
          callback.call data
        end
      end

    end
    # cmd = "ffmpeg -y -f x11grab -s 1600x900 -r 5 -i :0.0 -tune fastdecode -b:v 256k -threads 4 -f ogg -"
    # cmd = "ffmpeg -y -f x11grab -s 1600x900 -r 5 -i :0.0 -movflags faststart -b:v 256k -threads 4 -f mp4 -"
    cmd = "ffmpeg -y -f x11grab -s 1600x900 -r 5 -re -i :0.0 -g 52 -c:v libx264 -crf 22 -c:a libfaac -movflags frag_keyframe+empty_moov -f mp4 -"
    # cmd = "ffmpeg -y -f x11grab -s 1600x900 -r 5 -i :0.0 -c:v libx264 -f segment -segment_time 4 -segment_format mp4 -"


    EM.popen(cmd, Streamer)
  end

  EM.run do
    class App
      include Rack::Stream::DSL

      @@streams = []

      stream do
        after_open do

          env['rack.stream'] << Streamer.header if Streamer.header

          Streamer.add_callback do |data|
            env['rack.stream'] << data
          end

        end

        before_close do
          puts 'the stream is closed'
          # @handler.kill('TERM', true)
        end

        [200, {'Content-Type' => 'video/mp4', 'Cache-Control' => 'no-cache', 'Content-Transfer-Encoding' => 'binary', 'Transfer-Encoding' => 'identity', 'Content-Disposition' => 'inline; filename="stream.mp4"'}, []]
      end
    end

    app = Rack::Builder.app do
      use Rack::Stream
      run App.new
      # map('/client'){ run SimpleView.new }
    end

    Rack::Server.start({
      app:    app,
      server: 'thin',
      Host:   '0.0.0.0',
      Port:   '5353'
    })

  end

end



