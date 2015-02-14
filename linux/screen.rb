class Screen
  def initialize socket
    @socket = socket
    @timer = EM::PeriodicTimer.new 1 do
      grab_screen
    end
  end
  def stop
    @timer.cancel
  end
private
  def grab_screen
    screenshot_command = "xwd -root | convert xwd:- -quality 20 jpg:- | base64"
    grab_desktop = Proc.new {POSIX::Spawn.send(:`, screenshot_command)}
    send_image = Proc.new do |result|
      unless result == @previous_frame
        @socket.send(result)
      end
      @previous_frame = result
    end
    EM.defer grab_desktop, send_image
  end
end