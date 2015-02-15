require 'bundler'
Bundler.require :server
require './linux/keyboard'
require './linux/mouse'
require './linux/screen'
require 'json'

class Server
  def initialize
    @settings = YAML.load(File.read("#{Dir.pwd}/server.yml"))
    establish_connection
  rescue Errno::ENOENT
    puts "[ERROR]: Could not load server.yml"
  end

  def establish_connection
    @socket = WebSocket::EventMachine::Client.connect(uri: "ws://#{@settings['node']['url']}?channel=#{@settings['server']['channel']}")
    @socket.onopen do |handshake|
      puts "Connected to node."
      cast_screen
    end
    @socket.onclose do |code, reason|
      responses = {
        1002 => Proc.new{
          puts "Server contacted but node not found.  Retrying in 3 seconds..."
          EM::Timer.new(3){ establish_connection }
        },
        :closed => Proc.new{
          puts "Node connection closed."
        }
      }

      responses[code].call || responses[:closed].call
      @screen.stop
    rescue => e
      puts "There was a problem:"
      puts e
    end
    @socket.onmessage do |message|
      message = JSON.parse(message)['data']
      Object.const_get(message['constant']).send(message['method'], *message['arguments']) rescue nil
    end
  rescue ConnectionError
    puts "Error connecting to websocket.  Retrying..."
    EM::Timer.new 3 do
      establish_connection
    end
  end

  def cast_screen
    @screen = Screen.new @socket
  end

end

EM.run do
  Server.new
end





