local stateMachine = {}

local states = {
    initialize = require("initialize"),         -- require the initialize.lua file
    mainMenu = require("mainMenu"),             -- require the mainMenu.lua file
    gameplay = require("gameplay"),             -- require the gameplay.lua file
    credits = require("credits"),             -- require the credits.lua file
    keybinds = require("keybinds"),
    pause = require("pause")
}

local currentState = nil

-- Updates the scaling and offsets
local function updateScaling()
    local currentWindowWidth, currentWindowHeight = love.graphics.getDimensions()

    -- Calc the scale
    local scaleX = currentWindowWidth / SETTINGS.DISPLAY.WIDTH
    local scaleY = currentWindowHeight / SETTINGS.DISPLAY.HEIGHT

    -- Use smaller scale value to maintain the aspect ratio (letterboxing)
    SETTINGS.DISPLAY.SCALE = math.min(scaleX, scaleY)

    -- Calc the offsets to center the game on screen
    SETTINGS.DISPLAY.OFFSETX = (currentWindowWidth - SETTINGS.DISPLAY.WIDTH * SETTINGS.DISPLAY.SCALE) / 2
    SETTINGS.DISPLAY.OFFSETY = (currentWindowHeight - SETTINGS.DISPLAY.HEIGHT * SETTINGS.DISPLAY.SCALE) / 2

end

function stateMachine.changeState(newState)
    if currentState and currentState.exit then
        currentState.exit()
    end

    currentState = states[newState]

    if currentState and currentState.enter then
        currentState.enter(stateMachine)
    end
end     

function stateMachine.update(dt)
    if currentState and currentState.update then
        currentState.update(dt)
    end
end

function stateMachine.draw()
    if currentState and currentState.draw then
        currentState.draw()
    end
end

function stateMachine.resize(w, h)
    updateScaling()
end

-- Mouse input
function stateMachine.mousemoved(x, y, dx, dy, istouch)
    if currentState and currentState.mousemoved then
        currentState.mousemoved(x, y, dx, dy, istouch)
    end
end

function stateMachine.mousepressed(x, y, button, istouch, presses)
    if currentState and currentState.mousepressed then
        currentState.mousepressed(x, y, button, istouch, presses)
    end
end

function stateMachine.mousereleased(x, y, button, istouch, presses)
    if currentState and currentState.mousereleased then
        currentState.mousereleased(x, y, button, istouch, presses)
    end
end

-- Touch input
function stateMachine.touchpressed(id, x, y, dx, dy, pressure)
    if currentState and currentState.touchpressed then
        currentState.touchpressed(id, x, y, dx, dy, pressure)
    end
end

function stateMachine.touchreleased(id, x, y, dx, dy, pressure)
    if currentState and currentState.touchreleased then
        currentState.touchreleased(id, x, y, dx, dy, pressure)
    end
end

-- Keyboard input
function stateMachine.keyreleased(key, scancode)
    if currentState and currentState.keyreleased then
        currentState.keyreleased(key, scancode)
    end
end

function stateMachine.keypressed(key, scancode, isrepeat)
    if currentState and currentState.keypressed then
        currentState.keypressed(key, scancode, isrepeat)
    end
end

return stateMachine