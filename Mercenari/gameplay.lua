local gameplay = {}
local stateMachineRef = nil

--------------------------------------------------
-- REQUIRE
--------------------------------------------------
local Player = require("player")
local sti = require("Libraries/sti")
local camera = require("Libraries/camera")
local wf = require("Libraries/windfield")
local bf = require("Libraries/breezefield")
local Pause = require("pause")
--------------------------------------------------

--------------------------------------------------
-- VARIABLES
--------------------------------------------------
local debugText = true
local ispause = false
local player = nil
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
function gameplay.enter(stateMachine)
    stateMachineRef = stateMachine
    
    cam = camera()
    map = sti('Assets/Maps/TestMap4.lua')
    world = wf.newWorld(0, 200, true)

    
    player = Player.new({x = 100,y = 200, speed = 100, collider = world:newBSGRectangleCollider(100, 200, 25, 25, 2)})
    if player then 
        player:load() 
        player.collider:setFixedRotation(true)
    end
    platforms = {}
    if map.layers["Platform"] then
        for i, obj in pairs(map.layers["Platform"].objects) do
            local platform = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)--[[bf.Collider.new(world, "Polygon", {obj.x, obj.y, obj.x + obj.width, obj.height, obj.x, obj.y + obj.height})]] 
            platform:setType("static")
            table.insert(platforms, platform)
        end
    end
    
end

function gameplay.update(dt)
    if ispause then
        Pause:load()
        Pause:update(dt)
    else
        world:update(dt)
        if player then 
            player.x = player.collider:getX()
            player.y = player.collider:getY()
            player:update(dt) 
        
            cam:lookAt(player.x, player.y)
        end
    end

end

function gameplay.draw()
    -- Draw the game here
    cam:attach()
        love.graphics.setColor(1, 1, 1)
        map:drawLayer(map.layers["Background"])
        map:drawLayer(map.layers["Block"])

        
        
        if player then
            player:draw() 
        end

        world:draw()

    cam:detach()

    if ispause then
        Pause:draw()
    end
end
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
---
function  gameplay.keypressed(key, scancode, isrepeat)
    
    if key == "space"  then
        if player then
            

                player.isJump = true
           
        end
       
    end
end

function gameplay.keyreleased(key, scancode)
   
    if key == "escape" then
        ispause = not ispause
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

return gameplay