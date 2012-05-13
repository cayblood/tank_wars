module TankWars
  module PlayerDraw
    GUN_LENGTH = 20

    def draw_gun
      line_width = GUN_LENGTH * Math.cos(@radians)
      line_height = GUN_LENGTH * Math.sin(@radians)
      @gun_tip_x = @gun_base_x + line_width.round
      @gun_tip_y = @y + line_height.round
      $window.draw_line(@gun_base_x, @y, @color, @gun_tip_x, @gun_tip_y, @color)
    end

    def draw_power
      @power_text = Chingu::Text.new(@power.to_s, x: @x + 13, y: @y, zorder: 1, font: "Arial", size: 23)
      @power_text.x = @gun_base_x + ((@power_text.width - @width) / 2)
      @power_text.draw
    end

    def draw
      @rect = Chingu::Rect.new(@x, @y, @width, @height)
      $window.fill_rect(@rect, @color, 1)
      draw_gun
      #draw_power
    end

  end
end