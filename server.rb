require 'bundler'
Bundler.require

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
      send_file
    end
  end

  EM.run do
    Rack::Server.start({
      app:    Rack::Builder.app{map('/'){ run SimpleView.new }},
      server: 'thin',
      Host:   '0.0.0.0',
      Port:   '8181'
    })
  end

end



