require 'bundler'
Bundler.require :server
require './linux/keyboard'
require './linux/mouse'
require './linux/screen'

class Server
  def initialize
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
      @screen.stop if @screen
    end
    @socket.onmessage do |message|
      message = JSON.parse(message)
      case message["event"]
      when "mousemove"
        Mouse.move message["data"][0], message["data"][1]
      when "mousedown"
        Mouse.left_press message["data"][0], message["data"][1]
      when "mouseup"
        Mouse.left_release message["data"][0], message["data"][1]
      when "keydown"
        Keyboard.keydown message['data']
      when "keyup"
        Keyboard.keyup message['data']
      end
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





