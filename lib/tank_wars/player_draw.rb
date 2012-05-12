module PlayerDraw
  def draw_gun
    $window.draw_line(@gun_base_x, @y, @color, @gun_tip_x, @gun_tip_y, @color)
  end

  def draw_power
    @power_text = Chingu::Text.new(@power.to_s, x: @x + 13, y: @y, zorder: 1, font: "Arial", size: 23)
    @power_text.x = @gun_base_x + ((@power_text.width - @width ) / 2)
    @power_text.draw
  end

  def draw
    @rect = Chingu::Rect.new(@x, @y, @width, @height)
    $window.fill_rect(@rect, @color, 1)
    draw_gun
    draw_power
  end

end