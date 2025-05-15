local keybinds = {}
local stateMachineRef = nil





function keybinds.enter(stateMachine)
    stateMachineRef = stateMachine
    
end

function keybinds.update(dt)
    -- Update the game logic here
end

function keybinds.draw()
    -- Draw the game here
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("A:", 10, 100)
    love.graphics.print("Left", 100, 100)
    love.graphics.print("D:", 10, 150)
    love.graphics.print("Right", 100, 150)
    love.graphics.print("Space:", 10, 200)
    love.graphics.print("Jump", 100, 200)
    love.graphics.print("MouseLeft:", 10, 250)
    love.graphics.print("Attack", 100, 250)
    love.graphics.print("MouseRight:", 10, 300)
    love.graphics.print("Parry", 100, 300)
    
end

function keybinds.keyreleased(key, scancode)

    if key == "escape" then
            if stateMachineRef ~= nil then
                stateMachineRef.changeState("mainMenu")
            end
        end
    if key == "f11" then
            -- Toggle fullscreen mode
            local isFullscreen = love.window.getFullscreen()
            love.window.setFullscreen(not isFullscreen)
        end
end
return keybinds