local sounds = {}

angelOn = love.audio.newSource("sounds/effects/statues/angel/angel_on.ogg", "static")
angelOff = love.audio.newSource("sounds/effects/statues/angel/angel_off.ogg", "static")
devilOn = love.audio.newSource("sounds/effects/statues/devil/devil_on.ogg", "static")
devilOff = love.audio.newSource("sounds/effects/statues/devil/devil_off.ogg", "static")
switchOn = love.audio.newSource("sounds/effects/switch/switch_on.ogg", "static")
switchOff = love.audio.newSource("sounds/effects/switch/switch_off.ogg", "static")
bgMusic = love.audio.newSource("sounds/music/Timeless_Jami_Sieber_03_River_of_Sky_Jami_Sieber_spoken.ogg", "stream")
bgMusic:setLooping(true)

sounds.playAngel = function(isOn)
    if isOn then
        angelOn:play()
    else
        angelOff:play()
    end
end

sounds.playDevil = function(isOn)
    if isOn then
        devilOn:play()
    else
        devilOff:play()
    end
end

sounds.playSwitch = function(isOn)
    if isOn then
        switchOn:play()
    else
        switchOff:play()
    end
end

sounds.playMusic = function(isOn)
    if isOn then
        bgMusic:play()
    else
        bgMusic:stop()
    end
end

return sounds
