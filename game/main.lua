local Scene = require 'scene'
local json = require 'dkjson'
local Control = require 'control'
local tween = require 'tween'
local audio = require 'audio'

local control = Control()

require 'LUBE.LUBE'

s = Scene()
s:loadTest()

function handleUpdate()
    control.enable = false
end

local timeElapsed = 0

function s:sendCommand(cmd) 
    cmd.timestamp = timeElapsed
    local  data  = json.encode(cmd)
    lube.client:send(data)
end

local t = love.thread.newThread('network.lua')
--t:start()

local demoInit = [[{"player_tag": 0, "tiles": [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 7, 7, 7, 7, 7, 7, 7, 2, 7, 7, 7, 7, 7, 7, 7, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 7, 12, 12, 12, 12, 12, 12, 12, 12, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12], "height": 20, "width": 25, "objects": [{"kind": "switch", "tag": 1000, "group": "b", "is_on": "false", "y": 111, "x": 559}, {"kind": "switch", "tag": 1001, "group": "b", "is_on": "true", "y": 497, "x": 241}, {"kind": "light", "tag": 1002, "group": "b", "is_on": "true", "y": 206, "x": 400}, {"y": 398, "x": 399, "kind": "light", "tag": 1003, "is_on": "true"}, {"kind": "light", "tag": 1004, "group": "a", "is_on": "false", "y": 400, "x": 559}, {"y": 464, "x": 624, "kind": "angel", "tag": 1005}, {"y": 400, "x": 239, "kind": "light", "tag": 1006, "is_on": "true"}, {"y": 144, "x": 302, "kind": "dark_player", "tag": 1}, {"y": 143, "x": 337, "kind": "light_player", "tag": 0}], "action": "init"}]]
function rcvCallback(data)
    --data is the data received, do anything you want with it
    print (data)
    if (data.action == 'init') then
        timeElapsed = 0
    end
    local dest,err = json.decode(data)
    if not dest then return end
    s:updateState(dest)
end

function load()
    --do anything else you need to do here
    local ip, port = '127.0.0.1', 1234
    lube.client:Init('udp') --initialize
    lube.client:setHandshake('{"action":"player_connect"}') --this is a unique string that will be sent when connecting and disconnecting
    lube.client:setCallback(rcvCallback) --set rcvCallback as the callback for received messages
    lube.client:connect(ip, port) --change ip and port into.. an ip and a port
    print 'connection complete. if you are not seeing anything, things fucked up.'
end

function love.load()
	load()
    audio:playMusic(true)
    --tween.start(5, s.shadow, {x = 300})--, easing, callback, ...)
    --rcvCallback(demoInit)
    --rcvCallback([[{"direction":[1,0],"action":"move"}]])
end

function love.draw()
	s:draw()
end

function love.update( dt )
    timeElapsed = timeElapsed + dt
    tween.update(dt)
    --control:update(dt)
	lube.client:update(dt)
	if v then print (v) end
	s:update(dt)
end

function love.keypressed( k )
    if k==' ' then
        s:attemptInteract()
    end
    if k=='n' then
        s:sendCommand({action='change_map',direction='next'})
    elseif k=='r' then
        s:sendCommand({action='change_map',direction='current'})
    elseif k=='z' then
        s:sendCommand({action='change_map',direction='previous'})
    end

    if k == 'b' then
        s:clear(true)
    end
    if k == 'v' then
        s:clear(false)
    end
end
