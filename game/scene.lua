local Object = require 'middleclass'.Object
local Scene = Object:subclass'Scene'
local Animation = require 'Animation'
local audio = require 'audio'
require 'system'
local lp = love.physics
local cobweb = require 'cobweb'

--[[local ls = {
		range = 32*1.5*4,
		x = 400,
		y = 300,
		group = 'a'
	}]]

local tween = require 'tween'

local img = love.graphics.newImage'testbg.jpg'

local tileImage = love.graphics.newImage'tileset.png'

local dot = love.graphics.newImage'dot.png'

local switchImage = {
	love.graphics.newImage'lever_left.png'
}
local switchImage2 = {
	love.graphics.newImage'lever_right.png'
}
local angelImage = {
	love.graphics.newImage'angel_idle.png'
}
local angelImage2 = {
	love.graphics.newImage'angel_activated.png'
}
local devilImage = {
	love.graphics.newImage'devil_idle.png'
}
local devilImage2 = {
	love.graphics.newImage'devil_activated.png'
}

local candleImages = {
	love.graphics.newImage'candle_01.png',
	love.graphics.newImage'candle_02.png',
	love.graphics.newImage'candle_03.png',
	love.graphics.newImage'candle_04.png',
	love.graphics.newImage'candle_05.png',
	love.graphics.newImage'candle_06.png',
	love.graphics.newImage'candle_07.png',
	love.graphics.newImage'candle_08.png',
}

local candleGone = {
	love.graphics.newImage'candle_off.png',
}

function Scene:initialize()
	Object.initialize(self)
	self.units = {}
	self.bodies = {}
	self.animations = {}
	self.physicsRef = {}
	self.lightSources = {}
	self.world = lp.newWorld()
	self.shadowTime = 0

	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	self.canvas1 = love.graphics.newCanvas(w,h)
	self.canvas2 = love.graphics.newCanvas(w,h)
	self.lightCanvas1 = love.graphics.newCanvas(w,h)
	self.lightCanvas2 = love.graphics.newCanvas(w,h)

	local frag = love.filesystem.read'radial.frag'
	self.radialShader = love.graphics.newShader(frag)
	local blur = love.filesystem.read'blur.frag'
	self.blurShader = love.graphics.newShader(blur)
	self.blurShader:send('rf_w',800)
	self.blurShader:send('rf_h',600)
	self.blurShader:send('intensity',2.5)
	self.radialShader:send('center',{400,300})
	self.radialShader:send('range',400)

	local ink_diffuse = love.filesystem.read("ink_diffuse.frag")
	local ink_advect = love.filesystem.read("ink_advect.frag")
	local intensity_alpha = love.filesystem.read("intensity_alpha.frag")
	
	self.diffuseShader = love.graphics.newShader(ink_diffuse)
	self.advectShader = love.graphics.newShader(ink_advect)
	self.intensityShader = love.graphics.newShader(intensity_alpha)

	self.vField = love.graphics.newCanvas(800, 600)
	self.vField2 = love.graphics.newCanvas(800, 600)

	self.diffuseShader:send('width',800)
	self.diffuseShader:send('height',600)

	self.advectShader:send('width',800)
	self.advectShader:send('height',600)

	love.graphics.setCanvas(self.vField)
	love.graphics.setBackgroundColor(127,127,0)
	love.graphics.clear()
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(0,0,0)

	self.scarf = {}
	self.blurInt = 0
	local function blurT()
		tween.start(.5,self,{blurInt=math.random()*5},nil,blurT)
	end
	blurT()
	cobweb:load(800,600,50)
end

function Scene:reset()
	self.units = {}
	self.bodies = {}
	self.animations = {}
	self.physicsRef = {}
	self.lightSources = {}
	self.world = lp.newWorld()
	self.shadowTime = 0
end

function Scene:exchangeCanvas()
	self.canvas1, self.canvas2 = self.canvas2, self.canvas1
end

function Scene:exchangeVField()
	self.vField, self.vField2 = self.vField2, self.vField
end

function Scene:getCurrentCanvas()
	return self.lightCanvas1
end

function Scene:drawScarf()
	for _,v in ipairs(self.scarf) do
		local x,y = v.body:getPosition()
		local r = v.body:getAngle()
		love.graphics.draw(dot, x, y, r, 20, 10, .5, .5)
	end
end

function Scene:update(dt)
	for i,v in ipairs(self.animations) do
		v:update(dt)
	end
	for i,v in ipairs(self.units) do
		if not self.bodies[v.tag] then
			local kind = 'static'
			if (v.kind ~= 'wall') then print (v.kind) end
			if v.kind == 'light_player' or v.kind == 'dark_player' or v.kind == 'box' then
				kind = 'dynamic'
			end
			local b = lp.newBody(self.world,v.x,v.y,kind)
			local s = lp.newRectangleShape(v.w,v.h)
			local f = lp.newFixture(b,s)
			table.insert(self.physicsRef, {s,f})
			self.bodies[v.tag] = b
			b:setInertia(1000000)
			f:setUserData(v)

			if #self.scarf == 0 and self.light then
				assert(self.light)
				for i = 1, 8 do
					local x,y = self.light.x, self.light.y
					local shape = lp.newRectangleShape(20,10)
					local b = lp.newBody(self.world, x + 20 * i)
					local fixture = lp.newFixture(b,shape)
				end
			end
		end

		self.bodies[v.tag]:setPosition(v.x,v.y)
		if v.kind == 'dark_player' then
			self.shadow = v
		end
		if v.kind == 'light_player' then
			self.light = v
		end
		if v.tag == self.playerTag then
			self.player = v
		end
	end
	self:updateShadow(dt)
	for i,v in ipairs(self.units) do
		v.hitByLight = nil
	end

	local vx,vy = 0,0

	if love.keyboard.isDown'a' then
		vx = -1
		self.face = 'left'
	end
	if love.keyboard.isDown'd' then
		vx = 1
		self.face = 'right'
	end
	if love.keyboard.isDown'w' then
		vy = -1
	end
	if love.keyboard.isDown's' then
		vy = 1
	end

	local speed = 100

	vx,vy = normalize(vx,vy)
	if self.player then
		for _,unit in ipairs(self.units) do
			local body = self.bodies[unit.tag]
			body:setAngle(0)
			if unit == self.player then
				body:setLinearVelocity(vx * speed,vy * speed)

				for _,lightsource in ipairs(self.lightSources) do
					if self.player == self.light then
						if lightsource.is_on and (unit.x - lightsource.x)^2 + (unit.y - lightsource.y) ^ 2 < 64*64 then
							unit.hitByLight = true
						end
					end
				end
			else
				body:setLinearVelocity(0,0)
				if (unit.x - self.player.x)^2 + (unit.y - self.player.y) ^ 2 < 64*64 then
					self.interacting = unit
				end
			end
		end
	end
	self.world:update(dt)
	
end

function Scene:attemptInteract()
	if (self.interacting) then
		if self.interacting.kind == 'switch' then
			local anim = self.interacting.animation
			anim.images, anim.images2 = anim.images2, anim.images

			if (math.random() > 0.5) then
				audio:playSwitch(true)
			else
				audio:playSwitch(false)
			end

			self:sendCommand({action='interact', group = self.interacting.group})
		end
	end
end

function Scene:screenCordToShader( x,y )
	return x, 600-y
end

function Scene:draw()
	for i,v in ipairs(self.animations) do
		v:draw()
	end
	love.graphics.setColor(255,255,255,100)
	if self.tileset then
		love.graphics.draw(self.tileset)
	end
	love.graphics.setColor(255,255,255,255)
	s:drawLight()
	s:drawShadow()
	for i,v in ipairs(self.units) do
		if v.quad then

		end
	end
	cobweb:draw(0,0)
	if self.bloom and self.bloom > 0 then
		love.graphics.setCanvas(self:getCurrentCanvas())
		love.graphics.clear()
		love.graphics.setShader(self.blurShader)
		love.graphics.draw(self.tileset)
		love.graphics.setCanvas()
		love.graphics.setColor(255,255,255,self.bloom*255)
		love.graphics.draw(self:getCurrentCanvas())
		self:exchangeCanvas()
	end
	for i,v in ipairs(self.units) do
		--[[love.graphics.rectangle('line', v.x - v.w/2,
				v.y - v.h / 2,
				v.w,
				v.h)]]
		if v.kind == 'light_player' then
			
		elseif v.quad then
			love.graphics.draw(tileImage, v.quad, v.x, v.y, 0, 1, 1, 16, 16)
		end
	end
	if self.light then
			love.graphics.setColor(255,255,255,127)
			love.graphics.setShader(self.blurShader)
			self.blurShader:send('intensity', self.blurInt)
			local sx = 1
			if self.face == 'left' then
				sx = -1
			end
			love.graphics.draw(tileImage, self.light.quad, self.light.x, self.light.y+self.blurInt, 0, sx, 1, 16, 48)
			love.graphics.setShader()
			love.graphics.setColor(255,255,255)
			self.blurShader:send('intensity', 3)
		end
	if self.clearing then
		love.graphics.setColor(255,255,255,self.clearing * 255)
		love.graphics.setShader(self.blurShader)
		self.blurShader:send('intensity',(1-self.clearing) * 10)
		love.graphics.draw(self.canvasvic,400,300,0,2-self.clearing,nil,400,300)
		love.graphics.setShader()
		love.graphics.setColor(255,255,255)
	end
	if self.showing then
	end
end

function Scene:drawShadow()
	if not self.shadow then return end
	love.graphics.setColor(255,255,255)
	love.graphics.setShader(self.intensityShader)
	love.graphics.draw(self.canvas1)
	love.graphics.setShader()
	love.graphics.setColor(255,255,255)
end

local numberOfCasts = 200

function Scene:drawLight()
			self.blurShader:send('intensity', 3)
	for _,source in ipairs(self.lightSources) do
		if source.is_on then
			love.graphics.setCanvas(self:getCurrentCanvas())
			love.graphics.clear()
			love.graphics.setShader(self.radialShader)
			self.radialShader:send('center',{self:screenCordToShader(source.x, source.y)})
			local range = source.range

			local triPoints = {}
			local px,py = source.x, source.y
			for i=1,numberOfCasts do
				local angle = math.pi * 2 / numberOfCasts * i
				local dx = math.cos(angle) * range
				local dy = math.sin(angle) * range
				table.insert(triPoints,{dx, dy})
			end
			for i=1,numberOfCasts do
				local dx,dy = unpack(triPoints[i])
				local hitList = {}
				local function castHit(fixture, x, y, xn, yn, fraction)
				    local hit = {}
				    local data = fixture:getUserData()
				    assert(data)
				    hit.fixture = fixture
				    hit.x, hit.y = x, y
				    hit.xn, hit.yn = xn, yn
				    hit.fraction = fraction
				    hit.data = data
				    --[[if data.kind == 'light_player' then
				  		data.hitByLight = true
				  	end]]
				  	if data.kind == 'wall' or data.kind == 'box' or 
				  		data.kind == 'dark_player' or data.kind == 'light_player'
				  		or data.kind == 'angel' or data.kind == 'devil'
				  		 then
				    table.insert(hitList, hit)
				    end

				    return 1 -- Continues with ray cast through all shapes.
				end
				self.world:rayCast(px,py,px+dx,py+dy, castHit)
				table.sort(hitList, function(a,b) return a.fraction < b.fraction end)
				local index = 1
				local firstHit = hitList[index]
				local kx, ky = unpack(triPoints[i % numberOfCasts + 1])
				if firstHit then
				    firstHit.data.hitByLight = true
				    if firstHit.data.kind == 'light_player' then
				    	if hitList[2] then
				    		firstHit = hitList[2]
				    		love.graphics.polygon('fill',px,py,px+dx * firstHit.fraction,py+dy * firstHit.fraction,
							px+kx * firstHit.fraction,py+ky * firstHit.fraction)
				    	else
				    		love.graphics.polygon('fill',px,py,px+dx,py+dy,px+kx,py+ky)
				    	end
						else
							love.graphics.polygon('fill',px,py,px+dx * firstHit.fraction,py+dy * firstHit.fraction,
							px+kx * firstHit.fraction,py+ky * firstHit.fraction)
					end
				else
					love.graphics.polygon('fill',px,py,px+dx,py+dy,px+kx,py+ky)
				end
				end
			love.graphics.setCanvas()
			love.graphics.setColor(255,255,255,255)
			love.graphics.setBlendMode'additive'
			love.graphics.setShader(self.blurShader)
			love.graphics.draw(self.lightCanvas1)
			love.graphics.setBlendMode'alpha'
			love.graphics.setShader()
		end
	end


	if self.player then
		for _,unit in ipairs(self.units) do
			local body = self.bodies[unit.tag]
			local x,y = body:getPosition()
			if math.abs(x - unit.x) > 0.000001 or math.abs(y - unit.y) > 0.000001 then
				if unit == self.player then
					if self.player.kind == 'light_player' and self.player.hitByLight or 
						self.player.kind == 'dark_player' and not self.player.hitByLight then
						self:sendCommand({action='move',x=x,y=y,tag = unit.tag})
					end
				else
					self:sendCommand({action='move',x=x,y=y,tag = unit.tag})
				end
			end

		    if unit.kind == 'devil' then
		    	if unit.prevHit ~= unit.hitByLight then
			    	if unit.hitByLight then
	    				audio:playDevil(false)
					else
	    				audio:playDevil(true)
					end
				end
		    	unit.prevHit = unit.hitByLight
		    	if unit.hitByLight then
					unit.animation.images = devilImage
				else
					unit.animation.images = devilImage2
				end
		    end
		    if unit.kind == 'angel' then
		    	if unit.prevHit ~= unit.hitByLight then
			    	if unit.hitByLight then
	    				audio:playAngel(true)
					else
	    				audio:playAngel(false)
					end
				end
		    	unit.prevHit = unit.hitByLight
		    	if unit.hitByLight then

					unit.animation.images = angelImage2
				else
					unit.animation.images = angelImage
				end
		    end

		end
	end
end

function Scene:loadTest()
end

function Scene:updateState( state )
	
end

local vfieldpic = love.graphics.newImage'vfield.png'
local ecli = love.graphics.newImage'ecli.png'
function Scene:updateShadow( dt )
	if not self.shadow then return end
	self.shadowTime = self.shadowTime + dt
	self.diff = 10
	self.diffuseShader:send('diff', self.diff * dt)
	
	love.graphics.setCanvas(self.vField2)
	love.graphics.setShader(self.diffuseShader)
	love.graphics.draw(self.vField)
	love.graphics.setShader()
	love.graphics.draw(vfieldpic,self.shadow.x,self.shadow.y,self.shadowTime,1,1,16,16)
	love.graphics.draw(vfieldpic,self.light.x,self.light.y,-self.shadowTime,1,1,16,16)
	love.graphics.setCanvas()
	self:exchangeVField()

	love.graphics.setCanvas(self.canvas2)
	love.graphics.setShader(self.advectShader)
	self.advectShader:send('diff', self.diff * dt * 10)
	self.advectShader:send('velocityField', self.vField)
	love.graphics.draw(self.canvas1)
	love.graphics.setShader()
	local x,y = self.shadow.x, self.shadow.y
	love.graphics.setColor(255,0,0,255)
	love.graphics.circle('fill',x,y, 16)

	local x,y = self.light.x, self.light.y
	love.graphics.setColor(255,241,195,255)
	love.graphics.draw(ecli,x,y,0,1,1,16,8)

	love.graphics.setCanvas()
	self:exchangeCanvas()

	love.graphics.setCanvas(self.canvas2)
	love.graphics.setShader(self.diffuseShader)
	love.graphics.clear()
	love.graphics.setColor(255,255,255,255-100*dt)
	love.graphics.draw(self.canvas1)
	love.graphics.setColor(255,255,255,255)
	love.graphics.setShader()
	self:exchangeCanvas()
	love.graphics.setCanvas()

end

local function getTileTopLeft(tileId)
	if tileId == 0 then return nil end
	local x,y = tileId % 8, math.floor(tileId/8)
	if x == 0 then
		x = 6
		y = y - 1
	end
	return x - 1,y
end

local lvlClear = love.graphics.newImage'lvlclear.png'

function Scene:clear(isAngel)
	self.clearing = 0
	self.canvasvic = love.graphics.newCanvas(800,600)
	local bgc = {love.graphics.getBackgroundColor()}
	love.graphics.setCanvas(self.canvasvic)
	if isAngel then
		love.graphics.setBackgroundColor{255,255,255}
		love.graphics.setColor{0,0,0}
	else
		love.graphics.setBackgroundColor{0,0,0}
		love.graphics.setColor{255,255,255}
	end
	love.graphics.clear()
	love.graphics.draw(lvlClear, 400, 300, 0, 1, 1, lvlClear:getWidth()/2, lvlClear:getHeight()/2)
	love.graphics.setCanvas()
	self.showing = 1
	tween.start(.5, self, {clearing = 1}, outExpo, function()
		tween.start(1, self, {},nil,function()
			self:sendCommand({action='change_map',direction='next'})
		tween.start(1, self,{clearing = 0})
			self.clearing = nil
		end)
	end)
	love.graphics.setColor{255,255,255}
	love.graphics.setBackgroundColor(bgc)
end

local id = 10000

local obs = {[9]=true,[25]=true}
local web = {[9]=true,[25]=true}

function Scene:createTile(data,width,height)
	local sw,sh = tileImage:getWidth(), tileImage:getHeight()
	self.tileset = love.graphics.newSpriteBatch(tileImage,width*height)
	for i=1,width do
		for j=1,height do
			local tileId = data[i+width*(j-1)]
			local tx,ty = getTileTopLeft(tileId)
			if tx then
				local quad = love.graphics.newQuad(tx * 32,ty *32, 32, 32, sw,sh)
				local id = self.tileset:add(quad,(i-1)*32, (j-1)*32,0, 1, 1, 16, 16)
				if web[tileId] then
					cobweb:spawn((i-1)*32, (j-1)*32)
				end
				if obs[tileId] then
					table.insert(self.units, {
						w = 32,
						h = 32,
						x = (i-1)*32,
						y = (j-1)*32,
						tag = id,
						isObstacle = true,
						kind = 'wall'
					})
					id = id + 1
				end
			end
		end
	end
end


function Scene:createObject( def )
	if def.kind == 'light' or def.kind == 'window_light' then
		local x,y = def.x - 16, def.y - 16
		local range = def.range or 2.8
		range = range * 32
		table.insert(self.lightSources, {x=x,y=y,range=range,is_on = def.is_on,group = def.group})
		if def.kind == 'light' then
			local anim = Animation(candleImages, 0.2, x,y)
			table.insert(self.animations, anim)
			if not def.is_on then
				anim.images = candleGone
			end
			self.lightSources[#self.lightSources].animation = anim
		end
	else
		local sw,sh = tileImage:getWidth(), tileImage:getHeight()
		local tileId, quad
		if def.tileId then
			tileId = def.tileId
			local tx,ty = getTileTopLeft(tileId)
			if tx then
				quad = love.graphics.newQuad(tx * 32,ty *32, 32, 32, sw,sh)
			end
		end
		if (def.kind == 'box') then
			print 'newBox'
			def.w, def.h = 35,35
			quad = love.graphics.newQuad(160, 64, 32, 64, sw,sh)
		end

		if def.kind=='light_player' then
			print 'newQuad'
			quad = love.graphics.newQuad(192, 0, 32, 64, sw,sh)
		end

		local object = {
			tag = def.tag or 1,
			quad = quad,
			kind = def.kind,
			x = def.x - 16,
			y = def.y - 16,
			w = def.w or 25,
			h = def.h or 25,
			group = def.group
		}

		if def.kind=='switch' then
			local anim = Animation(switchImage, 10, def.x-16,def.y-16)
			anim.images2 = switchImage2
			table.insert(self.animations,anim)
			object.animation = anim
		end


		if def.kind == 'angel' then
			local anim = Animation(angelImage, 10, def.x-16,def.y-16)
			anim.h = 32
			anim.images2 = switchImage2
			table.insert(self.animations,anim)
			object.animation = anim
		end

		if def.kind == 'devil' then
			local anim = Animation(devilImage, 10, def.x-16,def.y-16)
			anim.h = 32
			anim.images2 = switchImage2
			table.insert(self.animations,anim)
			object.animation = anim
		end

		table.insert(self.units,object)
	end
end

function Scene:updateState(data)
	if data.action == 'init' then
		cobweb:clear()
		self:reset()
		self.playerTag = data['player_tag']
		self.width = data.width
		self.height = data.height
		self:createTile(data.tiles,self.width,self.height)
		for _,def in ipairs(data.objects) do
			self:createObject(def)
		end
	elseif data.action == 'move' then
		for _,unit in ipairs(self.units) do
			if unit.tag == data.tag then
				unit.x, unit.y = data.x, data.y
			end
		end
	elseif data.action == 'update' then
		for _,unit in ipairs(self.units) do
			if unit.tag == data.tag then
				for k,v in pairs(data) do
					if k~= 'action' then
						unit[k] = v
					end
				end
			end
		end
	elseif data.action == 'interact' then
		for _,lightsource in ipairs(self.lightSources) do
			print (lightsource.group)
			if lightsource.group == data.group then
				lightsource.is_on = not lightsource.is_on
				if lightsource.is_on then
					lightsource.animation.images = candleImages
					self.bloom = .5
					tween.start(.5, self, {bloom = 0})
				else
					lightsource.animation.images = candleGone
				end
			end
		end
	end
end

return Scene
