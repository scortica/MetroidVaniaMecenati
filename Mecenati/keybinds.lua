local keybinds = {}
local callbacks = {}

local stateMachineRef = nil


local atk=love.graphics.newImage("Assets/Sprites/UI/Attack.png")
local parry=love.graphics.newImage("Assets/Sprites/UI/Parry.png")
local left=love.graphics.newImage("Assets/Sprites/UI/MoveLeft.png")
local right=love.graphics.newImage("Assets/Sprites/UI/MoveRight.png")
local jump=love.graphics.newImage("Assets/Sprites/UI/Jump.png")
local heal=love.graphics.newImage("Assets/Sprites/UI/Heal.png")



function keybinds.load(cb)
    callbacks = cb or {}

end

function keybinds.update(dt)
    
end

function keybinds.draw()
    -- Draw the game here
    love.graphics.draw(atk, 400, 200)
    love.graphics.draw(parry, 400, 300)
    love.graphics.draw(left, 400, 400)
    love.graphics.draw(right, 400, 500)
    love.graphics.draw(jump, 400, 600)
    love.graphics.draw(heal, 400, 700)

end

function keybinds.keyreleased(key, scancode)

    if key == "escape" then
            if callbacks.onPause then callbacks.onPause() end
    end

    if key == "f11" then
            -- Toggle fullscreen mode
            local isFullscreen = love.window.getFullscreen()
            love.window.setFullscreen(not isFullscreen)
        end
end
return keybinds