local cobweb = {}

local images = {
	love.graphics.newImage'cobweb_1.png',
	love.graphics.newImage'cobweb_2.png',
	love.graphics.newImage'cobweb_3.png',
	love.graphics.newImage'cobweb_4.png',
}

function cobweb:load( w,h )
	local blur = love.filesystem.read'blur.frag'
	self.blurShader = love.graphics.newShader(blur)
	self.canvas = love.graphics.newCanvas(w,h)
end

function cobweb:clear()
	self.canvas = love.graphics.newCanvas(w,h)
end

function cobweb:spawn(x,y)
	if math.random() > 0.3 then return end
	local dx = math.random()*60
	local dy = math.random()*60
	local scale
	--x,y = x+dx, y + dy
	scale = math.random() + 1
	
	local r = math.random()*7
	love.graphics.setShader(self.blurShader)
	love.graphics.setCanvas(self.canvas)
	self.blurShader:send('intensity', (scale - 1) * 3)
	love.graphics.draw(images[math.random(1,4)], x,y,r,scale,scale,16,16)
	
	love.graphics.setCanvas()
	love.graphics.setShader()
end

function cobweb:draw(x,y)
	love.graphics.draw(self.canvas,x,y)
end

return cobweb