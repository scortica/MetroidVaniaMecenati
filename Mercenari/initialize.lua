local initialize = {}

require("globals")

function initialize.enter(stateMachine)

    -- Detect the operating system
    local os = love.system.getOS()

    -- On mobile
    if os == 'iOS' or os == 'Android' then

        -- Fullscreen on mobile
        SETTINGS.DISPLAY.FULLSCREEN = true
        SETTINGS.DISPLAY.RESIZABLE = true
        SETTINGS.DISPLAY.BORDERLESS = true

    -- On desktop
    else
        SETTINGS.DISPLAY.FULLSCREEN = false
        SETTINGS.DISPLAY.RESIZABLE = false
        SETTINGS.DISPLAY.BORDERLESS = false
    end

    -- Check DPI
    if love.graphics.getDPIScale() > 1 then
        SETTINGS.DISPLAY.HIGHDPI = true
    end

    -- Set the window mode
    love.window.setMode(SETTINGS.DISPLAY.WIDTH, SETTINGS.DISPLAY.HEIGHT, {
        fullscreen = SETTINGS.DISPLAY.FULLSCREEN,
        resizable = SETTINGS.DISPLAY.RESIZABLE,
        borderless = SETTINGS.DISPLAY.BORDERLESS,
        vsync = SETTINGS.DISPLAY.VSYNC,
        display = SETTINGS.DISPLAY.DISPLAY,
        minwidth = SETTINGS.DISPLAY.MINWIDTH,
        minheight = SETTINGS.DISPLAY.MINHEIGHT,
        highdpi = SETTINGS.DISPLAY.HIGHDPI
    })

    love.graphics.setDefaultFilter("nearest", "nearest")

    stateMachine.changeState("mainMenu")
end

function initialize.update(dt)

end

function initialize.draw()
    love.graphics.clear(0, 0, 0, 0)
end

function initialize.exit()
    os = nil
end

return  initialize