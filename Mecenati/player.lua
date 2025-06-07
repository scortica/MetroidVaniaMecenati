local Player = {}

Player.__index = Player
require("globals")

local anim8 =require("Libraries/anim8")
local image,animation,grid


function Player.new(params)
    local self = setmetatable({}, Player)

    params = params or {}

    -- esempi di parametri o valori preimportati
    self.x = params.x or 800
    self.y = params.y or 500
    self.lastCheckpoint = nil
    self.dx = "Right"
    self.width = params.width or 128
    self.height = params.height or 256
    self.speed = params.speed or 3
    self.gravity = 110
    self.crossPoints = 0
    self.scale = params.scale or 1
    self.defaultSpeed = self.speed
    self.lp= params.lp or 5
    self.maxLp = 5
    self.isDead = false
    self.healing = false
    self.healTimer = 0

    self.jumpNum = 0
    self.jumpResetTime = 0.095
    self.collider = world:newBSGRectangleCollider(params.x, params.y, 64, 128, 2)  -- collider del player windfield
    self.isGrounded = false

    self.spriteSheetPath = {idle='Assets/Sprites/player/player_r_idle_sheet.png',
                            walk='Assets/Sprites/player/player_r_run_sheet.png',
                            attack='Assets/Sprites/player/player_r_atk_sheet.png',
                            jump='Assets/Sprites/player/player_r_jump_sheet.png',
                            parry='Assets/Sprites/player/player_r_parry_sheet.png',
                            heal='Assets/Sprites/player/player_r_heal_sheet.png'
                        }
    self.playerSprite = nil
    self.currentAnimation = nil

    self.isAttacking = false
    self.attackHasHit = false
    self.attackTimer = 0
    self.attackDuration = 0.5
    self.attackCollider = world:newRectangleCollider(params.x, params.y, 175, 75) -- collider dell'attacco windfield

    self.parryCollider = world:newRectangleCollider(params.x, params.y, 32 , 128)
    self.parry = false
    self.parryTimer = 0
    self.parryCooldown = 0.5

    self.attackDamage = params.attackDamage or 1
    self.hitted = false
    self.hitTimer = 0
    self.hitCooldown = 0.5

    self.knockbackPending = false
    self.knockbackDir = 0
    self.knockbackStrength = 6000 -- adjust as needed
    self.knockbackUp = -3000 


    self.isWalking = false
    self.isJump = false
    self.jumpBuffer = 0
    self.jumpState = "idle"
    self.apexTimer = 0
    self.succParry = false

    self.collider:setObject(self)
    
    return self
end

local debugText = true

function Player:mousepressed(x, y, button, istouch, presses)

    -- Se il player non è in attacco e il tasto sinistro del mouse è premuto
    -- attiva l'attacco e resetta il timer dell'attacco
    if button == 1 and not self.isAttacking then -- Left mouse button
        self.isAttacking = true
        self.attackHasHit = false

        self.attackTimer = 0

        self.currentAnimation = self.playerSprite.attack

        if self.dx == "Right" then

            self.currentAnimation.animation_r:gotoFrame(2)
            self.currentAnimation.animation_r:resume()
            
            
        elseif self.dx == "Left" then

            self.currentAnimation.animation_l:gotoFrame(2)
            self.currentAnimation.animation_l:resume()
            
      
        end
    end
    if button == 2 then
       self.parry = true
        self.parryTimer = 0
        -- Reset parry animation to frame 1
        self.currentAnimation = self.playerSprite.parry
        if self.dx == "Right" then
            self.currentAnimation.animation_r:gotoFrame(1)
            self.currentAnimation.animation_r:resume()
        elseif self.dx == "Left" then
            self.currentAnimation.animation_l:gotoFrame(1)
            self.currentAnimation.animation_l:resume()
        end
    end
    -- Se il tasto destro del mouse è premuto,
    --------------------------------IMPLEMENTARE LOGICA PARRY---------------------------------------
    if button == 2 then -- Right mouse button
        -- parry logic here  
    end
end

function Player:heal()
    if self.lp < self.maxLp and not self.healing then
        if self.crossPoints >= 4 then
            self.healing = true
            self.healTimer = 0
            self.lp = self.lp + 1
            self.crossPoints = self.crossPoints - 4
        end
    end
end

function Player:chargeCross()
    if self.crossPoints < 15 then
        self.crossPoints = self.crossPoints + 1
    end
end

function Player:gotHit(damage)
    self.lp = self.lp - damage
    if self.lp<=0 then
        self.isDead = true
    end
end

-----------------------------------------------------------------------------------------------
---------------------------------FUNZIONI LOVE-------------------------------------------------


---------------------------------------LOAD----------------------------------------------------

function Player:load()


    -- Inizzializzi i vari collider del player, dell'attacco e del parry
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass("Player")
    self.attackCollider:setType("dynamic")
    self.attackCollider:setFixedRotation(true)
    self.attackCollider:setGravityScale(0)
    self.attackCollider:setCollisionClass("PlayerAttack")
    self.attackCollider:setActive(false)
    self.parryCollider:setType("dynamic")
    self.parryCollider:setFixedRotation(true)
    self.parryCollider:setGravityScale(0)
    self.parryCollider:setCollisionClass("PlayerParry")
    self.parryCollider:setActive(true)

    --Verifica se il player si trova a terra o meno
    self.collider:setPreSolve(function(collider_1, collider_2, contact)
        if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
            if self.jumpBuffer <= 0 then
                local px, py = collider_1:getPosition()  -- posizione del player.collider
                local pw, ph = 25, 25 -- usa le dimensioni reali del player
                local tx, ty = collider_2:getPosition() -- posizione della piattaforma
                local tw, th = collider_2:getObject() and collider_2:getObject().width or 0, collider_2:getObject() and collider_2:getObject().height or 0  -- dimensioni della piattaforma
                -- Se il player è sopra la piattaforma
                if py + ph/2 <= ty - th/2 + 5 then
                    self.isGrounded = true
                else
                    self.isGrounded = false
                end
            end
        -----------------------Player subisce attacco----------------------------------------------------------
        elseif collider_1.collision_class == 'Player' and collider_2.collision_class == 'EnemyAttack' then
            if not self.hitted then
                local enemyObj = collider_2:getObject()

                self.hitted = true
                if enemyObj == "EnemyGhost" then
                    enemyObj.attackHasHit = true
                    enemyObj.attackTimer = 0
                end
                
                self.hitTimer = 0
            

                self.lp = self.lp - 1
                if self.lp<=0 then
                    self.isDead = true
                end
                if enemyObj and enemyObj.x then
                    if enemyObj.x < self.x then
                        self.knockbackDir = 1   -- Enemy is to the left, knockback to the right
                    else
                        self.knockbackDir = -1  -- Enemy is to the right, knockback to the left
                    end
                else
                    -- fallback to previous logic if position is not available
                    self.knockbackDir = (self.dx == "Right") and -1 or 1
                end
                self.knockbackPending = true
                hitFreezeTimer = hitFreezeDuration + 0.1
                camShakeTime = camShakeDuration
            end
            
        end
    end)
     -- Se il player non è a terra, resetta il grounded
    self.collider:setPostSolve(function(collider_1, collider_2, contact, normalimpulse, tangentimpulse)
        if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then 
            self.grounded = false
        end
    end)
    -- Logica per l'attacco del player
    self.attackCollider:setPreSolve(function(collider_1, collider_2, contact)
        if collider_1.collision_class == 'PlayerAttack' and collider_2.collision_class == 'Enemy' then
            if not self.attackHasHit then
                self.attackHasHit = true
                local enemy = collider_2:getObject()

                enemy:gotHit(self.attackDamage)
                enemy:knockback(self.x)
                self:chargeCross()
                hitFreezeTimer = hitFreezeDuration
            end
        end
    end)

    
    -- Logica per il parry del player
    self.parryCollider:setPreSolve(function(parry, other, contact)
        if other.collision_class == "EnemyAttack" then
            if self.parry and not self.succParry then
                local object =  other:getObject()
                if object and object.getParried then
                    object:getParried()
                end
                self.succParry = true
                self:chargeCross()
            end
        end
    end)
    
    self.playerSprite = {
        idle = {
            sprite = love.graphics.newImage(self.spriteSheetPath.idle),
            grid= nil,
            animation_r = nil,
            animation_l = nil,
            frameN = 5
        },
        walk = {
            sprite = love.graphics.newImage(self.spriteSheetPath.walk),
            grid= nil,
            animation_r = nil,
            animation_l = nil,
            frameN = 8
        },
        attack ={
            sprite = love.graphics.newImage(self.spriteSheetPath.attack),
            grid= nil,
            animation_r = nil,
            animation_l = nil,
            frameN = 6
        },
        jump = {
            sprite = love.graphics.newImage(self.spriteSheetPath.jump),
            grid= nil,
            animation_r = nil,
            animation_l = nil,
            frameN = 9
        },
        parry = {
            sprite = love.graphics.newImage(self.spriteSheetPath.parry),
            grid= nil,
            animation_r = nil,
            animation_l = nil,
            frameN = 4
        },
        heal = {
            sprite = love.graphics.newImage(self.spriteSheetPath.heal),
            grid= nil,
            animation_r = nil,
            animation_l = nil,
            frameN = 7
        }
    }



    
    self.playerSprite.idle.grid = anim8.newGrid(139,131, self.playerSprite.idle.sprite:getWidth(), self.playerSprite.idle.sprite:getHeight())
    self.playerSprite.walk.grid = anim8.newGrid(139,131, self.playerSprite.walk.sprite:getWidth(), self.playerSprite.walk.sprite:getHeight())
    self.playerSprite.attack.grid = anim8.newGrid(260,131, self.playerSprite.attack.sprite:getWidth(), self.playerSprite.attack.sprite:getHeight())
    self.playerSprite.jump.grid = anim8.newGrid(152,128, self.playerSprite.jump.sprite:getWidth(), self.playerSprite.jump.sprite:getHeight())
    self.playerSprite.parry.grid = anim8.newGrid(180,135, self.playerSprite.parry.sprite:getWidth(), self.playerSprite.parry.sprite:getHeight())
    self.playerSprite.heal.grid = anim8.newGrid(139,131, self.playerSprite.heal.sprite:getWidth(), self.playerSprite.heal.sprite:getHeight())


    self.playerSprite.idle.animation_r = anim8.newAnimation(self.playerSprite.idle.grid('1-5', 1),0.3)
    self.playerSprite.walk.animation_r = anim8.newAnimation(self.playerSprite.walk.grid('1-8',1),0.15)
    self.playerSprite.attack.animation_r = anim8.newAnimation(self.playerSprite.attack.grid('1-6',1),0.1)
    self.playerSprite.jump.animation_r = anim8.newAnimation(self.playerSprite.jump.grid('2-9',1),0.15)
    self.playerSprite.parry.animation_r = anim8.newAnimation(self.playerSprite.parry.grid('1-4',1),0.1)
    self.playerSprite.heal.animation_r = anim8.newAnimation(self.playerSprite.heal.grid('1-7',1),0.15)

    self.playerSprite.idle.animation_l = anim8.newAnimation(self.playerSprite.idle.grid('1-5', 1),0.3):flipH()
    self.playerSprite.walk.animation_l = anim8.newAnimation(self.playerSprite.walk.grid('1-8',1),0.15):flipH()
    self.playerSprite.attack.animation_l = anim8.newAnimation(self.playerSprite.attack.grid('1-6',1),0.1):flipH()
    self.playerSprite.jump.animation_l = anim8.newAnimation(self.playerSprite.jump.grid('2-9',1),0.15):flipH()
    self.playerSprite.parry.animation_l = anim8.newAnimation(self.playerSprite.parry.grid('1-4',1),0.1):flipH()
    self.playerSprite.heal.animation_l = anim8.newAnimation(self.playerSprite.heal.grid('1-7',1),0.15):flipH()


    self.currentAnimation = self.playerSprite.idle

    end

-------------------------------------------------------------------------------------------------------
----------------------------------------UPDATE-----------------------------------------------------------

function Player:update(dt)
    self.x = self.collider:getX()
    self.y = self.collider:getY()
    local px, py = self.collider:getLinearVelocity()
    ------------------------------LOGICA ATTACCO---------------------------------------------------------
    -- Se il player è in attacco, attiva il collider dell'attacco
    -- e posizionalo in base alla direzione del player
    -- Se il player non è in attacco, disattiva il collider dell'attacco
    if self.isAttacking and not self.attackHasHit then
        if self.dx == "Left" then
            self.attackCollider:setPosition(self.x - 90, self.y)
        else
            self.attackCollider:setPosition(self.x + 90, self.y)
        end
        self.attackCollider:setActive(true)
    else
        self.attackCollider:setActive(false)
    end

    -- Se il player sta attaccando, incrementa il timer dell'attacco
    -- Se il timer dell'attacco supera la durata dell'attacco, disattiva l'attacco
    if self.isAttacking then
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer >= self.attackDuration then
            self.isAttacking = false
            self.attackCollider:setActive(false)
        end
    end
    -------------------------------------------------------------------------------------------------------
    ------------------------------LOGICA PARRY-------------------------------------------------------------
    if self.parry then
        self.parryTimer = self.parryTimer + dt
        if self.parryTimer >= self.parryCooldown then
            self.parry = false
            self.succParry = false
        end
    end

    ------------------------------ATTACCO SUBITO-----------------------------------------------------------
    
    if self.hitted then
        self.hitTimer = self.hitTimer + dt
        if self.hitTimer > self.hitCooldown then
            self.hitted = false
            self.hitTimer = 0
        end
    end

    if self.knockbackPending then
        self.collider:applyLinearImpulse(self.knockbackDir * self.knockbackStrength, self.knockbackUp)
        self.knockbackPending = false
    end

    -------------------------------------------------------------------------------------------------------
    ------------------------------LOGICA SALTO-------------------------------------------------------------
    -- Se il player è a terra, resetta il numero di salti
    if self.isGrounded then
        self.jumpNum = 0
    end
    
    -- Se il player salta (premendo la barra spaziatrice) e non ha superato il numero massimo di salti
    -- applica una forza verso l'alto al collider del player per farlo saltare
    -- altrimenti, non saltare
    if self.isJump then
        
        if self.jumpNum < 1 --[[and py > -30 and py < 30 ]]then
            self.collider:applyLinearImpulse(0, -10000)
            self.isGrounded = false
            self.jumpNum = self.jumpNum + 1
            self.jumpBuffer = 0.1 -- ignore ground for 0.1 seconds
        end
        self.isJump = false
    end

    if self.jumpBuffer > 0 then
        self.jumpBuffer = self.jumpBuffer - dt
    end

     if py < 0 then
        -- Going up: normal gravity
        self.collider:setGravityScale(1.75)
    elseif py > 0 then
        -- Falling: increase gravity for faster fall
        self.collider:setGravityScale(3)
    else
        -- On ground or not moving vertically
        self.collider:setGravityScale(1)
    end





    -------------------------------------------------------------------------------------------------------

    ------------------------------LOGICA MOVIMENTO---------------------------------------------------------
    -- Se premi "a" o "d", applica una forza al collider del player per muoverlo a sinistra o a destra
    -- Se non premi nessun tasto, applica una forza al collider del player per fermarlo


    if not self.healing then
        if love.keyboard.isDown("a") then
            if px >= -500 then
                self.collider:applyForce(-30000, 0)
                self.dx = "Left"
                self.isWalking = true
            end
        elseif love.keyboard.isDown("d")  then
            if  px <= 500 then
            
                self.collider:applyForce(30000, 0)
                self.dx = "Right"
                self.isWalking = true
            end
            
        elseif love.keyboard.isDown("a") or love.keyboard.isDown("d") then
            --VUOTO
        else
            if px > 0 then
                self.collider:applyForce(-(px + 25000), 0)
            elseif px < 0 then
                self.collider:applyForce(-(px - 25000), 0)
            end
            self.isWalking = false

        end
    end
    

    if self.dx == "Right" then
        self.parryCollider:setPosition(self.collider:getX() + 50, self.collider:getY())
    elseif self.dx == "Left" then
        self.parryCollider:setPosition(self.collider:getX() - 50, self.collider:getY())
    end


-----------------------------------------LOGICA ANIMAZIONI----------------------------------------------------
---
---
---
---
---------------------------------------------ATTACCO----------------------------------------------------------
    
    if self.isAttacking then


        
------------------------------------------------PARRY--------------------------------------------------------

    elseif self.parry then
       -- self.currentAnimation = self.playerSprite.parry
        if self.dx == "Right" then
            self.currentAnimation.animation_r:update(dt)
        elseif self.dx == "Left" then
            self.currentAnimation.animation_l:update(dt)
        end
        -- Optionally, reset to idle after parry cooldown
        if self.parryTimer >= self.parryCooldown then
            self.currentAnimation = self.playerSprite.idle
        end
        return -- skip other animation logic while parrying
------------------------------------------------CURA--------------------------------------------------------

    elseif self.healing then
        self.currentAnimation = self.playerSprite.heal
        if self.dx == "Right" then
            self.currentAnimation.animation_r:update(dt)
        elseif self.dx == "Left" then
            self.currentAnimation.animation_l:update(dt)
        end
        -- End healing after animation finishes (assuming 7 frames at 0.15s each)
        self.healTimer = (self.healTimer or 0) + dt
        if self.healTimer > 7 * 0.15 then
            self.healing = false
            self.healTimer = 0
            self.currentAnimation = self.playerSprite.idle
        end
        return -- skip other animation logic while healing

------------------------------------------------SALTO--------------------------------------------------------

    elseif not self.isGrounded then
        if py < -20 then
            -- Ascending: frames 2-4, no loop
            if self.jumpState ~= "ascend" then
                self.jumpState = "ascend"
                self.currentAnimation = self.playerSprite.jump
                if self.dx == "Right" then
                    self.currentAnimation.animation_r = anim8.newAnimation(self.playerSprite.jump.grid('2-4',1), 0.10, "pauseAtEnd")
                    self.currentAnimation.animation_r:gotoFrame(1)
                    self.currentAnimation.animation_r:resume()
                elseif self.dx == "Left" then
                    self.currentAnimation.animation_l = anim8.newAnimation(self.playerSprite.jump.grid('2-4',1), 0.10, "pauseAtEnd"):flipH()
                    self.currentAnimation.animation_l:gotoFrame(1)
                    self.currentAnimation.animation_l:resume()
                end
            end
        elseif math.abs(py) <= 20 then
            -- Apex: frame 5
            if self.jumpState ~= "apex" then
                self.jumpState = "apex"
                self.currentAnimation = self.playerSprite.jump
                if self.dx == "Right" then
                    self.currentAnimation.animation_r = anim8.newAnimation(self.playerSprite.jump.grid(5,1), 1)
                    self.currentAnimation.animation_r:gotoFrame(1)
                    self.currentAnimation.animation_r:pause()
                elseif self.dx == "Left" then
                    self.currentAnimation.animation_l = anim8.newAnimation(self.playerSprite.jump.grid(5,1), 1):flipH()
                    self.currentAnimation.animation_l:gotoFrame(1)
                    self.currentAnimation.animation_l:pause()
                end
                self.apexTimer = 0
            end
            self.apexTimer = self.apexTimer + dt
            -- Optionally, after a short time, force descend state
            if self.apexTimer > 0.18 then
                self.jumpState = "descend"
                self.currentAnimation = self.playerSprite.jump
                if self.dx == "Right" then
                    self.currentAnimation.animation_r = anim8.newAnimation(self.playerSprite.jump.grid('6-7',1), 0.12, "pauseAtEnd")
                    self.currentAnimation.animation_r:gotoFrame(1)
                    self.currentAnimation.animation_r:resume()
                elseif self.dx == "Left" then
                    self.currentAnimation.animation_l = anim8.newAnimation(self.playerSprite.jump.grid('6-7',1), 0.12, "pauseAtEnd"):flipH()
                    self.currentAnimation.animation_l:gotoFrame(1)
                    self.currentAnimation.animation_l:resume()
                end
            end
        elseif py > 20 then
            -- Descending: frames 6-7, no loop
            if self.jumpState ~= "descend" then
                self.jumpState = "descend"
                self.currentAnimation = self.playerSprite.jump
                if self.dx == "Right" then
                    self.currentAnimation.animation_r = anim8.newAnimation(self.playerSprite.jump.grid('6-7',1), 0.12, "pauseAtEnd")
                    self.currentAnimation.animation_r:gotoFrame(1)
                    self.currentAnimation.animation_r:resume()
                elseif self.dx == "Left" then
                    self.currentAnimation.animation_l = anim8.newAnimation(self.playerSprite.jump.grid('6-7',1), 0.12, "pauseAtEnd"):flipH()
                    self.currentAnimation.animation_l:gotoFrame(1)
                    self.currentAnimation.animation_l:resume()
                end
            end
        end
    elseif self.isGrounded and not self.isWalking then
        if self.jumpState ~= "land" and self.jumpState ~= "idle" then
            self.jumpState = "land"
            self.landingTimer = 0
            self.currentAnimation = self.playerSprite.jump
            if self.dx == "Right" then
                self.currentAnimation.animation_r = anim8.newAnimation(self.playerSprite.jump.grid(8,1), 1)
                self.currentAnimation.animation_r:gotoFrame(1)
                self.currentAnimation.animation_r:pause()
            elseif self.dx == "Left" then
                self.currentAnimation.animation_l = anim8.newAnimation(self.playerSprite.jump.grid(8,1), 1):flipH()
                self.currentAnimation.animation_l:gotoFrame(1)
                self.currentAnimation.animation_l:pause()
            end
        end
        self.landingTimer = (self.landingTimer or 0) + dt
        if self.landingTimer > 0.12 then
            if self.currentAnimation ~= self.playerSprite.idle then
                self.jumpState = "idle"
                self.currentAnimation = self.playerSprite.idle
                if self.dx == "Right" then
                    self.currentAnimation.animation_r:gotoFrame(1)
                    self.currentAnimation.animation_r:resume()
                elseif  self.dx == "Left" then
                    self.currentAnimation.animation_l:gotoFrame(1)
                    self.currentAnimation.animation_l:resume()
                end
            end
        end

------------------------------------------------CAMMINATA-------------------------------------------------------

    elseif self.isWalking then 
        self.currentAnimation = self.playerSprite.walk
    else

--------------------------------------------------IDLE-----------------------------------------------------
    
        if self.currentAnimation ~= self.playerSprite.idle then
            self.currentAnimation = self.playerSprite.idle
            if self.dx == "Right" then
                self.currentAnimation.animation_r:gotoFrame(1)
                self.currentAnimation.animation_r:resume()
            elseif  self.dx == "Left" then
                self.currentAnimation.animation_l:gotoFrame(1)
                self.currentAnimation.animation_l:resume()
            end
        end
    end



    if self.currentAnimation then
        if self.dx == "Right" then
            self.currentAnimation.animation_r:update(dt)
        elseif  self.dx == "Left" then
            self.currentAnimation.animation_l:update(dt)
        end
        

    end
        
end
-----------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------DRAW----------------------------------------------------------------------------------------
	
function Player:draw()
    love.graphics.setColor(1,1,1,1)
    if self.currentAnimation then
        if self.dx == "Right" then
            self.currentAnimation.animation_r:draw(self.currentAnimation.sprite, self.x, self.y, 0, 1 , 1 , self.currentAnimation.sprite:getWidth()/(self.currentAnimation.frameN*3), self.currentAnimation.sprite:getHeight()/2)
        elseif self.dx == "Left" then
            self.currentAnimation.animation_l:draw(self.currentAnimation.sprite, self.x - self.currentAnimation.sprite:getWidth()/(self.currentAnimation.frameN*3) , self.y, 0, 1 , 1 , self.currentAnimation.sprite:getWidth()/(self.currentAnimation.frameN*3), self.currentAnimation.sprite:getHeight()/2)
        end
    end
    
    love.graphics.setColor(1,1,1)

    
end
---------------------------------------

---KEYBINDS----------------------------
---------------------------------------
function Player:keypressed(key, scancode, isrepeat)
    if key == "space"  then
        self.isJump = true
        self.isGrounded = false
    end
    if key == "f" then
     
        self:heal()
    end
end

---------------------------------------

return Player
