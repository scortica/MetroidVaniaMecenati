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
local DeadScreen = require("deadScreen")
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
local UI_Cross_image,UI_Cross_animation,UI_Cross_grid

-- Stato animazione boccette LP
local lpBottles = {}
local lastPlayerLp = nil
local bottleAnimDuration = 0.25 -- durata animazione svuotamento (in secondi)

--------------------------------------------------

--------------------------------------------------
-- FUNZIONI 
--------------------------------------------------

--------------------------------------------------
-- FUNZIONI LOVE
--------------------------------------------------
function gameplay.enter(stateMachine)

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

    DeadScreen.load({
        onMainMenu = function()
            if stateMachineRef then
                stateMachineRef.changeState("mainMenu")
            else
                print("Error: state_machine_ref is nil")
            end
        end,

        onRetry = function()
            if stateMachineRef then
                gameplay.enter(stateMachineRef)
            else
                print("Error: state_machine_ref is nil")
            end
        end
    })

    --------------------------------------------------
    

    cam = camera()

    map = sti('Assets/Maps/mappa.lua')
    world = wf.newWorld(0, 500, true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('PlayerAttack', {ignores = {'Player', 'Platform'}})
    world:addCollisionClass('PlayerParry', {ignores = {'Player' , 'PlayerAttack', 'Platform'}})
    world:addCollisionClass('Enemy', {ignores = {'Player', 'PlayerParry', 'Enemy'}})
    world:addCollisionClass('EnemyAttack', {ignores = {'Enemy', 'PlayerAttack', 'EnemyAttack'}})

    if map.layers["PlayerSpawn"] then
        for i, obj in pairs(map.layers["PlayerSpawn"].objects) do
            player = Player.new({x = obj.x,y = obj.y, speed = 150})
        end
    end
    
    if player then 
        player:load() 
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

    --------------------------------------------------

    enemyManager = EnemyManager.new()
    if enemyManager then
        enemyManager:load()
    end

    --------------------------------------------------
   
    mappa = love.graphics.newImage("Assets/Maps/Background/Background_1.png")
   -- map:resize(love.graphics.getWidth(), love.graphics.getHeight())
   -- map:drawLayer(map.layers["Background"])
   -- map:drawLayer(map.layers["Block"])
   -- cam:lookAt(player.x, player.y)
    
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
    if player and not player.isDead then
        if ispause then
            
            Pause:update(dt)
        else
            world:update(dt)
            if player then 
                if player.healing then
                local maxCross = 16 - player.crossPoints - 4
                local minCross = maxCross + 4
                UI_Cross_animation = anim8.newAnimation(UI_Cross_grid(maxCross .. "-" .. minCross, 1), 1)

                player.healing = false
            else
                UI_Cross_animation = anim8.newAnimation(UI_Cross_grid(16-player.crossPoints, 1), 1)
            end
                player:update(dt) 
                cam:lookAt(player.x, player.y)
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
            --love.graphics.rectangle("fill",0 ,-1000 ,10000, 10000)

            love.graphics.draw(mappa, 0, -369)  --490
            --love.graphics.draw(mappa, 2000, -369)
            --love.graphics.draw(mappa, 4000, -369)
            --map:drawLayer(map.layers["Background"])
            map:drawLayer(map.layers["Block"])



            if player and not player.isDead then
                player:draw() 
            end

            if enemyManager then
                enemyManager:draw()
            end

            world:draw()

        cam:detach()

        UI_PLAYER_animation:draw(UI_PLAYER_image, 10, 10, 0, 1.5, 1.5)

        UI_Cross_animation:draw(UI_Cross_image, 30, 160, 0 ,1.5, 1.5)

        -- Disegna le boccette LP con animazione
        if player and player.maxLp and lpBottles then
            for i = 1, player.maxLp do
                local bottle = lpBottles[i]
                if bottle then
                    UI_LP_animation:gotoFrame(bottle.frame)
                    UI_LP_animation:draw(UI_LP_image, 20 + (30 * i), SETTINGS.DISPLAY.HEIGHT - 100, 0, 2, 2)
                end
            end
        end

        if ispause then
            Pause:draw()
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