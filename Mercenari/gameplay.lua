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
    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')

    
    player = Player.new({x = 100,y = 200, speed = 100, collider = world:newBSGRectangleCollider(100, 200, 25, 25, 2)})
    if player then 
        player:load() 
        player.collider:setFixedRotation(true)
        player.collider:setCollisionClass("Player")
    end
    platforms = {}
    if map.layers["Platform"] then
        for i, obj in pairs(map.layers["Platform"].objects) do
            local platform = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)--[[bf.Collider.new(world, "Polygon", {obj.x, obj.y, obj.x + obj.width, obj.height, obj.x, obj.y + obj.height})]] 
            platform:setType("static")
            platform:setCollisionClass("Platform")
            table.insert(platforms, platform)
        end
    end

    player.collider:setPreSolve(function(collider_1, collider_2, contact)
    if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
        
        local px, py = collider_1:getPosition()
        local pw, ph = 25, 25 -- usa le dimensioni reali del player
        local tx, ty = collider_2:getPosition()
        local tw, th = collider_2:getObject() and collider_2:getObject().width or 0, collider_2:getObject() and collider_2:getObject().height or 0
        -- Se il player è sopra la piattaforma
        if py + ph/2 <= ty - th/2 + 5 then
            player.isGrounded = true
        else    
            player.isGrounded = false
        end
    end
end)

player.collider:setPostSolve(function(collider_1, collider_2, contact, normalimpulse, tangentimpulse)
    if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
        player.grounded = false
    end
end)
    
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
                player.isGrounded = false
           
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