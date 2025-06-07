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
local Keybinds = require("keybinds")
local EnemyManager = require("enemyManager")
local DeadScreen = require("deadScreen")
local CameraAnchor = require("cameraAnchor")
--------------------------------------------------

--------------------------------------------------
-- VARIABLES
--------------------------------------------------
local debugText = true
local ispause = false
local iskeybind = false
local player = nil
local enemyManager = nil
local anchor = nil
local initialSpawn = nil
local checkpointSpawn = {}
local savedCheckpoint = nil

hitFreezeTimer = 0
hitFreezeDuration = 0.08
camShakeTime = 0
camShakeDuration = 0.15 -- seconds
camShakeMagnitude = 12 --pixels

local UI_PLAYER_image,UI_PLAYER_animation,UI_PLAYER_grid
local UI_LP_image,UI_LP_animation,UI_LP_grid
local UI_Cross_image,UI_Cross_animation,UI_Cross_grid
local UI_HealingAvailable

-- Stato animazione boccette LP
local lpBottles = {}
local lastPlayerLp = nil
local bottleAnimDuration = 0.25 -- durata animazione svuotamento (in secondi)

local keyObject = nil
local keySprite = love.graphics.newImage("Assets/Sprites/player.png")
local doorCollider = nil
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI 
--------------------------------------------------
---
function gameplay.reset()
    player = nil
    world = nil
    map = nil
    enemyManager = nil
    cam = nil
    anchor = nil
    initialSpawn = nil
    checkpointSpawn = nil
    lastPlayerLp = nil
    lpBottles = {}

end

local function checkPlayerCheckpoint()
    if checkpointSpawn and player then
        local dx = player.x - checkpointSpawn.x
        local dy = player.y - checkpointSpawn.y
        if math.abs(dx) < 50 and math.abs(dy) < 10000 then -- 32 is the checkpoint "radius"
            savedCheckpoint = {x = checkpointSpawn.x, y = checkpointSpawn.y + 64}
            checkpointSpawn = nil
        end
    end
end
--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
function gameplay.enter(stateMachine)

    UI_HealingAvailable=love.graphics.newImage("Assets/Sprites/UI/Healing.png")

    UI_PLAYER_image = love.graphics.newImage("Assets/Sprites/UI/iconUI.png")
    UI_PLAYER_grid = anim8.newGrid(123, 108, UI_PLAYER_image:getWidth(), UI_PLAYER_image:getHeight())
    UI_PLAYER_animation = anim8.newAnimation(UI_PLAYER_grid('1-5', 1), 0.2)

    UI_Cross_image = love.graphics.newImage("Assets/Sprites/UI/crossUI.png")
    UI_Cross_grid = anim8.newGrid(112, 128, UI_Cross_image:getWidth(), UI_Cross_image:getHeight())
    UI_Cross_animation = anim8.newAnimation(UI_Cross_grid(16, 1), 1)

    UI_LP_image = love.graphics.newImage("Assets/Sprites/UI/lpUI.png")
    UI_LP_grid = anim8.newGrid(16, 16, UI_LP_image:getWidth(), UI_LP_image:getHeight())
    UI_LP_animation = anim8.newAnimation(UI_LP_grid('1-5', 1), 1)

    --------------------------------------------------

    stateMachineRef = stateMachine
    Pause.load({
        onResume = function()
            ispause = false
            iskeybind = false
        end,
        onMainMenu = function()
            ispause = false
            iskeybind = false
            if stateMachineRef then
                gameplay.reset()
                stateMachineRef.changeState("mainMenu")
            else
                print("Error: state_machine_ref is nil")
            end
        end,
        onKeybinds = function()
            ispause = true
            iskeybind = true
        end,
    })

    Keybinds.load({
        onPause = function()
            ispause = true
            iskeybind = false
        end,
        onResume = function ()
            ispause = false
            iskeybind = false
        end
    })

    DeadScreen.load({
        onMainMenu = function()
            if stateMachineRef then
                gameplay.reset()
                stateMachineRef.changeState("mainMenu")
            else
                print("Error: state_machine_ref is nil")
            end
        end,

        onRetry = function()
            if stateMachineRef then
                -- Save the last checkpoint before resetting
                gameplay.reset()
                gameplay.enter(stateMachineRef)
            else
                print("Error: state_machine_ref is nil")
            end
        end
    })

    
    --------------------------------------------------
    

    cam = camera()

    map = sti('Assets/Maps/Mappa.lua')
    world = wf.newWorld(0, 500, true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('PlayerAttack', {ignores = {'Player', 'Platform'}})
    world:addCollisionClass('PlayerParry', {ignores = {'Player' , 'PlayerAttack', 'Platform'}})
    world:addCollisionClass('Enemy', {ignores = {'Player', 'PlayerParry', 'Enemy'}})
    world:addCollisionClass('EnemyAttack', {ignores = {'Enemy', 'PlayerAttack', 'EnemyAttack'}})


    

    if map.layers["PlayerSpawn"] then
        for i, obj in pairs(map.layers["PlayerSpawn"].objects) do
            if obj.name == "Spawn" then
                initialSpawn = {x = obj.x, y = obj.y}
            elseif obj.name == "CheckPoint" then
                checkpointSpawn = {x = obj.x, y = obj.y}
            end
        end
    end

    local spawn = initialSpawn
    if savedCheckpoint then
        spawn = savedCheckpoint
    end
    if spawn then
        player = Player.new({x = spawn.x, y = spawn.y, speed = 150})
        player:load()
        player.lp = 5
        player.isDead = false
        player.lastCheckpoint = {x = spawn.x, y = spawn.y}
    end
    
   
    platforms = {}
    if map.layers["Platform"] then
        for i, obj in pairs(map.layers["Platform"].objects) do
            local platform = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            platform:setType("static")
            platform:setCollisionClass("Platform")
            if obj.name == "Door" then
                doorCollider = platform
            end
            table.insert(platforms, platform)
        end
    end

    if map.layers["Key"] then
        for _, obj in ipairs(map.layers["Key"].objects) do
            if obj.name == "Key" then
                keyObject = {x = obj.x, y = obj.y, width = obj.width or 32, height = obj.height or 32, collected = false}
            end
        end
    end

    if player then
        anchor = CameraAnchor.new(player.x, player.y, 3)
    end
    

    --------------------------------------------------

    enemyManager = EnemyManager.new()
    if enemyManager then
        enemyManager:load()
    end

    --------------------------------------------------
    
    -- Inizializza lpBottles
    lpBottles = {}
    if player and player.maxLp then
        for i = 1, player.maxLp do
            lpBottles[i] = {state = "idle", frame = 5, timer = 0}
        end
        lastPlayerLp = player.lp
    end
end




function gameplay.update(dt)
    print(savedCheckpoint)
    if player and not player.isDead then
        checkPlayerCheckpoint()
         if hitFreezeTimer > 0 then
            hitFreezeTimer = hitFreezeTimer - dt
            return -- skip updates during freeze
        end
        if ispause then
            if ispause then
                Pause:update(dt)
            end
            
            if iskeybind then
                Keybinds:update(dt)
            end
            return
        else
            world:update(dt)
            if player and anchor then 
                if player.healing then
                local maxCross = 16 - player.crossPoints - 4
                local minCross = maxCross + 4
                UI_Cross_animation = anim8.newAnimation(UI_Cross_grid(maxCross .. "-" .. minCross, 1), 1)
            else
                UI_Cross_animation = anim8.newAnimation(UI_Cross_grid(16-player.crossPoints, 1), 1)
            end
                player:update(dt) 
                anchor:update(dt, player.x, player.y)
                local shakeX, shakeY = 0, 0
                if camShakeTime > 0 then
                    camShakeTime = camShakeTime - dt
                    shakeX = love.math.random(-camShakeMagnitude, camShakeMagnitude)
                    shakeY = love.math.random(-camShakeMagnitude, camShakeMagnitude)
                end
                cam:lookAt(anchor.x + shakeX, anchor.y + shakeY)

                if cam.x < SETTINGS.DISPLAY.WIDTH/2 then
                    cam.x = SETTINGS.DISPLAY.WIDTH/2
                end
                if cam.y < SETTINGS.DISPLAY.HEIGHT/2 then
                    cam.y = SETTINGS.DISPLAY.HEIGHT/2
                end
                if cam.x > map.width * map.tilewidth - SETTINGS.DISPLAY.WIDTH/2 then
                    cam.x = map.width * map.tilewidth - SETTINGS.DISPLAY.WIDTH/2
                end
                if cam.y > map.height * map.tileheight - SETTINGS.DISPLAY.HEIGHT/2 then
                    cam.y = map.height * map.tileheight - SETTINGS.DISPLAY.HEIGHT/2
                end
            end
            if enemyManager then
                enemyManager:update(dt, player)
            end
        end

        
        
        UI_Cross_animation:update(dt)
        UI_PLAYER_animation:update(dt)
        UI_LP_animation:update(dt)
        UI_Cross_animation:update(dt)

        -- Aggiorna animazione boccette LP
        if player and player.maxLp and player.lp and lpBottles then
            -- Se il player ha perso vita
            if lastPlayerLp and player.lp < lastPlayerLp then
                for i = player.lp + 1, lastPlayerLp do
                    if lpBottles[i] then
                        lpBottles[i].state = "draining"
                        lpBottles[i].frame = 5
                        lpBottles[i].timer = 0
                    end
                end
            end
            -- Se il player ha guadagnato vita, anima la boccetta da vuota a piena
            if lastPlayerLp and player.lp > lastPlayerLp then
                for i = lastPlayerLp + 1, player.lp do
                    if lpBottles[i] then
                        lpBottles[i].state = "filling"
                        lpBottles[i].frame = 1
                        lpBottles[i].timer = 0
                    end
                end
            end
            lastPlayerLp = player.lp
            -- Aggiorna animazione svuotamento e riempimento
            for i = 1, player.maxLp do
                local bottle = lpBottles[i]
                if bottle then
                    if bottle.state == "draining" then
                        bottle.timer = bottle.timer + dt
                        local progress = math.min(bottle.timer / bottleAnimDuration, 1)
                        -- Frame da 5 (pieno) a 1 (vuoto)
                        bottle.frame = math.max(1, math.floor(5 - 4 * progress + 0.5))
                        if progress >= 1 then
                            bottle.state = "idle"
                            bottle.frame = 1
                        end
                    elseif bottle.state == "filling" then
                        bottle.timer = bottle.timer + dt
                        local progress = math.min(bottle.timer / bottleAnimDuration, 1)
                        -- Frame da 1 (vuoto) a 5 (pieno)
                        bottle.frame = math.min(5, math.floor(1 + 4 * progress + 0.5))
                        if progress >= 1 then
                            bottle.state = "idle"
                            bottle.frame = 5
                        end
                    end
                end
            end
        end
        if keyObject and not keyObject.collected then
            local px, py = player.x, player.y
            -- Simple AABB collision
            if px + player.width > keyObject.x and px < keyObject.x + keyObject.width and
            py + player.height > keyObject.y and py < keyObject.y + keyObject.height then
                keyObject.collected = true
                player.isKey = true
            end
        elseif keyObject and doorCollider then
            doorCollider:destroy()
            doorCollider = nil
        end
    else
        if player and player.isDead then
            if stateMachineRef then
                DeadScreen.update(dt)
            else
                print("Error: stateMachineRef is nil")
            end
        end
    end
end

function gameplay.draw()
    -- Draw the game here
    
    if player and not player.isDead then
        cam:attach()
        love.graphics.setColor(1,1,1)

        
        ----------------- BG DRAW ---------------------
            map:drawLayer(map.layers["bg"])
            map:drawLayer(map.layers["cimitero1"])
            map:drawLayer(map.layers["chapel"])
            map:drawLayer(map.layers["cimitero2"])
            map:drawLayer(map.layers["città1"])
            map:drawLayer(map.layers["città2"])

        --------------------------------------------------     
        ----------------- LAYER DRAW ---------------------
            map:drawLayer(map.layers["Bloc_BG2"])
            map:drawLayer(map.layers["Block_BG"])
            map:drawLayer(map.layers["Block"])

            if keyObject and not keyObject.collected then
                map:drawLayer(map.layers["Door"])
                love.graphics.draw(keySprite, keyObject.x, keyObject.y)
             end
-------------------------------------------------
           


            if player and not player.isDead then
                player:draw() 
            end
                
            if enemyManager then
                enemyManager:draw()
            end

            map:drawLayer(map.layers["Church"])
            world:draw()

        cam:detach()

        UI_PLAYER_animation:draw(UI_PLAYER_image, 10, 10, 0, 1.5, 1.5)

        UI_Cross_animation:draw(UI_Cross_image, 30, 160, 0 ,1.5, 1.5)

        if player.crossPoints>=4 then
            love.graphics.draw(UI_HealingAvailable, 30, 400)
        end

        -- Disegna le boccette LP con animazione
        if player and player.maxLp and lpBottles then
            for i = 1, player.maxLp do
                local bottle = lpBottles[i]
                if bottle then
                    UI_LP_animation:gotoFrame(bottle.frame)
                    UI_LP_animation:draw(UI_LP_image, 190 + (40 * i), 75, 0, 2, 2)
                end
            end
        end

        if ispause and not iskeybind then
            Pause:draw()
        end

        if iskeybind then
            Keybinds:draw()
        end

    else if player and player.isDead then
        DeadScreen.draw()
        end
    end

end


--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
---

function gameplay.mousemoved(x, y, dx, dy, istouch)
    if ispause then
        Pause.mousemoved(x, y, dx, dy, istouch)
    end
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
    if ispause then
        Pause.mousereleased(x, y, button, istouch, presses)
    end
end
function  gameplay.keypressed(key, scancode, isrepeat)
    if player then
        player:keypressed(key, scancode, isrepeat)
    end
    
end

function gameplay.keyreleased(key, scancode)
   
    if key == "escape" then
        if iskeybind then
            iskeybind = false
        else 
            ispause = not ispause
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

return gameplay