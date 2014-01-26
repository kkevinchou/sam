local system = {
	wasMouseDown = false
}

function normalize( x,y )
	if x==0 and y==0 then return x,y end
	local d = (x*x+y*y)^0.5
	return x/d, y/d
end

function dot(x1,y1,x2,y2)
	return x1*x2 + y1*y2
end

function cross(x1,y1,x2,y2)
	return x1 * y2 - x2 * y1
end

function projection(x1,y1,x2,y2)
	local d = dot(x1,y1,x2,y2)
	local x,y = normalize(x2,y2)
	return d * x2, d * y2
end

function perpendicular(x1,y1,x2,y2)
	local x,y = projection(x1,y1,x2,y2)
	return x1-x, y1-y
end

function distanceSquared(x1,y1,x2,y2)
	return (x2-x1)^2+(y2-y1)^2
end

function get_direction()
	local dx,dy = 0,0
	if love.keyboard.isDown'a' then
		dx = dx - 1
	end
	if love.keyboard.isDown'd' then
		dx = dx + 1
	end
	if love.keyboard.isDown'w' then
		dy = dy - 1
	end
	if love.keyboard.isDown's' then
		dy = dy + 1
	end
	return normalize(dx,dy)
end

function getMouseVelocity()
	local x,y = love.mouse.getPosition()
	local rx,ry = 0,0
	if system.wasMouseDown then
		rx,ry = x - system.mouseX, y - system.mouseY
	end
	system.mouseX, system.mouseY = x,y
	return rx,ry
end

function getAsset(path)
end

function system.update(dt)
	system.wasMouseDown = system.isMouseDown
	system.isMouseDown = love.mouse.isDown'l'
end

return system