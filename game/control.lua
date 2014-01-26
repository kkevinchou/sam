local Object = require 'middleclass'.Object

local Control = Object:subclass'Control'

function Control:initialize( ... )
	Object.initialize(self,...)
	self.enable = true
end

function Control:update(dt)
	if not self.enable then return end
	if love.keyboard.isDown'a' then
		self:sendCommand({action='move',direction={-1,0}})
	elseif love.keyboard.isDown'd' then
		self:sendCommand({action='move',direction={1,0}})
	elseif love.keyboard.isDown'w' then
		self:sendCommand({action='move',direction={0,-1}})
	elseif love.keyboard.isDown's' then
		self:sendCommand({action='move',direction={0,1}})
	end
end

return Control