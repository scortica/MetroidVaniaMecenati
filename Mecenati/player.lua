local player = {}

player.__index = player
require("globals")

local anim8 =require("Libraries/anim8")
local image,animation,grid


function player.new(params)
    local self = setmetatable({}, player)

    params = params or {}

    -- esempi di parametri o valori preimportati
    self.x = params.x or 800
    self.y = params.y or 500
    self.dx = 0
    self.width = params.width or 128
    self.height = params.height or 256
    self.speed = params.speed or 3
    self.gravity = 110
    self.scale = params.scale or 1
    self.defaultSpeed = self.speed
    self.lp= params.lp or 100
    self.jumpNum = 0
    self.jumpResetTime = 0.095
    self.collider = world:newBSGRectangleCollider(params.x, params.y, 64, 128, 2)  -- collider del player windfield
    self.isGrounded = false

    self.spriteSheetPath = {idle='Assets/Sprites/player/player_idle_sheet.png',
                            walk='Assets/Sprites/player/player_run_sheet.png',
                            attack=' ',
                            jump='Assets/Sprites/player/player_jump_sheet1.png'}
    self.playerSprite = nil
    self.currentAnimation = nil

    self.mouseX=nil
    self.mouseY=nil

    self.isAttacking = false
    self.attackHasHit = false
    self.attackTimer = 0
    self.attackDuration = 0.5
    self.attackCollider = world:newRectangleCollider(params.x, params.y, 25, 25) -- collider dell'attacco windfield

    self.isWalking = false
    self.isJump = false
    self.jumpBuffer = 0
    
    return self
end

local debugText = true

function player:mousepressed(x, y, button, istouch, presses)

    -- Se il player non è in attacco e il tasto sinistro del mouse è premuto
    -- attiva l'attacco e resetta il timer dell'attacco
    if button == 1 and not self.isAttacking then -- Left mouse button
        self.isAttacking = true
        self.attackHasHit = false

         self.attackTimer = 0
    end
    -- Se il tasto destro del mouse è premuto,
    --------------------------------IMPLEMENTARE LOGICA PARRY---------------------------------------
    if button == 2 then -- Right mouse button
        -- parry logic here  
    end
end




---------------------------------------
---------------------------------FUNZIONI LOVE-------------------------------------------------


---------------------------------------LOAD----------------------------------------------------

function player:load()
    self.attackCollider:setType("dynamic")
    self.attackCollider:setFixedRotation(true)
    self.attackCollider:setGravityScale(0)
    self.attackCollider:setCollisionClass("PlayerAttack")
    self.attackCollider:isActive(false)
    
    self.playerSprite = {
        idle = {
            sprite = love.graphics.newImage(self.spriteSheetPath.idle),
            grid= nil,
            animation = nil,
            frameN = 5
        },
        walk = {
            sprite = love.graphics.newImage(self.spriteSheetPath.walk),
            grid= nil,
            animation = nil,
            frameN = 8
        },
        attack ={
            sprite = nil,--love.graphics.newImage(self.spriteSheetPath.attack),
            grid= nil,
            animation = nil,
            frameN = nil
        },
        jump = {
            sprite = love.graphics.newImage(self.spriteSheetPath.jump),
            grid= nil,
            animation = nil,
            frameN = 9
        }
    }



    
    self.playerSprite.idle.grid = anim8.newGrid(139,131, self.playerSprite.idle.sprite:getWidth(), self.playerSprite.idle.sprite:getHeight())
    self.playerSprite.walk.grid = anim8.newGrid(139,131, self.playerSprite.walk.sprite:getWidth(), self.playerSprite.walk.sprite:getHeight())
    --self.playerSprite.attack.grid = anim8.newGrid(139,131, self.playerSprite.attack.sprite:getWidth(), self.playerSprite.attack.sprite:getHeight())
    self.playerSprite.jump.grid = anim8.newGrid(152,128, self.playerSprite.jump.sprite:getWidth(), self.playerSprite.jump.sprite:getHeight())


    self.playerSprite.idle.animation = anim8.newAnimation(self.playerSprite.idle.grid('1-5',1),0.3)
    self.playerSprite.walk.animation = anim8.newAnimation(self.playerSprite.walk.grid('1-8',1),0.15)
    --self.playerSprite.attack.animation = anim8.newAnimation(self.playerSprite.attack.grid('1-2',1),0.3)
    self.playerSprite.jump.animation = anim8.newAnimation(self.playerSprite.jump.grid('2-9',1),0.15)


    self.currentAnimation = self.playerSprite.idle

    end

-------------------------------------------------------------------------------------------------------
----------------------------------------UPDATE-----------------------------------------------------------

function player:update(dt)
    local px, py = self.collider:getLinearVelocity()
    ------------------------------LOGICA ATTACCO---------------------------------------------------------

    -- Se il player è in attacco, attiva il collider dell'attacco
    -- e posizionalo in base alla direzione del player
    -- Se il player non è in attacco, disattiva il collider dell'attacco
    if self.isAttacking then
        if self.dx == "Left" then
            self.attackCollider:setPosition(self.x - 25, self.y)
        else
            self.attackCollider:setPosition(self.x + 25, self.y)
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
            self.collider:applyLinearImpulse(0, -6000)
            self.isGrounded = false
            self.jumpNum = self.jumpNum + 1
            self.jumpBuffer = 0.1 -- ignore ground for 0.1 seconds
            self.currentAnimation = self.playerSprite.jump
            self.currentAnimation.animation:gotoFrame(1)
        end
        self.isJump = false
    end

    if self.jumpBuffer > 0 then
        self.jumpBuffer = self.jumpBuffer - dt
    end
    -------------------------------------------------------------------------------------------------------

    ------------------------------LOGICA MOVIMENTO---------------------------------------------------------
    -- Se premi "a" o "d", applica una forza al collider del player per muoverlo a sinistra o a destra
    -- Se non premi nessun tasto, applica una forza al collider del player per fermarlo


    if love.keyboard.isDown("a") and px >= -300 then
        --self.dx = self.speed * -1
        self.collider:applyForce(-10000, 0)
        self.dx = "Left"
        self.isWalking = true
    elseif love.keyboard.isDown("d") and px <= 300  then
        --self.dx = self.speed
        self.collider:applyForce(10000, 0)
        self.dx = "Right"
        self.isWalking = true

    elseif love.keyboard.isDown("a") or love.keyboard.isDown("d") then
        --VUOTO
    else
        if px > 0 then
            self.collider:applyForce(-(px + 9300), 0)
        elseif px < 0 then
            self.collider:applyForce(-(px - 9300), 0)
        end
        self.isWalking = false

    end
    
    if self.isAttacking then
        --self.currentAnimation = self.playerSprite.attack.animation
    elseif not self.isGrounded then
        if self.currentAnimation ~= self.playerSprite.jump then
            self.currentAnimation = self.playerSprite.jump
        end
    elseif self.isWalking then
       
        self.currentAnimation = self.playerSprite.walk
    else
        if self.currentAnimation ~= self.playerSprite.idle then
            self.currentAnimation = self.playerSprite.idle
        end
    end

    if self.currentAnimation then
        self.currentAnimation.animation:update(dt)
    end
        
    

end
-----------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------DRAW----------------------------------------------------------------------------------------
	
function player:draw()
    if self.currentAnimation then
       self.currentAnimation.animation:draw(self.currentAnimation.sprite, self.x, self.y, 0, 1 , 1 , self.currentAnimation.sprite:getWidth()/(self.currentAnimation.frameN*3), self.currentAnimation.sprite:getHeight()/2)
    end
    love.graphics.setColor(1,1,1,1)
    --love.graphics.draw(self.playerSprite, self.x, self.y, 0, 0.5, 0.5, self.playerSprite:getWidth()/2, self.playerSprite:getHeight()/2)
    love.graphics.setColor(1,1,1)

    if debugText then
        --print("Player width: " .. self.playerSprite:getWidth())
        --print("Player height: " .. self.playerSprite:getHeight())

    end
    
end
---------------------------------------

---KEYBINDS----------------------------
---------------------------------------
function player:keypressed(key, scancode, isrepeat)
    if key == "space"  then 
                self.isJump = true
                self.isGrounded = false
    end
end

---------------------------------------

return player