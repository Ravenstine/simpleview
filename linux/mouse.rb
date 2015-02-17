module Mouse
  @mouse = RuMouse.new
  def self.mousedown x, y, button
    @mouse.press x, y, button
  end
  def self.mouseup x, y, button
    @mouse.release x, y, button
  end
  def self.mousemove x, y
    @mouse.move x, y
  end
end