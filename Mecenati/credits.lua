local credits = {}
local stateMachineRef = nil

local debugText = true

local creditsFont = nil
local creditsText = nil
local creditsTextWidth = nil
local creditsTextHeight = nil
local creditsTextX = nil
local creditsTextY = nil

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
function credits.enter(stateMachine)
    stateMachineRef = stateMachine
    
end

function credits.update(dt)
    -- Update the game logic here
end

function credits.draw()
    -- Draw the game here
    love.graphics.clear(0, 0, 0, 0)
end
--------------------------------------------------

function credits.keyreleased(key, scancode)

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

end
return credits