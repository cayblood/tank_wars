module PlayerMove


  def move_left
    update_position(self.x - 2) unless blocked_on_left
  end

  def move_right
    update_position(self.x + 2) unless blocked_on_right
  end


  def update_position(x)
    notify_position_change(x)
  end
end