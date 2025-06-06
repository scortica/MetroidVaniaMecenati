local keybinds = {}
local callbacks = {}

local stateMachineRef = nil


local atk=love.graphics.newImage("Assets/Sprites/UI/Attack.png")
local parry=love.graphics.newImage("Assets/Sprites/UI/Parry.png")
local left=love.graphics.newImage("Assets/Sprites/UI/MoveLeft.png")
local right=love.graphics.newImage("Assets/Sprites/UI/MoveRight.png")
local jump=love.graphics.newImage("Assets/Sprites/UI/Jump.png")
local heal=love.graphics.newImage("Assets/Sprites/UI/Heal.png")
local pauseMenu = nil


function keybinds.load(cb)
    callbacks = cb or {}

    pauseMenu = love.graphics.newImage("Assets/Pause/PauseCornice.png")

end

function keybinds.update(dt)
    
end

function keybinds.draw()

    love.graphics.setColor(50/255, 60/255, 57/255, 0.5)
    love.graphics.rectangle("fill", 0, 0, SETTINGS.DISPLAY.WIDTH, SETTINGS.DISPLAY.HEIGHT)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(pauseMenu, 0, 0, 0, 0.5, 0.5)
    
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