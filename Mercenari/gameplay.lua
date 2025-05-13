local gameplay = {}
local stateMachineRef = nil

--------------------------------------------------
-- REQUIRE
--------------------------------------------------
local Player = require("player")

--------------------------------------------------

--------------------------------------------------
-- VARIABLES
--------------------------------------------------
local debugText = true

local player = Player.new({speed = 100})
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
function gameplay.enter(stateMachine)
    stateMachineRef = stateMachine


    if player then 
        player:load() end

    
end

function gameplay.update(dt)
    -- Update the game logic here
    if player then 
        player:update(dt) end
end

function gameplay.draw()
    -- Draw the game here
    if player then
        player:draw() end
end
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
---
function  gameplay.keypressed(key, scancode, isrepeat)
    
    if key == "space" then
        if player then
            player.isjump = true
        end
    end
end
function gameplay.keyreleased(key, scancode)


    if key == "escape" then
        if stateMachineRef ~= nil then
            stateMachineRef.changeState("mainMenu")
        end
    end

    if key == "f1" then
        debugText = not debugText
    end

    if key == "f11" then
        -- Toggle fullscreen mode
        local isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    end

    if key == "f3" then
        -- Toggle borderless window mode
        SETTINGS.DISPLAY.BORDERLESS = not SETTINGS.DISPLAY.BORDERLESS
    end
    
    
end

return gameplay