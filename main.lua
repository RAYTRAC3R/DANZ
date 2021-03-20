Gamestate = require "hump.gamestate"
Levelsys = require "level"
json = require "depend.json"

local menu = {} -- previously: Gamestate.new()
local danzsongs = {}
local levelface = {}

BUTTON_HEIGHT = 64

function newButton(text, fn)
	return {
		text = text,
		fn = fn,
		
		now = false,
		last = false
	}
end

function newLevelButton(text, songlevel, songBPM, songOffset, songBeats, fn)
	return {
		text = text,
		songlevel = songlevel,
		songBPM = songBPM,
		songOffset = songOffset,
		songBeats = songBeats,
		fn = fn,
		
		now = false,
		last = false
	}
end

function newBeat(beatNum, timing, buttonkeys, beatLength)
	return {
		beatNum = beatNum,
		timing = timing,
		buttonkeys = buttonkeys,
		beatLength = beatLength
	}
end


font = love.graphics.newFont(28)

function love.update(dt)
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
	songList = json.decode(love.filesystem.read('songlist.json'))
	-- discordSource = love.audio.newSource("songs/Discord/Discord.mp3", "stream")
	-- meltdownSource = love.audio.newSource("songs/Meltdown/Meltdown.mp3", "stream")
end

function menu.enter()

	buttons = {}

	table.insert(buttons, newButton(
		"Danz Mode",
		function()
			print("Starting game")
			Gamestate.switch(danzsongs)
		end))

	table.insert(buttons, newButton(
		"Pax",
		function()
			print("Loading game")
		
		end))

	table.insert(buttons, newButton(
		"Settings",
		function()
			print("Going to Settings menu")
		
		end))

	table.insert(buttons, newButton(
		"Exit",
		function()
			love.event.quit(0)
		
		end))
end

function danzsongs.enter()

	buttons = {}
	
	for i,k in ipairs(songList) do
		songFile = json.decode(love.filesystem.read(k["Song"]))
		for j,l in ipairs(songFile) do
			buttonTitle = l["songName"]
			songlevel = l["songWav"]
			songBPM = l["songBPM"]
			songOffset = l["songOffset"]
			songBeats = l["beatmap"]
			table.insert(buttons, newLevelButton(
				buttonTitle,
				songlevel,
				songBPM,
				songOffset,
				songBeats,
				function()
					print("Starting game")
					love.audio.stop()
					Gamestate.switch(levelface)
					songCrochet = 60 / songBPM
				end))
		end
	end

	table.insert(buttons, newButton(
		"Back",
		function()
			love.audio.stop( )
			Gamestate.switch(menu)
		end))
end

function levelface.enter()
	songCrochet = 60 / songBPM
	beatTimer = 0
	lastBeat = 0
	songBeatsAll = json.decode(love.filesystem.read(songBeats))
	levelsong = love.audio.newSource(songlevel, "stream")
	love.audio.play(levelsong)
	songBeats = json.decode(love.filesystem.read(songBeats))
	upcomingBeats = {}
	for i, k in ipairs(songBeats) do
		for l in pairs(k) do
			table.insert(upcomingBeats, newBeat(l, k[tostring(l)]["timing"], k[tostring(l)]["buttons"], k[tostring(l)]["beatLength"]))
		end
	end
end

function levelface.update()
	songPosition = levelsong:tell("seconds")
	if songPosition > songOffset + beatTimer + (songCrochet / 8) then 
		beatTimer = beatTimer + (songCrochet / 8)
		lastBeat = lastBeat + 0.125
	end
	for i, k in ipairs(songBeats) do
		for l in pairs(k) do
			if lastBeat == k[tostring(l)]["timing"] then
				print("Hit " .. k[tostring(l)]["buttons"] .. "!")
			end
		end
	end
end

function levelface.draw()
	buttons = {}
	love.graphics.setColor(0.9, 0.8, 0.85, 1.0)
	local tracker = {50, 400, 75, 550, 750, 550, 750, 400}
	love.graphics.polygon('line', tracker)
	love.graphics.print(
			songPosition,
			font,
			10,
			10
			)
	love.graphics.print(
			lastBeat,
			font,
			412,
			475
			)
end

function levelface:keyreleased(key)
	if key == 'escape' then
		love.audio.stop()
		Gamestate.switch(danzsongs)
	elseif key == 'a' then
		print("A was pressed!")
	end
end

function love.draw()
	local ww = love.graphics.getWidth()
	local wh = love.graphics.getHeight()
	
	local button_width = ww * (1/3)
	local margin = 16
	
	local total_height = (BUTTON_HEIGHT + margin) * #buttons
	local cursor_y = 0

	for i, button in ipairs(buttons) do
		button.last = button.now
		
		local bx = (ww * 0.5) - (button_width * 0.5)
		local by = (wh * 0.5) - (total_height * 0.5) + cursor_y
		
		local color = {0.5, 0.4, 0.45, 1.0}
		local mx, my = love.mouse.getPosition()
		
		local hot = mx > bx and mx < bx + button_width and 
					my > by and my < by + BUTTON_HEIGHT
					
		if hot then 
			color = {0.9, 0.8, 0.85, 1.0}
		end
		
		button.now = love.mouse.isDown(1)
		if button.now and not button.last and hot then 
			songlevel=button.songlevel
			songBPM=button.songBPM
			songOffset=button.songOffset
			songBeats=button.songBeats
			button.fn()
		end
		
			
		love.graphics.setColor(unpack(color))
		love.graphics.rectangle(
			"fill",
			bx,
			by,
			button_width,
			BUTTON_HEIGHT
		)
		
		love.graphics.setColor(0, 0, 0, 1)
		
		local textW = font:getWidth(button.text)
		local textH = font:getHeight(button.text)
		
		love.graphics.print(
			button.text,
			font,
			(ww * 0.5) - textW * 0.5,
			by + textH * 0.5
			)
		
		cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
	end
end