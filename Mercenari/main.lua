--if (love.system.getOS() == 'OS X' ) and (jit.arch == 'arm64' or jit.arch == 'arm') then jit.off() end

require("globals")

local state_machine = require("stateMachine")

function love.load()
    state_machine.changeState("initialize")
end

function love.update(dt)
    state_machine.update(dt)
end

function love.draw()
    state_machine.draw()
end

function love.resize(w, h)
    state_machine.resize(w, h)
end

-- Input

-- Mouse
function love.mousemoved(x, y, dx, dy, istouch)
    state_machine.mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
    state_machine.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    state_machine.mousereleased(x, y, button, istouch, presses)
end

-- Touch
function love.touchpressed(id, x, y, dx, dy, pressure)
    state_machine.touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    state_machine.touchreleased(id, x, y, dx, dy, pressure)
end

-- Keyboard
function love.keypressed(key, scancode, isrepeat)
    state_machine.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    state_machine.keyreleased(key, scancode)
end

