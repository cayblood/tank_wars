module PlayerMove

  def move_left
    self.x -= 2 unless blocked_on_left
    notify_position_change

  end

  def move_right
    self.x += 2 unless blocked_on_right
    notify_position_change
  end
end