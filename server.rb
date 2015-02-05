require 'bundler'
Bundler.require
require 'rack'
require 'rack/stream'

EM.run do
  EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|



    # @handler.callback do
    #   puts "hey"
    # end

    # @handler.errback do |err_code|
    #   puts err_code
    # end

    ws.onopen do |handshake|
      puts "WebSocket connection open"
    end

    ws.onclose do
      puts "Connection closed"
      # @handler.kill('TERM', true)
    end

  end

  class SimpleView < Sinatra::Base
    set :public_folder, './'
    configure do
      set :threaded, false
    end
    get '/' do
      "root folder"
    end
  end


  EM.run do

    class App
      include Rack::Stream::DSL

      stream do
        stream = env['rack.stream']
        stream.after_open do
          count = 0

          cmd = "ffmpeg -y -f x11grab -s 640x480 -r 15 -i :0.0 -tune fastdecode -b:v 150k -threads 4 -f ogg -"
          # cmd = "echo hey fool"
          @handler = EM.popen3(cmd, stdout: Proc.new { |data| 
            # chunk data
            stream << data
          }, stderr: Proc.new{|err| puts err})

          @handler.callback do
            # close
          end

          @handler.errback do |err_code|
            puts err_code
          end
        end

        before_close do
          # @timer.cancel
          @handler.kill('TERM', true)
        end

        [200, {'Content-Type' => 'video/ogg', 'Cache-Control' => 'no-cache', 'Connection' => 'keep-alive', 'Content-Transfer-Encoding' => 'binary', 'Transfer-Encoding' => 'chunked', 'Content-Disposition' => 'inline; filename="stream.ogg"'}, []]
      end
    end

    app = Rack::Builder.app do
      use Rack::Stream
      run App.new
      map('/client'){ run SimpleView.new }
    end

    Rack::Server.start({
      app:    app,
      server: 'thin',
      Host:   '0.0.0.0',
      Port:   '5353'
    })

  end

end



