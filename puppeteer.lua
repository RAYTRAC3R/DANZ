json = require "depend.json"

function addPart(sprite, partype, partsize, partx, party, originx, originy)
	return {
		sprite=sprite,
		partype=partype,
		partsize=partsize,
		partx=partx,
		party=party,
		originx=originx,
		originy=originy
		}
end

function buildChar(charjson, charx, chary)
	charjsoncode = json.decode(love.filesystem.read(charjson))
	instchar = {}
	for i, k in ipairs(charjsoncode) do
		local charroot = k["root"]
		local charhead = k["head"]
		if charroot["type"] == "root" then
			sprite = charroot["sprite"]
			partype = "root"
			partsize = charroot["size"]
			partx = charx
			party = chary
			originx = charroot["originx"]
			originy = charroot["originy"]
			table.insert(instchar, addPart(sprite, partype, partsize, partx, party, originx, originy))
		end
		if charhead["type"] == "head" then
			sprite = charhead["sprite"]
			headoffsetx = charhead["offsetx"]
			headoffsety = charhead["offsety"]
			partype = "head"
			partsize = charhead["size"]
			partx = charx + headoffsetx
			party = chary + headoffsety
			originx = charhead["originx"]
			originy = charhead["originy"]
			table.insert(instchar, addPart(sprite, partype, partsize, partx, party, originx, originy))
		end
	end
	return instchar
end

function setAnim()
	animhead = {0}
	animroot = {0}
	
	headanim1 = {18}
	headanim2 = {-18}
	
	headtween1 = tween.new(5, animhead, headanim1, 'inBack')
	headtween2 = tween.new(5, animhead, headanim2, 'inBack')
end