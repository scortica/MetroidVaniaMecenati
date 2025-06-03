local DeadScreen = {}
local callbacks = {}

local DeadScreenMenu = love.graphics.newImage("Assets/Sprites/UI/deadTextUII.png")
local esc = love.graphics.newImage("Assets/Sprites/UI/esc.png")
local menu = love.graphics.newImage("Assets/Sprites/UI/menuUI.png")
local restart = love.graphics.newImage("Assets/Sprites/UI/restartUI.png")

local stateMachineRef = nil

local debugText = false -- Set to true to enable debug messages

function DeadScreen.load(cb)
    callbacks = cb or {}
end

function DeadScreen.update(dt)
    
    if debugText then
        print("DeadScreen.update called")
    end
    
    if love.keyboard.isDown("escape") then
        if debugText then
            print("Escape key pressed, returning to main menu")
        end
        if callbacks.onMainMenu then callbacks.onMainMenu() end
    end

    if love.keyboard.isDown("r") then
        if debugText then
            print("Escape key pressed, returning to main menu")
        end
        if callbacks.onMainMenu then callbacks.onRetry() end
    end

end

function DeadScreen.draw()
    -- Draw the dead screen background
    love.graphics.draw(DeadScreenMenu, (SETTINGS.DISPLAY.WIDTH/2)-(DeadScreenMenu:getWidth()/3.5) , (SETTINGS.DISPLAY.HEIGHT/2)-(DeadScreenMenu:getHeight()/2) , 0, SETTINGS.DISPLAY.SCALE, SETTINGS.DISPLAY.SCALE)
    love.graphics.draw(menu, (SETTINGS.DISPLAY.WIDTH/2)-(esc:getWidth()/4)-22 , (SETTINGS.DISPLAY.HEIGHT/2)-(esc:getHeight()/2) + 200, 0, SETTINGS.DISPLAY.SCALE, SETTINGS.DISPLAY.SCALE)
    love.graphics.draw(restart, (SETTINGS.DISPLAY.WIDTH/2)-(esc:getWidth()/4) , (SETTINGS.DISPLAY.HEIGHT/2)-(esc:getHeight()/2) + 300, 0, SETTINGS.DISPLAY.SCALE, SETTINGS.DISPLAY.SCALE)

    
end

--[[function DeadScreen.mousemoved(x, y, dx, dy, istouch)
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

--[[function DeadScreen.mousepressed(x, y, button, istouch, presses)

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

--[[function DeadScreen.mousereleased(x, y, button, istouch, presses)
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


function DeadScreen.keyreleased(key, scancode)

    if key == "escape" then
            
    end
    if key == "f11" then
        local isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    end
end

return DeadScreen