local pause = {}
local callbacks = {}

local uiButtons = nil
local pauseMenu = nil
local function isMouseOverButton(button, x, y)
    return (x >= button.x and x <= button.x + button.width) and
           (y >= button.y and y <= button.y + button.height)
end

function pause.load(cb)
    
end

function pause.update(dt)
    -- Update the game logic here
end

function pause.draw()
    
end

--[[function pause.mousemoved(x, y, dx, dy, istouch)
    local transformedX = (x - SETTINGS.DISPLAY.OFFSETX) / SETTINGS.DISPLAY.SCALE
    local transformedY = (y - SETTINGS.DISPLAY.OFFSETY) / SETTINGS.DISPLAY.SCALE

    -------------------------------------------
    -- Code from here
    -------------------------------------------

    -- print("Mouse position: ", transformedX, transformedY) -- Uncomment to see the mouse position in the console

    if uiButtons then
        if isMouseOverButton(uiButtons.resume, transformedX, transformedY) then
            uiButtons.resume.currentColor = {0,0,0}
            uiButtons.resume.textColor = {1, 1, 1}
        elseif isMouseOverButton(uiButtons.mainMenu, transformedX, transformedY) then
            uiButtons.mainMenu.currentColor = {0,0,0}
            uiButtons.mainMenu.textColor = {1, 1, 1}
        elseif isMouseOverButton(uiButtons.keybinds, transformedX, transformedY) then
            uiButtons.keybinds.currentColor = {0,0,0}
            uiButtons.keybinds.textColor = {1, 1, 1}
        else
            -- Reset the colors
            uiButtons.resume.currentColor = uiButtons.resume.releasedColor
            uiButtons.mainMenu.currentColor = uiButtons.mainMenu.releasedColor
             uiButtons.keybinds.currentColor = uiButtons.keybinds.releasedColor
            uiButtons.resume.textColor = {0, 0, 0}
            uiButtons.mainMenu.textColor = {0, 0, 0}
            uiButtons.keybinds.textColor = {0, 0, 0}
        end
    end

end]]

--[[function pause.mousepressed(x, y, button, istouch, presses)

    if button == 1 then -- Left mouse button

        local transformedX = (x - SETTINGS.DISPLAY.OFFSETX) / SETTINGS.DISPLAY.SCALE
        local transformedY = (y - SETTINGS.DISPLAY.OFFSETY) / SETTINGS.DISPLAY.SCALE

        -------------------------------------------
        -- Code from here
        -------------------------------------------

        if uiButtons then
            if isMouseOverButton(uiButtons.resume, transformedX, transformedY) then
                uiButtons.resume.currentColor = uiButtons.resume.pressedColor
            elseif isMouseOverButton(uiButtons.mainMenu, transformedX, transformedY) then
                uiButtons.mainMenu.currentColor = uiButtons.mainMenu.pressedColor
            elseif isMouseOverButton(uiButtons.keybinds, transformedX, transformedY) then
                uiButtons.keybinds.currentColor = uiButtons.keybinds.pressedColor
            end
        end
    end
end]]

--[[function pause.mousereleased(x, y, button, istouch, presses)
    local transformedX = (x - SETTINGS.DISPLAY.OFFSETX) / SETTINGS.DISPLAY.SCALE
    local transformedY = (y - SETTINGS.DISPLAY.OFFSETY) / SETTINGS.DISPLAY.SCALE

    -------------------------------------------
    -- Code from here
    -------------------------------------------
    if uiButtons then
        if isMouseOverButton(uiButtons.resume, transformedX, transformedY) then
            uiButtons.resume.currentColor = uiButtons.resume.releasedColor
            if callbacks.onResume then callbacks.onResume() end -- Call the onResume callback

        elseif isMouseOverButton(uiButtons.mainMenu, transformedX, transformedY) then
            uiButtons.mainMenu.currentColor = uiButtons.mainMenu.releasedColor 
            if callbacks.onMainMenu then callbacks.onMainMenu() end -- Call the onMainMenu callback
        elseif isMouseOverButton(uiButtons.keybinds, transformedX, transformedY) then
            uiButtons.keybinds.currentColor = uiButtons.keybinds.releasedColor    
             ------------------MODIFICARE PER METTERE KEYBINDS------------------
            if stateMachineRef then
                stateMachineRef.changeState("keybinds")
            else
                print("Error: state_machine_ref is nil")
            end

        end
    end
end]]


function pause.keyreleased(key, scancode)

    if key == "escape" then
            if callbacks.onResume then callbacks.onResume() end
        end
    if key == "f11" then
            -- Toggle fullscreen mode
            local isFullscreen = love.window.getFullscreen()
            love.window.setFullscreen(not isFullscreen)
        end
end

return pause