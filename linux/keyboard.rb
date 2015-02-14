module Keyboard
  def self.keydown code
    POSIX::Spawn.send(:`, "xdotool keydown #{code}")
  end
  def self.keyup code
    POSIX::Spawn.send(:`, "xdotool keyup #{code}")
  end
end