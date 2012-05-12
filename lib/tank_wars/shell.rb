class Shell < Chingu::GameObject
  traits :collision_detection, :bounding_circle

  def initialize(options)
    super
    @radius = 10

    @image = Image["shell.png"]

    cache_bounding_circle # This does a lot for performance
  end

  def update
  end
end