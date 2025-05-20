local gameplay = {}
local stateMachineRef = nil

--------------------------------------------------
-- REQUIRE
--------------------------------------------------
local Player = require("player")
local sti = require("Libraries/sti")
local camera = require("Libraries/camera")
local wf = require("Libraries/windfield")
local Pause = require("pause")
local Enemy = require("enemy")
--------------------------------------------------

--------------------------------------------------
-- VARIABLES
--------------------------------------------------
local debugText = true
local ispause = false
local player = nil
local enemy = nil
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
function gameplay.enter(stateMachine)
    stateMachineRef = stateMachine
    Pause.load({
        onResume = function()
            ispause = false
        end,
        onMainMenu = function()
            ispause = false
            if stateMachineRef then
                stateMachineRef.changeState("mainMenu")
            else
                print("Error: state_machine_ref is nil")
            end
        end
    })
    cam = camera()

    map = sti('Assets/Maps/MappaProva5.lua')
    world = wf.newWorld(0, 700, true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('PlayerAttack', {ignores = {'Player'}})
    world:addCollisionClass('Enemy')
    world:addCollisionClass('EnemyAttack', {ignores = {'Enemy'}})

    
    player = Player.new({x = 100,y = -150, speed = 150})
    if player then 
        player:load() 
        player.collider:setFixedRotation(true)
        player.collider:setCollisionClass("Player")
    end
    platforms = {}
    if map.layers["Platform"] then
        for i, obj in pairs(map.layers["Platform"].objects) do
            local platform = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            platform:setType("static")
            platform:setCollisionClass("Platform")
            table.insert(platforms, platform)
        end
    end

    enemy = Enemy.new({x = 300, y = 200, speed = 100})
    if enemy then 
        enemy:load() 
    end

    player.collider:setPreSolve(function(collider_1, collider_2, contact)

    if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
        local px, py = collider_1:getPosition()  -- posizione del player.collider
        local pw, ph = 25, 25 -- usa le dimensioni reali del player
        local tx, ty = collider_2:getPosition() -- posizione della piattaforma
        local tw, th = collider_2:getObject() and collider_2:getObject().width or 0, collider_2:getObject() and collider_2:getObject().height or 0  -- dimensioni della piattaforma
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

player.attackCollider:setPreSolve(function(collider_1, collider_2, contact)
    if collider_1.collision_class == 'PlayerAttack' and collider_2.collision_class == 'Enemy' then
       if not player.attackHasHit then
            --Logica attacco Nemico
            player.attackHasHit = true
        end
    end
end)
    mappa = love.graphics.newImage("Assets/Maps/background_1_livello.png")
   -- map:resize(love.graphics.getWidth(), love.graphics.getHeight())
   -- map:drawLayer(map.layers["Background"])
   -- map:drawLayer(map.layers["Block"])
   -- cam:lookAt(player.x, player.y)
    
end

function gameplay.update(dt)
    if ispause then
        
        Pause:update(dt)
    else
        world:update(dt)
        if player then 
            player.x = player.collider:getX()
            player.y = player.collider:getY()
            player:update(dt) 
        
            cam:lookAt(player.x, player.y)
        end
        if enemy then 
            enemy.x = enemy.collider:getX()
            enemy.y = enemy.collider:getY()
            enemy:update(dt, player)
        end
    end

end

function gameplay.draw()
    -- Draw the game here
    cam:attach()

        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill",0 ,-1000 ,10000, 10000)

        love.graphics.draw(mappa, -1000, -540)
        --map:drawLayer(map.layers["Background"])
        map:drawLayer(map.layers["Block"])

        
        
        if player then
            player:draw() 
        end

        if enemy then
            enemy:draw()
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

function gameplay.mousemoved(x, y, dx, dy, istouch)
    Pause.mousemoved(x, y, dx, dy, istouch)
end

function gameplay.mousepressed(x, y, button, istouch, presses)
    if ispause then
        Pause.mousepressed(x, y, button, istouch, presses)
    end
    if player then
        player:mousepressed(x, y, button, istouch, presses)
    end

end

function gameplay.mousereleased(x, y, button, istouch, presses)
    Pause.mousereleased(x, y, button, istouch, presses)
end
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