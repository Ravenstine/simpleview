module Mouse
  @mouse = RuMouse.new
  # def self.move x, y
  #   @mouse.move x,y
  # end
  # def self.left_release x, y
  #   @mouse.release x,y
  # end
  # def self.left_press x, y
  #   @mouse.press x,y
  # end
  # def self.press data
  #   @mouse.press data['coords'][0], data['coords'][1], data['button']
  # end
  # def self.release data
  #   @mouse.release data['coords'][0], data['coords'][1], data['button']
  # end
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