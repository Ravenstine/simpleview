module Mouse
  @mouse = RuMouse.new
  def self.move x, y
    @mouse.move x,y
  end
  def self.left_release x, y
    @mouse.release x,y
  end
  def self.left_press x, y
    @mouse.press x,y
  end
end