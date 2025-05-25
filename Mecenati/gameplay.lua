local gameplay = {}
local stateMachineRef = nil

--------------------------------------------------
-- REQUIRE
--------------------------------------------------
local anim8 =require("Libraries/anim8")
local Player = require("player")
local sti = require("Libraries/sti")
local camera = require("Libraries/camera")
local wf = require("Libraries/windfield")
local Pause = require("pause")
local EnemyManager = require("enemyManager")
--------------------------------------------------

--------------------------------------------------
-- VARIABLES
--------------------------------------------------
local debugText = true
local ispause = false
local player = nil
local enemy_ghost = nil
local enemyManager = nil

local UI_PLAYER_image,UI_PLAYER_animation,UI_PLAYER_grid
local UI_LP_image,UI_LP_animation,UI_LP_grid


--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
function gameplay.enter(stateMachine)

    UI_PLAYER_image = love.graphics.newImage("Assets/Sprites/UI/iconUI.png")
    UI_PLAYER_grid = anim8.newGrid(123, 108, UI_PLAYER_image:getWidth(), UI_PLAYER_image:getHeight())
    UI_PLAYER_animation = anim8.newAnimation(UI_PLAYER_grid('1-5', 1), 0.2)

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
    world = wf.newWorld(0, 500, true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('PlayerAttack', {ignores = {'Player'}})
    world:addCollisionClass('Enemy', {ignores = {'Player'}})
    world:addCollisionClass('EnemyAttack', {ignores = {'Enemy'}})

    if map.layers["PlayerSpawn"] then
        for i, obj in pairs(map.layers["PlayerSpawn"].objects) do
            player = Player.new({x = obj.x,y = obj.y, speed = 150})
        end
    end
    
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

    enemyManager = EnemyManager.new()
    if enemyManager then
        enemyManager:load()
    end
    player.collider:setPreSolve(function(collider_1, collider_2, contact)

    if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
        if player.jumpBuffer <= 0 then
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
        if enemyManager then
            enemyManager:update(dt, player)
        end
    end

    UI_PLAYER_animation:update(dt)

end

function gameplay.draw()
    -- Draw the game here
    

    cam:attach()

        

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill",0 ,-1000 ,10000, 10000)

        love.graphics.draw(mappa, -1000, -540)
        --map:drawLayer(map.layers["Background"])
        map:drawLayer(map.layers["Block"])

        
        
        if player then
            player:draw() 
        end

        if enemyManager then
            enemyManager:draw()
        end

        world:draw()

    cam:detach()

    UI_PLAYER_animation:draw(UI_PLAYER_image, 10, 10)

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
    if player then
        player:keypressed(key, scancode, isrepeat)
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