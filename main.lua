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

font = love.graphics.newFont(32)

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
		end
		table.insert(buttons, newButton(
			buttonTitle,
			function()
				print("Starting game")
				love.audio.stop()
				Gamestate.switch(levelface)
				songlevel = songlevel
				songBPM = songBPM
				songCrochet = 60 / songBPM
				songOffset = songOffset
			end))
	end

	table.insert(buttons, newButton(
		"Back",
		function()
			love.audio.stop( )
			Gamestate.switch(menu)
		end))
end

function levelface.draw()
	buttons = {}
	love.graphics.setColor(0.9, 0.8, 0.85, 1.0)
	local tracker = {50, 400, 75, 550, 750, 550, 750, 400}
	love.graphics.polygon('line', tracker)
	levelsong = love.audio.newSource(songlevel, "stream")
	love.audio.play(levelsong)
	songPosition = levelsong:tell("seconds")
	love.graphics.print(
			songPosition,
			font,
			10,
			10
			)
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