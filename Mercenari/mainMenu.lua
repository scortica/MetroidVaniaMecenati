local mainMenu = {}

local stateMachineRef = nil
--------------------------------------------------
-- DECLARE LOCAL VARIABLES AND FUNCTIONS BELOW
--------------------------------------------------

--------------------------------------------------
-- Variables (Local to this module)
--------------------------------------------------
local debugText = true
local uiButtons = nil
local currentFont = nil
local menuFont = nil
local logoImage = nil

--------------------------------------------------
-- Functions (Local to this module)
--------------------------------------------------

-- Helper function to check if the mouse is over an object
local function isMouseOverButton(button, x, y)
    return (x >= button.x and x <= button.x + button.width) and
           (y >= button.y and y <= button.y + button.height)
end

--------------------------------------------
-- LOVE LOAD FUNCTION
--------------------------------------------
function mainMenu.enter(stateMachine)
    stateMachineRef = stateMachine
    ---------------------------------------------------------------------------------
    -- Initialize variables and Load resources here, like fonts or images or sounds
    ---------------------------------------------------------------------------------

    uiButtons = {
        play = {
            x = 980,
            y = 500,
            width = 200,
            height = 50,
            currentColor = {1, 1, 1},
            pressedColor = {0.5, 0.5, 0.5},
            releasedColor = {1, 1, 1},
            text = "Play",
            textColor = {0, 0, 0}
        },
        quit = {
            x = 980,
            y = 600,
            width = 200,
            height = 50,
            currentColor = {1, 1, 1},
            pressedColor = {0.5, 0.5, 0.5},
            releasedColor = {1, 1, 1},
            text = "Quit",
            textColor = {0, 0, 0}
        },


        credits = {
            x = 980,
            y = 700,
            width = 200,
            height = 50,
            currentColor = {1, 1, 1},
            pressedColor = {0.5, 0.5, 0.5},
            releasedColor = {1, 1, 1},
            text = "Credits",
            textColor = {0, 0, 0}
        }
    }

    -- Other examples of variables to initialize
    -- menuFont = love.graphics.newFont("assets/fonts/yourfont.ttf", SETTINGS.FONT.DEFAULT_SIZE)
    -- logoImage = love.graphics.newImage("assets/sprites/yourimage.png")

end

-------------------------------------------
-- LOVE UPDATE FUNCTION
-------------------------------------------
function mainMenu.update(dt)
    -------------------------------------------
    -- Code from here
    -------------------------------------------

    -- Example to check if a key is held down
    if love.keyboard.isDown("w") then
        if debugText then print("W held down") end
    end

    if love.keyboard.isDown("a") then
        if debugText then print("A held down") end
    end

    if love.keyboard.isDown("s") then
        if debugText then print("S held down") end
    end

    if love.keyboard.isDown("d") then
        if debugText then print("D held down") end
    end

    if love.keyboard.isDown("space") then
        if debugText then print("Space held down") end
    end

end

-------------------------------------------
-- LOVE DRAW FUNCTION
-------------------------------------------
function mainMenu.draw()

    -- Draw using the scaled coordinates
    love.graphics.push()
    love.graphics.translate(SETTINGS.DISPLAY.OFFSETX, SETTINGS.DISPLAY.OFFSETY)
    love.graphics.scale(SETTINGS.DISPLAY.SCALE)

    -------------------------------------------
    -- Code from here
    -------------------------------------------

    -- Example to set the font loaded before
    -- love.graphics.setFont(menuFont)

    love.graphics.setColor(1, 1, 1) -- Reset color
    love.graphics.print("Main Menu", 100, 100)

    -- Background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, SETTINGS.DISPLAY.WIDTH, SETTINGS.DISPLAY.HEIGHT)

    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("GAME TITLE: MetroidVania", 100, 50)

    -- Draw play button
    if uiButtons then
        -- Draw play button rectangle
        love.graphics.setColor(uiButtons.play.currentColor)
        love.graphics.rectangle("fill", uiButtons.play.x, uiButtons.play.y, uiButtons.play.width, uiButtons.play.height)
        -- Draw play button text
        love.graphics.setColor(uiButtons.play.textColor)
        love.graphics.print(uiButtons.play.text, uiButtons.play.x + 10, uiButtons.play.y + 10)

        -- Draw quit button
        love.graphics.setColor(uiButtons.quit.currentColor)
        love.graphics.rectangle("fill", uiButtons.quit.x, uiButtons.quit.y, uiButtons.quit.width, uiButtons.quit.height)
        -- Draw quit button text
        love.graphics.setColor(uiButtons.quit.textColor)
        love.graphics.print(uiButtons.quit.text, uiButtons.quit.x + 10, uiButtons.quit.y + 10)

         -- Draw credits button rectangle
        love.graphics.setColor(uiButtons.credits.currentColor)
        love.graphics.rectangle("fill", uiButtons.credits.x, uiButtons.credits.y, uiButtons.credits.width, uiButtons.credits.height)
        -- Draw credits button text
        love.graphics.setColor(uiButtons.credits.textColor)
        love.graphics.print(uiButtons.credits.text, uiButtons.credits.x + 10, uiButtons.credits.y + 10)
    end

    -- Example to set the font loaded before
    --[[
    if logoImage then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(logoImage, 300, 100)
    end
    --]]

    -- Reset line width
    love.graphics.setLineWidth(1)

    -- End of scaled draw
    love.graphics.pop()
end

-----------------------------------------------
-- EXIT FROM THIS MODULE, CLEAN UP EVERYTHING
-----------------------------------------------
function mainMenu.exit()
    stateMachineRef = nil
    love.graphics.setColor(1, 1, 1) -- Reset color
    -------------------------------------------
    -- Code from here
    -------------------------------------------
    uiButtons = nil
    currentFont = nil
    menuFont = nil
    logoImage = nil
    collectgarbage("collect")
end

-------------------------------------------
-- INPUT HANDLERS
-------------------------------------------

function mainMenu.mousemoved(x, y, dx, dy, istouch)
    local transformedX = (x - SETTINGS.DISPLAY.OFFSETX) / SETTINGS.DISPLAY.SCALE
    local transformedY = (y - SETTINGS.DISPLAY.OFFSETY) / SETTINGS.DISPLAY.SCALE

    -------------------------------------------
    -- Code from here
    -------------------------------------------

    -- print("Mouse position: ", transformedX, transformedY) -- Uncomment to see the mouse position in the console

    if uiButtons then
        if isMouseOverButton(uiButtons.play, transformedX, transformedY) then
            uiButtons.play.currentColor = {0,0,0}
            uiButtons.play.textColor = {1, 1, 1}
        elseif isMouseOverButton(uiButtons.quit, transformedX, transformedY) then
            uiButtons.quit.currentColor = {0,0,0}
            uiButtons.quit.textColor = {1, 1, 1}
        else
            -- Reset the colors
            uiButtons.play.currentColor = uiButtons.play.releasedColor
            uiButtons.quit.currentColor = uiButtons.quit.releasedColor
            uiButtons.play.textColor = {0, 0, 0}
            uiButtons.quit.textColor = {0, 0, 0}
            uiButtons.credits.textColor = {0, 0, 0}
        end
    end

end

function mainMenu.mousepressed(x, y, button, istouch, presses)

    if button == 1 then -- Left mouse button

        local transformedX = (x - SETTINGS.DISPLAY.OFFSETX) / SETTINGS.DISPLAY.SCALE
        local transformedY = (y - SETTINGS.DISPLAY.OFFSETY) / SETTINGS.DISPLAY.SCALE

        -------------------------------------------
        -- Code from here
        -------------------------------------------

        if uiButtons then
            if isMouseOverButton(uiButtons.play, transformedX, transformedY) then
                uiButtons.play.currentColor = uiButtons.play.pressedColor
            elseif isMouseOverButton(uiButtons.quit, transformedX, transformedY) then
                uiButtons.quit.currentColor = uiButtons.quit.pressedColor
            elseif isMouseOverButton(uiButtons.credits, transformedX, transformedY) then
                uiButtons.credits.currentColor = uiButtons.credits.pressedColor
            end
        end
    end
end

function mainMenu.mousereleased(x, y, button, istouch, presses)
    local transformedX = (x - SETTINGS.DISPLAY.OFFSETX) / SETTINGS.DISPLAY.SCALE
    local transformedY = (y - SETTINGS.DISPLAY.OFFSETY) / SETTINGS.DISPLAY.SCALE

    -------------------------------------------
    -- Code from here
    -------------------------------------------
    if uiButtons then
        if isMouseOverButton(uiButtons.play, transformedX, transformedY) then
            uiButtons.play.currentColor = uiButtons.play.releasedColor

            -- Change to gameplay state, or any other state
            if stateMachineRef then
                stateMachineRef.changeState("gameplay")
            else
                print("Error: state_machine_ref is nil")
            end

        elseif isMouseOverButton(uiButtons.quit, transformedX, transformedY) then
            uiButtons.quit.currentColor = uiButtons.quit.releasedColor 
            love.event.quit()
        elseif isMouseOverButton(uiButtons.credits, transformedX, transformedY) then
            uiButtons.credits.currentColor = uiButtons.credits.releasedColor    
             if stateMachineRef then
                stateMachineRef.changeState("credits")
            else
                print("Error: state_machine_ref is nil")
            end

        end
    end
end

function mainMenu.touchpressed(id, x, y, dx, dy, pressure)
    local transformedX = (x - SETTINGS.DISPLAY.OFFSETX) / SETTINGS.DISPLAY.SCALE
    local transformedY = (y - SETTINGS.DISPLAY.OFFSETY) / SETTINGS.DISPLAY.SCALE

    -------------------------------------------
    -- Code from here
    -------------------------------------------
end

function mainMenu.touchreleased(id, x, y, dx, dy, pressure)
    local transformedX = (x - SETTINGS.DISPLAY.OFFSETX) / SETTINGS.DISPLAY.SCALE
    local transformedY = (y - SETTINGS.DISPLAY.OFFSETY) / SETTINGS.DISPLAY.SCALE

    -------------------------------------------
    -- Code from here
    -------------------------------------------

end

function mainMenu.keypressed(key, scancode, isrepeat)
    -------------------------------------------
    -- Code from here
    -------------------------------------------

    if key == "w" then
        if debugText then print("W key pressed - moving up") end
    end

    if key == "a" then
        if debugText then print("A key pressed - moving left") end
    end

    if key == "s" then
        if debugText then print("S key pressed - moving down") end
    end

    if key == "d" then
        if debugText then print("D key pressed - moving right") end
    end

    if key == "space" then
        if debugText then print("Space key pressed - action") end
    end

    if key == "escape" then
        love.event.quit()
    end
end

function mainMenu.keyreleased(key, scancode)
    -------------------------------------------
    -- Code from here
    -------------------------------------------
    if key == "w" then
        if debugText then print("W key released") end
    end

    if key == "a" then
        if debugText then print("A key released") end
    end

    if key == "s" then
        if debugText then print("S key released") end
    end

    if key == "d" then
        if debugText then print("D key released") end
    end

    if key == "space" then
        if debugText then print("Space key released") end
    end

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


return mainMenu
