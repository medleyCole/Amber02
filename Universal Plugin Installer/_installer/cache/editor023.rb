class UPI_SpritePositioner

	def initialize
		temp = Graphics.snap_to_bitmap
		@pokemon = []
		@enemyY = []
		@playerY = []
		@altitude = []
		@formNames = []
		@index = 0
		@curindex = 0
		@click = 0
		@search_string = ""
		@buffer = ""
		@form = 0
		@press = false
		@close = false
		self.evalRequired
		self.readPBS
		@vector = Vector.new(*VECTOR1)
		@offset = Rect.new((Graphics.width - 512)/2,(Graphics.height - 384)/2 -20,512,384)
		
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 500
		@viewport2 = Viewport.new(@offset.x,@offset.y,512,384)
		@viewport2.z = 500
		@viewport3 = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport3.z = 600
		
		@sprites = {}
		@sprites["transition"] = Sprite.new(@viewport3)
		@sprites["transition"].bitmap = temp
		@sprites["transition"].z = 99999
		
		# backdrop
		@sprites["bg"] = Sprite.new(@viewport)
		@sprites["bg"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		# battle background
		bg = pbBitmap(WORKING_DIRECTORY+"\\Graphics\\Battlebacks\\battlebg\\Field")
		@sprites["bg"].bitmap.stretch_blt(Rect.new(0,0,Graphics.width,Graphics.height),bg,bg.rect)
		# enemy base
		base = pbBitmap(WORKING_DIRECTORY+"\\Graphics\\Battlebacks\\enemybase\\FieldDirt")
		@sprites["bg"].bitmap.stretch_blt(Rect.new(@vector.x2+@offset.x-base.width/2,@vector.y2+@offset.y-base.height/2,base.width,base.height),base,base.rect)
		# player base
		base = pbBitmap(WORKING_DIRECTORY+"\\Graphics\\Battlebacks\\playerbase\\FieldDirt")
		@sprites["bg"].bitmap.stretch_blt(Rect.new(@vector.x+@offset.x-base.width/2,@vector.y+@offset.y-base.height/2,base.width,base.height),base,base.rect)
		#Rect.new(@offset.x,@offset.y,DEFAULTSCREENWIDTH,DEFAULTSCREENHEIGHT)
		
		# altitude slider
		@sprites["slider"] = Sprite.new(@viewport3)
		@sprites["slider"].bitmap = pbBitmap("_installer/editors/SpritePositioner/scroll")
		@sprites["slider"].ox = @sprites["slider"].bitmap.width/2
		@sprites["slider"].oy = 16
		@sprites["slider"].y = 297
		@sprites["slider"].x = 31
		@sprites["slider"].z = 10
		
		# name
		@sprites["name"] = Sprite.new(@viewport3)
		@sprites["name"].bitmap = Bitmap.new(320,32)
		@sprites["name"].bitmap.setFont(22,true)
		@sprites["name"].x = @offset.x
		@sprites["name"].y = @offset.y
				
		# enemy pokemon
		@sprites["pokemon1"] = DynamicPokemonSprite.new(false,1,@viewport,@playerY,@enemyY,@altitude)
		@sprites["pokemon1"].x = @vector.x2 + @offset.x
		@sprites["pokemon1"].y = @vector.y2 + @offset.y
		@sprites["pokemon1"].color = Color.new(255,255,255,0)
		
		# player pokemon
		@sprites["pokemon0"] = DynamicPokemonSprite.new(false,0,@viewport,@playerY,@enemyY,@altitude)
		@sprites["pokemon0"].x = @vector.x + @offset.x
		@sprites["pokemon0"].y = @vector.y + @offset.y
		@sprites["pokemon0"].color = Color.new(255,255,255,0)
		self.refreshSprites
		
		# search field
		@sprites["search"] = Sprite.new(@viewport3)
		@sprites["search"].z = 500
		@sprites["search"].bitmap = pbBitmap("_installer/editors/SpritePositioner/search")
		@sprites["search"].x = 14
		@sprites["search"].y = 436
		
		@sprites["break"] = Sprite.new(@viewport3)
		@sprites["break"].z = 500
		@sprites["break"].bitmap = pbBitmap("break")
		@sprites["break"].x = @sprites["search"].x + 190
		@sprites["break"].y = @sprites["search"].y + 10
		@sprites["break"].opacity = 155
		
		@sprites["entry"] = Window_TextEntry_Keyboard.new("",@sprites["search"].x + 22,@sprites["search"].y-40,168,96,"",true)
		@sprites["entry"].viewport = @viewport3
		@sprites["entry"].visible = true
		@sprites["entry"].opacity = 0
		@sprites["entry"].maxlength = -1
		@sprites["entry"].refresh(false)
		@sprites["entry"].z = 500
		
		# ui border
		@sprites["border"] = Sprite.new(@viewport3)
		@sprites["border"].bitmap = pbBitmap("_installer/editors/SpritePositioner/border")
		
		# scrollbar
		@sprites["scrollbar"] = ScrollBar.new(@viewport3,24,1..@pokemon.length)
		@sprites["scrollbar"].x = 606
		@sprites["scrollbar"].y = 54
		@sprites["scrollbar"].refresh(24)
		
		# tooltip
		@sprites["tooltip"] = Sprite.new(@viewport3)
		@sprites["tooltip"].z = 5000
		@sprites["tooltip"].bitmap = Bitmap.new(320,28)
		@sprites["tooltip"].visible = false
		
		# ui buttons
		@sprites["forms"] = Sprite.new(@viewport3)
		@sprites["forms"].bitmap = pbBitmap("_installer/editors/SpritePositioner/b_forms")
		@sprites["forms"].ox = @sprites["forms"].bitmap.width/2
		@sprites["forms"].oy = @sprites["forms"].bitmap.height/2
		@sprites["forms"].x = 300
		@sprites["forms"].y = 454
		@sprites["forms"].visible = false
		
		@sprites["apply"] = Sprite.new(@viewport3)
		@sprites["apply"].bitmap = pbBitmap("_installer/editors/SpritePositioner/b_apply")
		@sprites["apply"].ox = @sprites["apply"].bitmap.width/2
		@sprites["apply"].oy = @sprites["apply"].bitmap.height/2
		@sprites["apply"].x = 384
		@sprites["apply"].y = 454
		@sprites["apply"].visible = false
		
		@sprites["save"] = Sprite.new(@viewport3)
		@sprites["save"].bitmap = pbBitmap("_installer/editors/SpritePositioner/b_save")
		@sprites["save"].ox = @sprites["save"].bitmap.width/2
		@sprites["save"].oy = @sprites["save"].bitmap.height/2
		@sprites["save"].x = 512 - 32
		@sprites["save"].y = 454
		
		@sprites["exit"] = Sprite.new(@viewport3)
		@sprites["exit"].bitmap = pbBitmap("_installer/editors/SpritePositioner/b_exit")
		@sprites["exit"].ox = @sprites["exit"].bitmap.width/2
		@sprites["exit"].oy = @sprites["exit"].bitmap.height/2
		@sprites["exit"].x = 578 - 32
		@sprites["exit"].y = 454
		
		self.update
		self.main		
	end
	# main function with the main loop
	def main
		16.times do
			@sprites["transition"].opacity -= 16
			Graphics.update
		end
		loop do
			break if @close
			Graphics.update
			Input.update
			self.update
		end
		16.times do
			@sprites["transition"].opacity += 16
			Graphics.update
		end
		self.dispose
	end
	# displays a tooltip next to the cursor
	def tooltip(text)
		@sprites["tooltip"].bitmap.clear
		@sprites["tooltip"].bitmap.setFont(18,true)
		w = @sprites["tooltip"].bitmap.text_size(text).width + 18
		@sprites["tooltip"].bitmap.fill_rect(0,0,w,28,Color.new(105,105,105))
		@sprites["tooltip"].bitmap.fill_rect(1,1,w-2,26,Color.new(255,255,255))
		t = [[text,w/2,5,2,Color.new(105,105,105),nil]]
		pbDrawTextPositions(@sprites["tooltip"].bitmap,t)
		@sprites["tooltip"].visible = true
	end
	# refreshes the loaded Pokemon sprites
	def refreshSprites
		@sprites["name"].bitmap.clear
		@sprites["name"].bitmap.fill_rect(0,0,320,32,Color.new(0,0,0,85))
		name = @pokemon[@index].downcase.capitalize
		name += " (#{@formNames[@index][@form]})" if @formNames[@index][@form] != ""
		t = [[name,160,4,2,Color.new(255,255,255),nil]]
		pbDrawTextPositions(@sprites["name"].bitmap,t)
		@sprites["pokemon0"].setPokemonBitmap(@index+1,true,@form)
		@sprites["pokemon1"].setPokemonBitmap(@index+1,false,@form)
		@sprites["slider"].y = 297 - @altitude[@index][@form]*2
	end
	# main update for the scene
	def update
		# tooltip
		@sprites["tooltip"].visible = false
		@sprites["tooltip"].x = $mouse.x + 4
		@sprites["tooltip"].y = $mouse.y - 32
		# current index
		if @curindex != @index
			@curindex = @index
			@sprites["scrollbar"].index = @index + 1
			@form = 0
			self.refreshSprites
		end
		# scrollbar
		scroll = @sprites["scrollbar"].update - 1
		@index = scroll if @index != scroll
		# sprite updates
		@sprites["pokemon0"].refreshMetrics
		@sprites["pokemon0"].update
		@sprites["pokemon1"].refreshMetrics
		@sprites["pokemon1"].update
		# player pokemon
		if @sprites["pokemon0"].over && !@sprites["pokemon1"].over && !@press && !@sprites["scrollbar"].pressed
			@sprites["pokemon0"].color.alpha += 16 if @sprites["pokemon0"].color.alpha < 128
			self.tooltip("#{@playerY[@index][@form]}")
			if $mouse.leftPress?
				@sprites["pokemon0"].cy = $mouse.y - @playerY[@index][@form]*2 if @sprites["pokemon0"].cy < 0
				@playerY[@index][@form] = ($mouse.y - @sprites["pokemon0"].cy)/2 if @sprites["pokemon0"].cy > -1
			else
				@sprites["pokemon0"].cy = -1
			end
		else
			@sprites["pokemon0"].color.alpha -= 16 if @sprites["pokemon0"].color.alpha > 0
			@sprites["pokemon0"].cy = -1
		end
		# enemy pokemon
		if @sprites["pokemon1"].over && !@sprites["pokemon0"].over && !@press && !@sprites["scrollbar"].pressed
			@sprites["pokemon1"].color.alpha += 16 if @sprites["pokemon1"].color.alpha < 128
			self.tooltip("#{@enemyY[@index][@form]}")
			if $mouse.leftPress?
				@sprites["pokemon1"].cy = $mouse.y - @enemyY[@index][@form] if @sprites["pokemon1"].cy < 0
				@enemyY[@index][@form] = $mouse.y - @sprites["pokemon1"].cy if @sprites["pokemon1"].cy > -1
			else
				@sprites["pokemon1"].cy = -1
			end
		else
			@sprites["pokemon1"].color.alpha -= 16 if @sprites["pokemon1"].color.alpha > 0
			@sprites["pokemon1"].cy = -1
		end
		# altitude slider
		if (!@sprites["pokemon1"].pressed && !@sprites["pokemon0"].pressed && !@sprites["scrollbar"].pressed) && $mouse.over?(@sprites["slider"]) || @press
			self.tooltip("altitude")
			if $mouse.leftPress? || @press
				@press = true
				@sprites["slider"].y = $mouse.y - @sprites["slider"].ey
				@sprites["slider"].y = 157+16 if @sprites["slider"].y < 157+16
				@sprites["slider"].y = 297 if @sprites["slider"].y > 297
				@altitude[@index][@form] = (297 - @sprites["slider"].y)/2
			end
		else
			@sprites["slider"].ey = $mouse.y - @sprites["slider"].y
		end
		@press = false if !$mouse.leftPress?
		# search bar update
		if !@sprites["pokemon0"].pressed && !@sprites["pokemon1"].pressed
		    if $mouse.over?(@sprites["break"])
			    if $mouse.leftClick?
			        @sprites["entry"].text = ""
			        @sprites["entry"].refresh(false)
			    end
		    end
		end
		@sprites["entry"].update
		if $mouse.over?(@sprites["break"])
		    @sprites["break"].opacity += 10 if @sprites["break"].opacity < 255
		else
		    @sprites["break"].opacity -= 10 if @sprites["break"].opacity > 155
		end
		# ui buttons
		# form change
		@sprites["forms"].visible = @formNames[@index].length > 1
		if @sprites["forms"].visible && (!@sprites["pokemon1"].pressed && !@sprites["pokemon0"].pressed && !@sprites["scrollbar"].pressed && !@press)
			if $mouse.over?(@sprites["forms"])
				self.tooltip("change form")
				if $mouse.click?
					self.bounce(@sprites["forms"])
					@form += 1
					@form = 0 if @form >= @formNames[@index].length
					self.refreshSprites
				end
			end
		end
		# apply to all forms
		@sprites["apply"].visible = @formNames[@index].length > 1
		if @sprites["apply"].visible && (!@sprites["pokemon1"].pressed && !@sprites["pokemon0"].pressed && !@sprites["scrollbar"].pressed && !@press)
			if $mouse.over?(@sprites["apply"])
				self.tooltip("apply to all forms")
				if $mouse.click?
					self.bounce(@sprites["apply"])
					val1 = @enemyY[@index][@form]
					val2 = @playerY[@index][@form]
					val3 = @altitude[@index][@form]
					for j in 0...@formNames[@index].length
						next if j == @form
						@enemyY[@index][j] = val1
						@playerY[@index][j] = val2
						@altitude[@index][j] = val3
					end						
				end
			end
		end
		# save metrics
		if (!@sprites["pokemon1"].pressed && !@sprites["pokemon0"].pressed && !@sprites["scrollbar"].pressed && !@press)
			if $mouse.over?(@sprites["save"])
				self.tooltip("save metrics")
				if $mouse.click?
					self.bounce(@sprites["save"])
					self.savePBS					
				end
			end
		end
		# save metrics and exit
		if (!@sprites["pokemon1"].pressed && !@sprites["pokemon0"].pressed && !@sprites["scrollbar"].pressed && !@press)
			if $mouse.over?(@sprites["exit"])
				self.tooltip("save & exit")
				if $mouse.click?
					self.bounce(@sprites["exit"])
					self.savePBS
					@close = true
				end
			end
		end
		# force to refresh package
		if @search_string != @sprites["entry"].text
		    @search_string = @sprites["entry"].text.clone
			poke = @search_string
			if poke.numeric?
				@index = poke.to_i - 1 if poke.to_i > 0 && poke.to_i <= @pokemon.length
			else
				poke = @search_string.upcase
				@index = @pokemon.index(poke) if @pokemon.include?(poke)
			end
		end
		# change index using arrow keys
		@index += 1 if @index < @pokemon.length - 1 && Input.repeat?(Input::DOWN)
		@index -= 1 if @index > 0 && Input.repeat?(Input::UP)
	end
	# evals additional scripts from the main project
	def evalRequired
		for script in ["Settings"]
			next if !scriptExists?(script)
			eval(getSpecificScript(script))
		end
		file = "_installer/editors/SpritePositioner/helper.rb"
		f = File.open(file,'rb')
		r = f.read; f.close
		if !r.include?("# script updated 1.0")
			r = Downloader.toString("editors/positioner/helper.rb")
			File.open(file,'wb') {|f| f.write(r) }			
		end
		eval(r)
	end
	# reads PBS data
	def readPBS
		pokemon = WORKING_DIRECTORY + "\\PBS\\pokemon.txt"
		forms = WORKING_DIRECTORY + "\\PBS\\pokemonforms.txt"
		@chunks = []
		
		k = -1
		# interprets data in chunks
		File.open(pokemon,'rb') {|f|
			lines = f.read.split("\r\n")
			for line in lines
				next if line.include?("#--")
				s = line[/\[.*?\]/]
				if !s.nil?
					k += 1
					@chunks.push([])
				else
					@chunks[k].push(line)
				end
			end
		}
		for chunk in @chunks
			added = [false,false,false]
			for line in chunk
				@pokemon.push(line.split("=")[1]) if line.include?("InternalName")
				@formNames.push([""]) if line.include?("InternalName")
				if line.include?("BattlerEnemyY")
					added[0] = true
					@enemyY.push([line.split("=")[1].to_i])
				end
				if line.include?("BattlerPlayerY")
					added[1] = true
					@playerY.push([line.split("=")[1].to_i])
				end
				if line.include?("BattlerAltitude")
					added[2] = true
					@altitude.push([line.split("=")[1].to_i])
				end
			end
			if !added[0]
				chunk.insert(chunk.length-1,"BattlerEnemyY=0")
				@enemyY.push([0])
			end
			if !added[1]
				chunk.insert(chunk.length-1,"BattlerPlayerY=0")
				@playerY.push([0])
			end
			if !added[2]
				chunk.insert(chunk.length-1,"BattlerAltitude=0")
				@altitude.push([0])
			end
		end
		
		poke = ""
		File.open(forms,'rb') {|f|
			lines = f.read.split("\r\n")
			for line in lines
				i = -1
				s = line[/\[.*?\]/]
				if !s.nil?
					poke = (s.gsub("[","").gsub("]","")).split("-")[0] 
					added = [false,false,false,false]
				end
				i = @pokemon.index(poke) if @pokemon.include?(poke)
				if i >= 0
					# adds form data
					if line.include?("BattlerEnemyY")
						@enemyY[i].push(line.split("=")[1].to_i) 
						added[0] = true
					end
					if line.include?("BattlerPlayerY")
						@playerY[i].push(line.split("=")[1].to_i)
						added[1] = true
					end
					if line.include?("BattlerAltitude")
						@altitude[i].push(line.split("=")[1].to_i)
						added[2] = true
					end
					if line.include?("FormName")
						@formNames[i].push(line.split("=")[1])
						added[3] = true
					end
					if line.include?("#-----") || line == lines[lines.length-1]
						@enemyY[i].push(@enemyY[i][0]) unless added[0]
						added[0] = true unless added[0]
						@playerY[i].push(@playerY[i][0]) unless added[1]
						added[1] = true unless added[1]
						@altitude[i].push(@altitude[i][0]) unless added[2]
						added[2] = true unless added[2]
						@formNames[i].push("") unless added[3]
						added[3] = true unless added[3]
					end
				end
			end
		}
	end
	# saves PBS data
	def savePBS
		time = Time.now
		pokemon = WORKING_DIRECTORY + "\\PBS\\pokemon.txt"
		forms = WORKING_DIRECTORY + "\\PBS\\pokemonforms.txt"
		# pokemon.txt
		edited = ""
		# grabs the lines from the PBS file
		f = File.open(pokemon,'rb'); lines = f.read.split("\r\n"); f.close
		# creates blank file
		File.open(pokemon,'wb') {|f| f.write("") }
		# processes lines and writes to file
		f = File.open(pokemon,'ab')
		for i in 0...@chunks.length
			chunk = @chunks[i]
			f.write("#-------------------------------\r\n")
			f.write("[#{i+1}]\r\n")
			for line in chunk
				s = line.clone
				if i >= 0
					s = "BattlerEnemyY=#{@enemyY[i][0].to_s}" if line.include?("BattlerEnemyY")
					s = "BattlerPlayerY=#{@playerY[i][0].to_s}" if line.include?("BattlerPlayerY")
					s = "BattlerAltitude=#{@altitude[i][0].to_s}" if line.include?("BattlerAltitude")
				end
				f.write(s + "\r\n")
				# prevents script from hanging
				if Time.now > time + 5
					time = Time.now
					Graphics.update
				end
			end
		end
		# save edited to file
		f.close
		Graphics.update
		# pokemonforms.txt
		groups = []
		added = nil?
		poke = ""
		File.open(forms,'rb') {|f|
			lines = f.read.split("\r\n")
			for line in lines
				if line.include?("#-----")
					groups.push(added) if !added.nil?
					added = []
				end
				added.push(line)
				groups.push(added) if line == lines[lines.length-1]
				# prevents script from hanging
				if Time.now > time + 5
					time = Time.now
					Graphics.update
				end
			end
		}
		groups.uniq!
		edited = ""
		for lines in groups
			next if !lines.is_a?(Array)
			for line in lines
				if line.include?("[") && line.include?("]")
					poke = line.gsub("[","").gsub("]","").split("-")[0]
					f = line.gsub("[","").gsub("]","").split("-")[1].to_i
					i = @pokemon.index(poke) if @pokemon.include?(poke)
					added = [false,false,false]
				end
				s = line.clone
				if line.include?("BattlerEnemyY")
					s = "BattlerEnemyY=#{@enemyY[i][f].to_s}"
					added[0] = true
				end
				if line.include?("BattlerPlayerY")
					s = "BattlerPlayerY=#{@playerY[i][f].to_s}"
					added[1] = true
				end
				if line.include?("BattlerAltitude")
					s = "BattlerAltitude=#{@altitude[i][f].to_s}"
					added[2] = true
				end
				edited += s + "\r\n"
				if line == lines[lines.length-1]
					edited += "BattlerEnemyY=#{@enemyY[i][f].to_s}\r\n" if !added[0]
					edited += "BattlerPlayerY=#{@playerY[i][f].to_s}\r\n" if !added[1]
					edited += "BattlerAltitude=#{@altitude[i][f].to_s}\r\n" if !added[2]
				end
				# prevents script from hanging
				if Time.now > time + 5
					time = Time.now
					Graphics.update
				end
			end
		end
		# save edited to file
		File.open(forms,'wb') {|f| f.write(edited) }
		Graphics.update
	end
	# dispose of class
	def dispose
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
		@viewport2.dispose
		@viewport3.dispose
	end
	# bounce animation for buttons
    def bounce(sprite)
		for i in 0...8
		    z = i < 4 ? 0.02 : -0.02
		    sprite.zoom_x -= z
		    sprite.zoom_y -= z
		    Graphics.update
		end
    end
end