-- to start with, we need to require the 'socket' lib (which is compiled
-- into love). socket provides low-level networking features.

print 'threading running'

local socket = require "socket"

-- the address and port of the server
local address, port = "10.1.7.109", 1234

local entity -- entity is what we'll be controlling
local updaterate = 0.1 -- how long to wait, in seconds, before requesting an update

local world = {} -- the empty world-state
local t

print 'threading running'

-- love.load, hopefully you are familiar with it from the callbacks tutorial
function load()

    -- first up, we need a udp socket, from which we'll do all
    -- out networking.
    udp = socket.udp()
    
    -- normally socket reads block until they have data, or a
    -- certain amout of time passes.
    -- that doesn't suit us, so we tell it not to do that by setting the 
    -- 'timeout' to zero
    udp:settimeout(0)
    
    -- unlike the server, we'll just be talking to the one machine, 
    -- so we'll "connect" this socket to the server's address and port
    -- using setpeername.
    --
    -- [NOTE: UDP is actually connectionless, this is purely a convenience
    -- provided by the socket library, it doesn't actually change the 
    --'bits on the wire', and in-fact we can change / remove this at any time.]
    udp:setpeername(address, port)
    
    -- seed the random number generator, so we don't just get the
    -- same numbers each time.
    math.randomseed(os.time()) 
    
    -- entity will be what we'll be controlling, for the sake of this
    -- tutorial its just a number, but it'll do.
    -- we'll just use random to give us a reasonably unique identity for little effort.
    --
    -- [NOTE: random isn't actually a very good way of doing this, but the
    -- "correct" ways are beyond the scope of this article. the *simplest* 
    -- is just an auto-count, they get a *lot* more fancy from there on in]
    
    entity = tostring(math.random(99999))

    -- Here we do our first bit of actual networking:
    -- we set up a string containing the data we want to send (using 'string.format')
    -- and then send it using 'udp.send'. since we used 'setpeername' earlier
    -- we don't even have to specify where to send it.
    --
    -- thats...it, really. the rest of this is just putting this context and practical use.
    local dg = string.format("%s %s %d %d", entity, 'at', 320, 240)
    udp:send(dg) -- the magic line in question.
    
    -- t is just a variable we use to help us with the update rate in love.update.
    t = 0 -- (re)set t to 0
end

load()

-- love.update, hopefully you are familiar with it from the callbacks tutorial
function update(deltatime)

    t = t + deltatime -- increase t by the deltatime
    
    -- its *very easy* to completely saturate a network connection if you
    -- aren't careful with the packets we send (or request!), we hedge
    -- our chances by limiting how often we send (and request) updates.
    -- 
    -- for the record, ten times a second is considered good for most normal
    -- games (including many MMOs), and you shouldn't ever really need more 
    -- than 30 updates a second, even for fast-paced games.
    if t > updaterate then
        -- we could send updates for every little move, but we consolidate
        -- the last update-worth here into a single packet, drastically reducing
        -- our bandwidth use.
         udp:send('lol')

        t=t-updaterate -- set t for the next round
    end

    
    -- there could well be more than one message waiting for us, so we'll
    -- loop until we run out!
    repeat
        -- and here is something new, the much anticipated other end of udp:send!
        -- receive return a waiting packet (or nil, and an error message).
        -- data is a string, the payload of the far-end's send. we can deal with it
        -- the same ways we could deal with any other string in lua (needless to 
        -- say, getting familiar with lua's string handling functions is a must.
        data, msg = udp:receive()

        if data then -- you remember, right? that all values in lua evaluate as true, save nil and false?
           print (data,msg)
        elseif msg ~= 'timeout' then 
            error("Network error: "..tostring(msg))
        end
    until not data 

end

while true do
    update(0.01)
    socket.sleep(0.01)
    print 'updating'
end
