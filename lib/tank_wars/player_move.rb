module PlayerMove


  def update_position
    self.gun_base_x = @x + (@width / 2)
    notify_position_change
  end
  def move_left
    self.x -= 2 unless blocked_on_left
    update_position
  end

  def move_right
    self.x += 2 unless blocked_on_right
    update_position
  end
end