require 'rubygems'
require 'gosu'

WIDTH  = 800
HEIGHT = 600
module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

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
    # Moving the Champion
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

class Bullets
  
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
    # Using Property of Congruent Triangles
    d = Gosu.distance(@x, @y, x, y)
    @vel_x = (vel * (@x - x) / d)
    @vel_y = (vel * (@y - y) / d)
    @angle = 0
  end
end

class Game < Gosu::Window
  
  def initialize(difficulty,smallFont, bigFont)
    super WIDTH, HEIGHT
    @backgroundImage = Gosu::Image.new("./resources/image/space1.jpg", :tileable => true)
    @champion = Champion.new()
    @allBullets = Array.new()
    @timeOffset = Gosu.milliseconds/1000
    @skillImg = Gosu::Image.new("./resources/image/stick.png")
    @stickAngle = 0.0
    @skill = false
    @cooldown = false
    @difficulty = difficulty
    @smallFont = smallFont
    @bigFont = bigFont
  end
  
  def update
    # Using mouse to control the champion
    if Gosu.button_down?(Gosu::MS_RIGHT)
      @champion.moveTo(mouse_x, mouse_y)
    end
    # Calculate the exact starting time 
    @time = Gosu.milliseconds/1000 - @timeOffset
    # Update the position of the champion
    @champion.update
    @allBullets.each {|bullets| move (bullets)}
    removeBullets(@allBullets)
    generateBulletsFrequency()
    Collision(@allBullets, @champion)
    skillCooldown()
  end
  
  def draw
    @backgroundImage.draw(0, 0, ZOrder:: BACKGROUND)
    @champion.draw
    @allBullets.each {|bullets| drawBullets bullets}
    @smallFont.draw_text("Time: #{@time}s", 315 , 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    @skillImg.draw_rot(400, 520, ZOrder::UI,@stickAngle)    
  end
  
  def generateBulletsFrequency()
    #  @time/@difficulty = maxBullets 
    if rand(100) < 20 and @allBullets.size < @time/@difficulty
      @allBullets.push(generateBullets(@champion.x, @champion.y))
    end
  end
  
  def skillCooldown()
    if @skill
      @stickAngle += 8  
      @cooldown = true
      if @stickAngle == 360
        @skill = false  
        @cooldown = false
      end
    end
  end
  
  def Collision(allBullets, champion)
    allBullets.reject! do |bullets|
      distance = Gosu.distance(champion.x, champion.y, bullets.x, bullets.y)
      if ((bullets.type == :blackhole && distance < 43) || 
        (bullets.type == :snow && distance < 40) || 
        (bullets.type == :steel && distance < 49) || 
        (bullets.type == :lighting && distance < 43))
        close
        @result = @time
        Result.new(@result,@smallFont, @bigFont,@difficulty).show if __FILE__ == $0
      end
    end
  end
  
  def generateBullets (x, y)
    case rand(4)
    when 0
      Bullets.new("./resources/image/lighting.png", :lighting, 5, x, y)
    when 1
      Bullets.new("./resources/image/blackhole.png", :blackhole, 3, x, y)
    when 2
      Bullets.new("./resources/image/snow.png", :snow, 6, x, y)
    when 3
      Bullets.new("./resources/image/steel.png", :steel,4, x, y )
    end
  end
  
  def skill()
    if (@champion.x != nil && @champion.dest_x != nil && @champion.y != nil && @champion.dest_y != nil)
      d = Gosu.distance(@champion.x, @champion.y, @champion.dest_x, @champion.dest_y)
      if @cooldown == false && @champion.x != @champion.dest_x && @champion.y != @champion.dest_y
        @stickAngle = 0
        if (d > @champion.step * 30)
          @champion.x -= (@champion.step * 30 * (@champion.x - @champion.dest_x) / d)
          @champion.y -= (@champion.step * 30 * (@champion.y - @champion.dest_y) / d)
        else 
          @champion.x = @champion.dest_x
          @champion.y = @champion.dest_y
        end
        @skill = true 
      end
    end
  end
  
  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    end
    case id
    when Gosu::KB_SPACE
      skill()
    end 
  end
  
  def removeBullets(allBullets)
    allBullets.reject! do |bullets|
      if bullets.x > WIDTH || bullets.y > HEIGHT || bullets.x < 0 || bullets.y < 0
        true
      else
        false
      end
    end
  end
  
  # Move bullets
  def move(bullets)
    if (bullets.x != nil && bullets.y != nil)
      if ( bullets.x < WIDTH || bullets.y < HEIGHT || bullets.x > 0 || bullets.y > 0)   
        bullets.x -= bullets.vel_x
        bullets.y -= bullets.vel_y
      end
    end
  end
  
  def drawBullets bullets
    if (bullets.img != nil)
      bullets.img.draw_rot(bullets.x, bullets.y, ZOrder::UI, bullets.angle)
    end
  end  
  
end

# ================================================================================

class Result < Gosu::Window
  def initialize (result,smallFont, bigFont,difficulty)
    super(WIDTH, HEIGHT, false)
    @background = Gosu::Image.new("./resources/image/space3.jpg")
    @difficulty = difficulty
    @hugeFont = Gosu::Font.new(90, bold: true, name: "./resources/content/Lmht.otf")
    @smallFont = smallFont
    @bigFont = bigFont
    @smallerFont = Gosu::Font.new(40, bold: true, name: "./resources/content/Lmht.otf")
    self.caption = "Food Hunter Game"
    @result = result
    loadHighScore()
  end
  
  def draw
    @background.draw(0,0, ZOrder::BACKGROUND)
    @hugeFont.draw_text("You Failed!!!", 180, 70,ZOrder::UI, 1.0, 1.0, Gosu::Color::RED)
    @smallFont.draw_text("Your Score:", 230, 220,ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    @smallerFont.draw_text(@result, 525, 200,ZOrder::UI, 2.0, 2.0, Gosu::Color::YELLOW)
    @smallFont.draw_text("High Score:", 230, 300, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    @smallerFont.draw_text(@highScore, 525, 280,ZOrder::UI, 2.0, 2.0, Gosu::Color::YELLOW)
    @smallFont.draw_text("Play Again", 270, 425 , ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    @smallFont.draw_text("Home", 335, 507 , ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    # Hover Button
    button = mouseOverButton(mouse_x, mouse_y)
    case button
    when 0
      @smallFont.draw_text("Play Again", 270, 425 , ZOrder::UI, 1.0, 1.0, Gosu::Color.new(0xFF0000BB))
    when 1  
      @smallFont.draw_text("Home", 335, 507 , ZOrder::UI, 1.0, 1.0, Gosu::Color.new(0xFF0000BB))
    end
  end
  
  def mouseOverButton(mouse_x, mouse_y)
    if mouse_x.between?(260, 505)
      if mouse_y.between?(420, 480)
        return 0
      end
    end
    if mouse_x.between?(325, 455)
      if mouse_y.between?(500, 560)
        return 1
      end
    end
  end
  
  def loadHighScore()
    fileName = File.new("./resources/content/record.txt", "r")
    @highScore = fileName.gets.chomp
    fileName.close
    if (@highScore.to_i < @result.to_i)
      fileName = File.new("./resources/content/record.txt", "w")
      @highScore = @result
      fileName.puts(@highScore)
      fileName.close
    end
  end
  
  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    end
    case id
    when Gosu::MsLeft
      button = mouseOverButton(mouse_x,mouse_y)
      case button
      when 0
        close
        Game.new(@difficulty,@smallFont, @bigFont).show if __FILE__ == $0
      when 1
        close 
        Home.new.show if __FILE__ == $0
      end
    end
  end
  
end

# ================================================================================

class Difficulty < Gosu::Window
  def initialize (smallFont, bigFont)
    super(WIDTH, HEIGHT, false)
    @backgroundImage = Gosu::Image.new("./resources/image/space2.jpg")
    # @bigFont = Gosu::Font.new(70,bold: true, name: "./resources/content/Lmht.otf")
    # @smallFont = Gosu::Font.new(50,bold: true, name: "./resources/content/Lmht.otf")
    @smallFont = smallFont
    @bigFont = bigFont
    @difficulty = 0
  end
  
  def draw()
    @backgroundImage.draw(0, 0, ZOrder::BACKGROUND)
    @smallFont.draw_text("Difficulty", 298, 40,ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    @smallFont.draw_text("Easy", 345, 300,ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    @smallFont.draw_text("Hard", 345, 360,ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    # Hover button
    button = mouseOverButton(mouse_x, mouse_y)
    case button
    when 0
      @smallFont.draw_text("Easy", 345, 300,ZOrder::UI, 1.0, 1.0, Gosu::Color.new(0xFF0000BB))
    when 1
      @smallFont.draw_text("Hard", 345, 360,ZOrder::UI, 1.0, 1.0, Gosu::Color.new(0xFF0000BB))
    end
  end
  
  def mouseOverButton(mouse_x, mouse_y)
    if mouse_x.between?(345, 445)
      if mouse_y.between?(310, 350)
        return 0
      end
    end
    if mouse_x.between?(345, 445)
      if mouse_y.between?(370, 400)
        return 1
      end
    end
  end
  
  
  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    end
    button = mouseOverButton(mouse_x, mouse_y)
    case button
    when 0
      @difficulty = 4
      close 
      Game.new(@difficulty,@smallFont, @bigFont).show if __FILE__ == $0
    when 1
      @difficulty = 1 
      close 
      Game.new(@difficulty,@smallFont, @bigFont).show if __FILE__ == $0
    end
  end
end

# ================================================================================

class Instruction < Gosu::Window
  def initialize (smallFont, bigFont)
    super(WIDTH, HEIGHT, false)
    @backgroundImage = Gosu::Image.new("./resources/image/space2.jpg")
    @smallFont = smallFont
    @bigFont = bigFont
    @smallerFont = Gosu::Font.new(40,bold: true, name: "./resources/content/Lmht.otf")
    @instructionLines = Array.new()
    readInstruction(@instructionLines)
    self.caption = "Avoiding Skill Game"
  end
  
  def draw
    @backgroundImage.draw(0, 0, ZOrder::BACKGROUND)
    @bigFont.draw_text("Instruction", 242,40 , ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    # Display all the instruction
    i = 0
    while (i < @total)
      @smallerFont.draw_text(@instructionLines[i], 86, 155 + 60*i,ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
      i += 1
    end
    @smallFont.draw_text("Home", 335, 505,ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    # When mouse move to the "Home" button -> change color (hover button)
    if mouseOverButton()
      @smallFont.draw_text("Home", 335, 535 - 30,ZOrder::UI, 1.0, 1.0, Gosu::Color.new(0xFF0000BB))  
    end
  end
  
  def mouseOverButton()   
    if mouse_x.between?(335, 450)
      if mouse_y.between?(515, 545)
        true
      end
    end
  end
  
  def readInstruction(array)
    fileName = File.new("./resources/content/instruction.txt", "r")
    @total = fileName.gets.to_i
    i = 0
    while (i < @total)
      array[i] = fileName.gets
      i += 1
    end
  end
  
  
  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    end
    
    if id == Gosu::MsLeft
      if mouseOverButton()
        close 
        Home.new.show if __FILE__ == $0
      end
    end
  end
end

# ================================================================================

class Home < Gosu::Window
  
  def initialize 
    super(WIDTH, HEIGHT, false)
    @backgroundImage = Gosu::Image.new("./resources/image/space2.jpg")
    @smallFont = Gosu::Font.new(50,bold: true, name: "./resources/content/Lmht.otf")
    @bigFont = Gosu::Font.new(70,bold: true, name: "./resources/content/Lmht.otf")
    self.caption = "Avoiding Skill Game"
  end
  
  def draw
    @backgroundImage.draw(0, 0, ZOrder::BACKGROUND)
    @bigFont.draw_text("Avoiding Skill", 200, 100 , ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    @smallFont.draw_text("Play", 345,420 , ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    @smallFont.draw_text("Instruction", 280,480 , ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    # Hover button    
    button = mouseOverButton(mouse_x, mouse_y)
    case button
    when 0
      @smallFont.draw_text("Play", 345,420 , ZOrder::UI, 1.0, 1.0, Gosu::Color.new(0xFF0000BB))
    when 1
      @smallFont.draw_text("Instruction", 280,480 , ZOrder::UI, 1.0, 1.0, Gosu::Color.new(0xFF0000BB))
    end
  end
  
  def mouseOverButton(mouse_x, mouse_y)
    if mouse_x.between?(335, 450)
      if mouse_y.between?(430, 460)
        return 0
      end
    end
    
    if mouse_x.between?(280, 505)
      if mouse_y.between?(490, 520)
        return 1
      end
    end
  end
  
  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    when Gosu::MsLeft
      button = mouseOverButton(mouse_x, mouse_y)
      case button
      when 0
        close
        Difficulty.new(@smallFont, @bigFont).show if __FILE__ == $0
      when 1
        close
        Instruction.new(@smallFont, @bigFont).show if __FILE__ == $0
      end
    end
  end
  
end

Home.new.show if __FILE__ == $0