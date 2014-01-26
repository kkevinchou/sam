local Object = require 'middleclass'.Object

local Animation = Object:subclass'Animation'

function Animation:initialize(images, interval,x,y)
	self.images = images
	self.index = 1
	self.interval = interval
	self.timeElapsed = 0
	self.x,self.y = x,y
end

function Animation:update(dt)
	self.timeElapsed = self.timeElapsed + dt
end

function Animation:draw(x,y)
	x = x or self.x
	y = y or self.y
	love.graphics.setColor(255,255,255)
	local currentImage = self.images[
		math.floor(self.timeElapsed/self.interval)%(#self.images) + 1]
	local w,h = self.w or currentImage:getWidth(), self.h or currentImage:getHeight()
	love.graphics.draw(currentImage, x, y, 0, 1, 1, w/2, h/2)
end

return Animation