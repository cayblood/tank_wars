module PlayerMove


  def move_left
    update_position(self.x - 2) unless blocked_on_left
  end

  def move_right
    update_position(self.x + 2) unless blocked_on_right
  end


  def update_position(x)
    self.x = x
    notify_position_change(x)
  end

  def update_opponent_position(x)
    self.x = x unless me?
  end
end