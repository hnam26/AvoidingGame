  class Champion 
    attr_accessor :step, :x, :y, :img, :dest_x, :dest_y

    def initialize()
      @img = Gosu::Image.new("./resources/image/current.png")
      @x = 400
      @y = 305
      @dest_x = nil
      @dest_y = nil
      @step = 5
    end

    def moveTo(x, y)
      @dest_x = x
      @dest_y = y
    end

    def update
      if @dest_x != nil
        d = Gosu.distance(@x, @y, @dest_x, @dest_y)
        if d < @step
          @x = @dest_x
          @y = @dest_y
        else
          @x -= (@step * (@x - @dest_x) / d)
          @y -= (@step * (@y - @dest_y) / d)
        end
      end
    end

    def draw
      @img.draw_rot(@x.to_f, @y.to_f, ZOrder:: PLAYER)
    end

  end