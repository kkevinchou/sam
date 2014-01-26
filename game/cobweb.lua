local cobweb = {}

local images = {
	love.graphics.newImage'cobweb_1.png',
	love.graphics.newImage'cobweb_2.png',
	love.graphics.newImage'cobweb_3.png',
	love.graphics.newImage'cobweb_4.png',
}

function cobweb:load( w,h ,count)
	self.canvas = love.graphics.newCanvas(w,h)
	love.graphics.setCanvas(self.canvas)
	for i=1,count do
		
	end
end

function cobweb:draw(x,y)
	love.graphics.draw(x,y,self.self.canvas)
end

return cobweb