require "dir.TLfres.lua"
require 'strong.strong'
require 'dir.AnAl.lua'
Timer = require "hump.timer"
tween = require "dir.tween"

function love.load()
	T = 0
	tt = 0
	word_count = 0
	delay = true
	vel = {v1 = 0.0, v2 = 0.0 }
	bgm = love.audio.newSource("audio/bgm.ogg", "stream") -- make 0
	p_coin = love.audio.newSource("audio/positive.ogg", "static") -- make 1
	n_coin = love.audio.newSource("audio/negative.ogg", "static") -- make 2
	death = love.audio.newSource("audio/death.ogg", "static") -- make 3
	crash = love.audio.newSource("audio/death.wav", "static") -- make 4
	love.audio.setVolume(0.0)
	mode = {w=800, h=600, full=true, vsync=false, aa=0} -- fulscreen or not, change
	TLfres.setScreen(mode, 800, 600, true, false)
	image = love.graphics.newImage('assets/wheel.png')
	bkground = love.graphics.newImage('assets/cloud.png')
	img1 = love.graphics.newImage('assets/b.png')
	img2 = love.graphics.newImage('assets/r.png')
	mute = love.graphics.newImage('assets/mute.png')
	unmute = love.graphics.newImage('assets/unmute.png')
	blife = love.graphics.newImage('assets/blife.png')
	rlife = love.graphics.newImage('assets/rlife.png')
	begin = love.graphics.newImage('assets/love_logo.png') -- change logo
	anim1 = newAnimation(img1, 63, 96, 0.2, 0)
	anim1:setMode("loop")
	love.graphics.setBackgroundColor(0,0,0)
	anim2 = newAnimation(img2, 63, 96, 0.2, 0)
	--jump1 = newAnimation(img, 63, 96, 0.2, 0)
	--jump2 = newAnimation(img, 63, 96, 0.2, 0)
	anim2:setMode("loop")
	love.keyboard.setKeyRepeat(0, 2000)
	ff = love.graphics.newFont('assets/Brutality.ttf', 20 ) 
	sf = love.graphics.newFont('assets/Brutality.ttf', 24 ) 
	screenshot = love.image.newImageData(800,600)
	msg = "The next game will begin in 5 seconds." -- change message, opening
	--file = love.filesystem.newFile('contents/data.txt')
	--file:open('w')
	word = {}
	sign = {}
	lists = {}
	assign()
end

function init()
	p1_life = 3
	p2_life = 3
	Timer.add(2,function() comp = true end )
	tt = 0
	T = love.timer.getTime()
	love.audio.play(bgm)
	bgm:setLooping(true)
	math.randomseed(os.time())
	player1_pos = "Player1:POSITIVE - "
	player1_neg = "Player1:NEGATIVE - "
	player2_pos = "Player2:POSITIVE - "
	player2_neg = "Player2:NEGATIVE - "
	vel = {v1 = 0.3, v2 = 0.3 }
	score = 0
	string_ = " "
	status = " "
	over = false
	temp = 0
	counter = 0
	ax1 = -28
	ay1 = -185
	ax2 = 32
	ay2 = 193
	n1=0
	n2=0
	d1 =0
	d2 = 0
	word_count = 0
	label1 = {x=0,y=0,d=0,text=""}
	label2 = {x=0,y=0,d=0,text=""}
end

function reset()
	tt = love.timer.getTime()
	vel = {v1 = 0.3, v2 = 0.3 }
	timestamp = os.clock()
end

function collide()
	x1 = 100 * math.sin(dQ1)
	y1 = -100 * math.cos(dQ1)
	x2 = 100 * math.sin(-dQ2)
	y2 = 100 * math.cos(dQ2)
	if math.abs(x1-x2) < 10 and math.abs(y1-y2) < 10  and over==false  then
		love.audio.play(crash)
		life()
		if p1_life == 0 or p2_life == 0 then
			bgm:stop()
			love.audio.play(death)
			score = math.ceil(math.max(vel.v1,vel.v2) * 100 + love.timer.getTime() - T)
			status = ""
			--Timer.add(0.01, function() screenshot = love.graphics.newScreenshot(); sshot = love.graphics.newImage( screenshot ); over = true;	end)
			over = true
			data = love.filesystem.read('log.txt')
			if p1_life > 0 then
				success = love.filesystem.write('log.txt',data..'\n'..player1_pos..'\t'..player1_neg)
			else
				success = love.filesystem.write('log.txt',data..'\n'..player2_pos..'\n'..player2_neg)
			end
			Timer.clear()
			-- Timer.add(10, function() love.event.push('r') end)
			Timer.add(5,function() bgm:stop() delay = true assign() reset() end)		--restart start screen after 5 seconds
		end
	end
end

function life()
	if ( vel.v1 > vel.v2 ) and n2 == vel.v2 then
		p2_life = p2_life - 1
			if p2_life > 0 then
				reset()
				assign()
			end
	elseif ( vel.v1 < vel.v2 ) and n1 == vel.v1 then
		p1_life = p1_life - 1
			if p1_life > 0 then
				reset()
				assign()
			end
	elseif n1 > vel.v1 then
		p2_life = p2_life - 1
			if p2_life > 0 then
				reset()
				assign()
			end
	else
		p1_life = p1_life - 1
			if p1_life > 0 then
				reset()
				assign()
			end
	end
end

function assign()
	wc = 1
	word_count = 0
	for line in love.filesystem.lines('contents/words.txt') do
		str =""
		for c in (line):chars() do
			if c ~= "+" and c ~= "-" then
				str = str..c
			elseif c=="+" then
				sign[wc] = 0
			elseif c=="-" then
				sign[wc] = 1
			end 
		end
		word[wc] = str
		wc = wc + 1
	end
	for l=1,30 do
		list = {}
		f = 0
		list.d = word[l]
		list.f = love.graphics.newFont('assets/Brutality.ttf', math.random(20,30))
		list.s = sign[l] 	-- sign of the constant to be deducted or added. 1 denotes subtract and 0 denotes add
		list.x, list.y, list.th = position(l)
		table.insert(lists, list)
	end
end

function position(index)
	if(math.random(0,1) > 0 ) then
			loc_x = math.random(0,6) * 78.33 - 230			--x co-ordinates of the word
			loc_y = math.abs(math.sqrt(55225 - loc_x ^ 2)) --y co-ordinates of the word
			if(math.random(1,10)%2 == 0) then loc_y = loc_y * (-1) end
			loc_th = 2 * math.atan2(loc_y + 235, loc_x) --theta
		else
			loc_x = math.random(0,7) * 78.57 - 275 			--x co-ordinates of the word
			loc_y = math.abs(math.sqrt(75625 - loc_x ^ 2)) --y co-ordinates of the word
			if(math.random(1,10)%2 == 0) then loc_y = loc_y * (-1) end
			loc_th = 2 * math.atan2(loc_y + 275, loc_x) --theta
	end
	for j,z in ipairs(lists) do
			if z.x == loc_x and z.y == loc_y then
				position(index)
				break
			end
	end
	return loc_x, loc_y, loc_th
end

function love.update(dt)
	anim1:update(dt)
	anim2:update(dt)
	Timer.update(dt)
	tween.update(dt)
	time_elapsed = love.timer.getTime() - tt;
	dQ1 = ((vel.v1 * time_elapsed)) 
	dQ2 = ((vel.v2 * time_elapsed))
	slow = (0.1 * time_elapsed)/10
	collide()
	if comp == true and delay == false then
		AI()
	end	
	if word_count > 20 then
		assign()
	end	
end

function jump(k)
	if k == 1 then
		d1 = dQ1 % (2 * math.pi)
		for i,v in ipairs(lists) do
			if math.abs(d1 - v.th) < 0.2  and v.x~=0 and v.y~=0 and over ==false then
				word_count= word_count + 1
				if(sign[i] == 0) then
					n1 = math.min(math.max(vel.v1 + ((math.random(5,20)/100) * vel.v1), 0.1),0.5)
					player1_pos = player1_pos..word[i]..'\n'
					love.audio.play(p_coin)
					--status = "Hey Blue ! Great going !"
				elseif (sign[i] == 1) then
					n1 = math.min(math.max(vel.v1 - ((math.random(5,20)/100) * vel.v1), 0.1),0.5)
					player1_neg = player1_neg..word[i]..'\n'
					love.audio.play(n_coin)
					--status = "Ohh Blue ! Wrong choice mate!"
				end				
				label1 = { x=v.x, y=v.y, d=v.th, text = word[i] }
				word[i]= ""
				v.s = 2
				v.x = 0
				v.y = 0
				v.th = 0
				tween.start(2,label1,{y=0,x=0}, 'inQuint')
				tween.start(1,vel,{v1 = n1}, 'linear')
				table.remove(v)
				Timer.add(2,function() label1.text="" end)
				break
			end	
		end

	else
		d2 = (dQ2 + math.pi)%(2 * math.pi)
		for i,v in ipairs(lists) do
			if math.abs(d2 - v.th ) < 0.3 and v.x~=0 and v.y~=0 and over ==false then
				word_count= word_count + 1
				label2 = { x=v.x, y=v.y, d=v.th, text = word[i] }
				if(sign[i] == 0) then
					n2 = math.min(math.max(vel.v2 + ((math.random(5,20)/100) * vel.v2), 0.1),0.5)
					player2_pos = player2_pos..word[i]..'\n'
					love.audio.play(p_coin)
					--status = "Hey Red ! Great going !"
				elseif (sign[i] == 1) then
					n2 = math.min(math.max(vel.v2 - ((math.random(5,20)/100) * vel.v2), 0.1),0.5)
					player2_neg = player2_neg..word[i]..'\n'
					love.audio.play(n_coin)
					--status = "Ohh Red ! Wrong choice mate!"
				end
				word[i]= ""
				v.s = 2
				v.x = 0
				v.y = 0
				v.th = 0
				tween.start(2,label2,{y=0,x=0}, 'inQuint')
				Timer.add(5,function() label2.text="" end)
				tween.start(2,vel,{v2 = n2}, 'linear')
				table.remove(v)
				break
			end	
		end
	end
end

function love.draw()
	TLfres.transform()
	if delay == true then
		start()
	else
		love.graphics.draw(bkground,-400,-300)
		love.graphics.setFont(ff)
		if love.audio.getVolume() == 0 then
			-- love.graphics.draw(mute,-400,-300)
		else
			-- love.graphics.draw(unmute,-400,-300)
		end
		love.graphics.setColor(0,0,0)
		love.graphics.print(string_, -350, -300)
		if over == true then
			if counter == 0 then
				--love.graphics.clear()
				counter = 1
			else
				love.graphics.setColor(255,255,255)
				--love.graphics.draw(sshot, -400, -300)
				love.graphics.setColor(0,0,0)
				love.graphics.print("Game over!", -60, -60)
				if (p2_life == 0) then
					love.graphics.print("You win.", -75, 0)
					--scores()
					love.graphics.setColor(100,100,100)
					--love.graphics.print(player2_pos, -400, -200)
					--love.graphics.print(player2_neg, 300, -200)
				else
					love.graphics.print("Computer wins.", -75, 0)
					--scores()
					love.graphics.setColor(100,100,100)
					--love.graphics.print(player1_pos, -400, -200)
					--love.graphics.print(player1_neg, 300, -200)
				end
				love.graphics.setColor(255,255,255)
			end
		else
			love.graphics.setColor(0,0,0)
			-- Time()
			love.graphics.setColor(100,100,100)
			love.graphics.print(status,-400,275)
			love.graphics.setColor(13, 34, 114)
			love.graphics.rectangle("fill",400 - vel.v1*200, -297,vel.v1*200, 15)
			-- love.graphics.print("YOU:", 200,-300)
			love.graphics.setColor(255, 255, 255)
			for w=1,p1_life do
				love.graphics.draw(blife,-310 - 25*w,-300)
			end
			love.graphics.setColor(193, 47, 14)
			love.graphics.rectangle("fill",400 - vel.v2*200, -272,vel.v2*200, 15)
			-- love.graphics.print("CPU:", 200,-275)
			love.graphics.setColor(255, 255, 255)
			for w=1,p2_life do
				love.graphics.draw(rlife,-310 - 25*w,-275)
			end
			love.graphics.setColor(255,255,255)
			love.graphics.rotate(slow)
			for  i,v in ipairs(lists) do
				if math.abs(v.th - 4.712388) < 0.01 then
				else
				love.graphics.setFont(v.f)
				love.graphics.print(tostring(word[i]), v.x, v.y, v.th)
				end
			end
			love.graphics.setColor(255,0,0)
			love.graphics.print(label1.text,label1.x,label1.y,label1.d)
			love.graphics.print(label2.text,label2.x,label2.y,label2.d)
			love.graphics.setColor(255,255,255)
			love.graphics.draw(image, -100, -100)			
			disp()
		end			
	end
	--TLfres.letterbox(4, 3)
end

function Time()
	run_time = math.ceil(love.timer.getTime() - T)
	if run_time % 60 < 10 then
		time_format = '0'..math.floor(run_time/60)..':0'..(run_time % 60)
	else
		time_format = '0'..math.floor(run_time/60)..':'..(run_time % 60)
	end
	love.graphics.print(time_format,-260,-275)
end

--[[function scores()
	for s=1,score do
	love.graphics.clear()
	love.graphics.print(tostring(s), -50, 30)
	end
end]]--

function start()
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(sf)
	love.graphics.draw(begin,-256,-228) -- change image. love logo. 
	love.graphics.print(msg,-256, 0)
	if delay == true then
		Timer.add(5,function() delay = false init() reset() end)
	end
end

function disp()
		love.graphics.rotate(dQ1)
		anim1:draw(ax1, ay1)
		love.graphics.rotate(dQ2 - dQ1)
		anim2:draw(ax2, ay2, 3.14)
end

function love.keypressed(key, unicode)
	if key == "q" then
		love.event.push('q')
	end
	
	if key == "1" then
		if delay == false then
			ax1 = -30
			ay1 = -260
			Timer.add(0.3, function() ax1 = -30	ay1 = -185  --[[anim1:play() ]] end)
			--anim1:stop()
			--jump1:play()
			jump(1)
		end
	end
	
	if key == 'm' then
		if delay == false then
			v = love.audio.getVolume()
			love.audio.setVolume(math.abs(v - 1.0))
		end
	end
	
	if key == 'r' then -- for restart
		bgm:stop()
		delay = true
		assign()
	end
end

function AI()
	comp = false
	Timer.clear()
	d2 = (dQ2 + math.pi)%(2 * math.pi)
		for i,v in ipairs(lists) do
			if math.abs(d2 - v.th ) < 0.3 and v.x~=0 and v.y~=0 and vel.v2 < vel.v1 + 0.05 then
				ax2 = 30
				ay2 = 260
				Timer.add(0.3, function() ax2 = 30	ay2 = 185 --[[ anim2:play() ]]end)
				--anim2:stop()
				--jump1:play()
				jump(2)
				break
			end	
		end
	Timer.add(4, function() comp = true end)	
end