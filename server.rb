require 'bundler'
Bundler.require
require 'rack'
require 'rack/stream'

EM.run do
  EM::WebSocket.run host: "0.0.0.0", port: 9393 do |ws|

    cmd = "ffmpeg -y -f x11grab -s 1600x900 -r 15 -i :0.0 -tune fastdecode -b:v 150k -threads 4 -f webm -"
    @handler = EM.popen3(cmd, stdout: Proc.new { |data| 
      puts(data)
      ws.send(Base64.encode64(data))
    }, stderr: Proc.new{|err|})

    @handler.callback do
      puts "hey"
    end

    @handler.errback do |err_code|
      puts err_code
    end

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


  # EM.run do
  #   # use Rack::Stream
  #   Rack::Server.start({
  #     app:    Rack::Builder.app{map('/'){ run SimpleView.new }},
  #     server: 'thin',
  #     Host:   '0.0.0.0',
  #     Port:   '8181'
  #   })
  # end

  EM.run do

    class App
      include Rack::Stream::DSL

      stream do
        after_open do
          count = 0
          @timer = EM.add_periodic_timer(1) do
            chunk "chunky monkey\n"
          end
        end

        before_close do
          @timer.cancel
        end

        [200, {'Content-Type' => 'text/plain'}, ['Hello']]
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



