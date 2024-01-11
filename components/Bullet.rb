class Bullet

  attr_accessor :x, :y, :type, :img, :vel_x, :vel_y, :angle
  def initialize(img, type, vel, x, y)
    @type = type
    @img = Gosu::Image.new(img)
    # Create the object randomly from the edge of program
    if rand(2) == 0
      @x = WIDTH * rand(2)
      @y = rand(HEIGHT)
    else
      @x = rand(WIDTH)
      @y = HEIGHT * rand(2)
    end
    # Explain?
    d = Gosu.distance(@x, @y, x, y)
    @vel_x = (vel * (@x - x) / d)
    @vel_y = (vel * (@y - y) / d)
    @angle = Gosu.angle(@x, @y, x, y)
  end
end

  # Move bullet
  def move(bullet)
    if (bullet.x != nil && bullet.y != nil)
      if ( bullet.x < WIDTH || bullet.y < HEIGHT || bullet.x > 0 || bullet.y > 0)   
        bullet.x -= bullet.vel_x
        bullet.y -= bullet.vel_y
      end
    end
  end
  
  
  def drawBullet bullet
    if (bullet.img != nil)
      bullet.img.draw_rot(bullet.x, bullet.y, ZOrder::UI, bullet.angle)
    end
  end

 