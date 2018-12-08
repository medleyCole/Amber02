# script updated 1.0
# necessary for sprite rendering
class AnimatedBitmapWrapper
  attr_reader :width
  attr_reader :height
  attr_reader :totalFrames
  attr_reader :animationFrames
  attr_reader :currentIndex
  attr_accessor :scale
  
  def initialize(file,scale=2)
    raise "filename is nil" if file==nil
    raise ".gif files are not supported!" if File.extname(file)==".gif"
    
    @scale = scale
    @width = 0
    @height = 0
    @frame = 0
    @frames = 2
    @direction = +1
    @animationFinish = false
    @totalFrames = 0
    @currentIndex = 0
    @speed = 1
      # 0 - not moving at all
      # 1 - normal speed
      # 2 - medium speed
      # 3 - slow speed
    bmp = pbBitmap(file)
    @bitmapFile = Bitmap.new(bmp.width,bmp.height); @bitmapFile.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
	bmp.dispose
    # initializes full Pokemon bitmap
    @bitmap = Bitmap.new(@bitmapFile.width,@bitmapFile.height)
    @bitmap.blt(0,0,@bitmapFile,Rect.new(0,0,@bitmapFile.width,@bitmapFile.height))
    @width = @bitmapFile.height*@scale
    @height = @bitmap.height*@scale
    
    @totalFrames = @bitmap.width/@bitmap.height
    @animationFrames = @totalFrames*@frames
    # calculates total number of frames
    @loop_points = [0,@totalFrames]
    # first value is start, second is end
    
    @actualBitmap = Bitmap.new(@width,@height)
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end
    
  def length; @totalFrames; end
  def disposed?; @actualBitmap.disposed?; end
  def dispose;
    @bitmap.dispose
    @bitmapFile.dispose
	@actualBitmap.dispose
  end
  def copy; @actualBitmap.clone; end
  def bitmap; @actualBitmap; end
  def bitmap=(val); @actualBitmap=val; end
  def each; end
  def alterBitmap(index); return @strip[index]; end
    
  def prepareStrip
    @strip=[]
    for i in 0...@totalFrames
      bitmap=Bitmap.new(@width,@height)
      bitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmapFile,Rect.new((@width/@scale)*i,0,@width/@scale,@height/@scale))
      @strip.push(bitmap)
    end
  end
  def compileStrip
    @bitmap.clear
    for i in 0...@strip.length
      @bitmap.stretch_blt(Rect.new((@width/@scale)*i,0,@width/@scale,@height/@scale),@strip[i],Rect.new(0,0,@width,@height))
    end
  end
  
  def reverse
    if @direction  >  0
      @direction=-1
    elsif @direction < 0
      @direction=+1
    end
  end
  
  def setLoop(start, finish)
    @loop_points=[start,finish]
  end
  
  def setSpeed(value)
    @speed=value
  end
  
  def toFrame(frame)
    if frame.is_a?(String)
      if frame=="last"
        frame=@totalFrames-1
      else
        frame=0
      end
    end
    frame=@totalFrames if frame > @totalFrames
    frame=0 if frame < 0
    @currentIndex=frame
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end
  
  def play
    return if @currentIndex >= @loop_points[1]-1
    self.update
  end
  
  def finished?
    return (@currentIndex==@totalFrames-1)
  end
  
  def update
    return false if @actualBitmap.disposed?
    return false if @speed < 1
    case @speed
    # frame skip
    when 1
      @frames=3
    when 2
      @frames=5
    when 3
      @frames=7
    end
    @frame+=1
    if @frame >= @frames
      # processes animation speed
      @currentIndex+=@direction
      @currentIndex=@loop_points[0] if @currentIndex >=@loop_points[1]
      @currentIndex=@loop_points[1]-1 if @currentIndex < @loop_points[0]
      @frame=0
    end
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
    # updates the actual bitmap
  end
    
  # returns bitmap to original state
  def deanimate
    @frame=0
    @currentIndex=0
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end
end

class DynamicPokemonSprite
  attr_accessor :shadow
  attr_accessor :sprite
  attr_accessor :showshadow
  attr_accessor :status
  attr_accessor :hidden
  attr_accessor :fainted
  attr_accessor :anim
  attr_accessor :charged
  attr_accessor :isShadow
  attr_accessor :over
  attr_accessor :cy
  attr_reader :loaded
  attr_reader :selected
  attr_reader :isSub
  attr_reader :viewport
  attr_reader :pulse
  attr_reader :pressed

  def initialize(doublebattle,index,viewport,player,enemy,altitude)
    @viewport=viewport
    @selected=0
    @frame=0
    @frame2=0
    @frame3=0
	@over = false
	@cy = -1
    @player=player
	@enemy=enemy
	@altitude=altitude
    @status=0
    @loaded=false
    @charged=false
    @index=index
    @doublebattle=doublebattle
    @showshadow=true
    @shadow=Sprite.new(@viewport)
    @sprite=Sprite.new(@viewport)
    @overlay=Sprite.new(@viewport)
	@overlay.bitmap=pbBitmap("_installer/editors/SpritePositioner/grabber")
	@overlay.ox=@overlay.bitmap.width/2
	@overlay.oy=@overlay.bitmap.height/2
    @isSub=false
    @lock=false
    @pokemon=nil
    @still=false
    @hidden=false
    @fainted=false
    @anim=false
    @isShadow=false
	@offset = Rect.new((Graphics.width - DEFAULTSCREENWIDTH)/2,(Graphics.height - DEFAULTSCREENHEIGHT)/2 -20,DEFAULTSCREENWIDTH,DEFAULTSCREENHEIGHT)
  end
  
  def battleIndex; return @index; end
  def x; @sprite.x; end
  def y; @sprite.y; end
  def z; @sprite.z; end
  def ox; @sprite.ox; end
  def oy; @sprite.oy; end
  def zoom_x; @sprite.zoom_x; end
  def zoom_y; @sprite.zoom_y; end
  def visible; @sprite.visible; end
  def opacity; @sprite.opacity; end
  def width; @bitmap.width; end
  def height; @bitmap.height; end
  def tone; @sprite.tone; end
  def bitmap; @bitmap.bitmap; end
  def actualBitmap; @bitmap; end
  def disposed?; @sprite.disposed?; end
  def color; @sprite.color; end
  def src_rect; @sprite.src_rect; end
  def blend_type; @sprite.blend_type; end
  def angle; @sprite.angle; end
  def mirror; @sprite.mirror; end
  def src_rect; return @sprite.src_rect; end
  def src_rect=(val)
    @sprite.src_rect=val
  end
  def lock
    @lock=true
  end
  def bitmap=(val)
    @bitmap.bitmap=val
  end
  def x=(val)
    @sprite.x=val
    @shadow.x=val
  end
  def ox=(val)
    @sprite.ox=val
    self.formatShadow
  end
  def addOx(val)
    @sprite.ox+=val
    self.formatShadow
  end
  def oy=(val)
    @sprite.oy=val
    self.formatShadow
  end
  def addOy(val)
    @sprite.oy+=val
    self.formatShadow
  end
  def y=(val)
    @sprite.y=val
    @shadow.y=val
  end
  def z=(val)
    @shadow.z=(val==32) ? 31 : 10
    @sprite.z=val
  end
  def zoom_x=(val)
    @sprite.zoom_x=val
    self.formatShadow
  end
  def zoom_y=(val)
    @sprite.zoom_y=val
    self.formatShadow
  end
  def visible=(val)
    return if @hidden
    @sprite.visible=val
    self.formatShadow
  end
  def opacity=(val)
    @sprite.opacity=val
    self.formatShadow
  end
  def tone=(val)
    @sprite.tone=val
  end
  def color=(val)
    @sprite.color=val
  end
  def blend_type=(val)
    @sprite.blend_type=val
    self.formatShadow
  end
  def angle=(val)
    @sprite.angle=(val)
    self.formatShadow
  end
  def mirror=(val)
    @sprite.mirror=(val)
    self.formatShadow
  end
  def dispose
    @sprite.dispose
    @shadow.dispose
	@overlay.dispose
  end
  def selected=(val)
    @selected=val
    @sprite.visible=true if !@hidden
  end
  def toneAll(val)
    @sprite.tone.red+=val
    @sprite.tone.green+=val
    @sprite.tone.blue+=val
  end
    
  def setPokemonBitmap(species,back=false,form=0)
	@species = species - 1
	@form = form
    scale = back ? BACKSPRITESCALE*2 : POKEMONSPRITESCALE
	folder = back ? "Back" : "Front"
	form = form==0 ? "" : "_#{form}"
	file = WORKING_DIRECTORY + sprintf("\\Graphics\\Battlers\\#{folder}\\%03d#{form}",species)
	
	@bitmap.dispose if @bitmap
	@sprite.bitmap.dispose if @sprite.bitmap
	@shadow.bitmap.dispose if @shadow.bitmap
    @bitmap = AnimatedBitmapWrapper.new(file,scale)

    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height
    self.refreshMetrics
    self.visible = true
    self.formatShadow
  end
  
  
  def refreshMetrics
    if (@index%2==0)
	  y = @player[@species][@form]
	  y *= 2
    else
      y = @enemy[@species][@form]
    end
	a = @altitude[@species][@form]
    
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height + a - y
  end
    
  def clear
    @sprite.bitmap.clear
    @bitmap.dispose
  end
  
  def formatShadow
    @shadow.zoom_x = @sprite.zoom_x*0.90
    @shadow.zoom_y = @sprite.zoom_y*0.30
    @shadow.ox = @sprite.ox - 6
    @shadow.oy = @sprite.oy - 6
    @shadow.opacity = @sprite.opacity*0.3
    @shadow.tone = Tone.new(-255,-255,-255,255)
    @shadow.visible = @sprite.visible
    @shadow.mirror = @sprite.mirror
    @shadow.angle = @sprite.angle
  end
  
  def update(angle=74)
    if @still
      @still = false
      return
    end
    return if @lock
    return if !@bitmap || @bitmap.disposed?
	if !(@over && $mouse.leftPress?)
	  @bitmap.update
	  @sprite.bitmap.dispose if @sprite.bitmap
	  @shadow.bitmap.dispose if @shadow.bitmap
	  @sprite.bitmap = @bitmap.bitmap.clone
	  @shadow.bitmap = @bitmap.bitmap.clone
	end
	if $mouse.over?(@offset) && ($mouse.overPixel?(@sprite) || $mouse.over?(@overlay)) && !$mouse.leftPress?
	  @over = true
	elsif !$mouse.leftPress?
	  @over = false
	end
	@pressed = @over && $mouse.leftPress?
    self.formatShadow
	@overlay.x = self.x
	@overlay.y = self.y - self.oy + self.height/2
  end  
  
  
end

class Vector
  attr_reader :x
  attr_reader :y
  attr_reader :angle
  attr_reader :scale
  attr_reader :x2
  attr_reader :y2
  attr_accessor :zoom1
  attr_accessor :zoom2
  attr_accessor :inc
  attr_accessor :set
  
  def initialize(x=0,y=0,angle=0,scale=1,zoom1=1,zoom2=1)
    @x=x.to_f
    @y=y.to_f
    @angle=angle.to_f
    @scale=scale.to_f
    @zoom1=zoom1.to_f
    @zoom2=zoom2.to_f
    @inc=0.2
    @set=[@x,@y,@scale,@angle,@zoom1,@zoom2]
    @locked=false
    @force=false
    @constant=1
    self.calculate
  end
  
  def calculate
    angle=@angle*(Math::PI/180)
    width=Math.cos(angle)*@scale
    height=Math.sin(angle)*@scale
    @x2=@x+width
    @y2=@y-height
  end
  
  def spoof(*args)
    if args[0].is_a?(Array)
      x,y,angle,scale,zoom1,zoom2 = args[0]
    else
      x,y,angle,scale,zoom1,zoom2 = args
    end
    angle=angle*(Math::PI/180)
    width=Math.cos(angle)*scale
    height=Math.sin(angle)*scale
    x2=x+width
    y2=y-height
    return x2, y2
  end
  
  def angle=(val)
    @angle=val
    self.calculate
  end
  
  def scale=(val)
    @scale=val
    self.calculate
  end
  
  def x=(val)
    @x=val
    @set[0]=val
    self.calculate
  end
  
  def y=(val)
    @y=val
    @set[1]=val
    self.calculate
  end
  
  def force
    @force = true
  end
  
  def reset(doublebattle=false)
    self.set(doublebattle ? VECTOR2 : VECTOR1)
  end
  
  def set(*args)
    return if DISABLESCENEMOTION && !@force
    @force = false
    if args[0].is_a?(Array)
      x,y,angle,scale,zoom1,zoom2 = args[0]
    else
      x,y,angle,scale,zoom1,zoom2 = args
    end
    @set=[x,y,angle,scale,zoom1,zoom2] 
    @constant=rand(4)+1
  end
  
  def add(field="",amount=0.0)
    case field
    when "x"
      @set[0]=@x+amount
    when "y"
      @set[1]=@y+amount
    when "angle"
      @set[2]=@angle+amount
    when "scale"
      @set[3]=@scale+amount
    when "zoom1"
      @set[4]=@zoom1+amount
    when "zoom2"
      @set[5]=@zoom2+amount
    end
  end
  
  def setXY(x,y)
    @set[0]=x
    @set[1]=y
  end
    
  def locked?
    return @locked
  end
  
  def lock
    @locked=!@locked
  end
  
  def update
    @x+=(@set[0]-@x)*@inc
    @y+=(@set[1]-@y)*@inc
    @angle+=(@set[2]-@angle)*@inc
    @scale+=(@set[3]-@scale)*@inc
    @zoom1+=(@set[4]-@zoom1)*@inc
    @zoom2+=(@set[5]-@zoom2)*@inc
    self.calculate
  end
  
  def finished?
    return ((@set[0]-@x)*@inc).abs <= 0.05*@constant
  end
  
end

def calculateCurve(x1,y1,x2,y2,x3,y3,frames=10)
  output=[]
  curve=[x1,y1,x2,y2,x3,y3,x3,y3]
  step=1.0/frames
  t=0.0
  frames.times do
    point=getCubicPoint2(curve,t)
    output.push([point[0],point[1]])
    t+=step
  end
  return output
end

def singleDecInt?(number)
  number*=10
  return (number%10==0)
end