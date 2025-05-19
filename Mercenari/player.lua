local player = {}

player.__index = player
require("globals")

--local anim8 =require("anim8")
--local image,animation


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
    self.isJump = false
    self.collider = world:newBSGRectangleCollider(params.x, params.y, 64, 128, 2)  -- collider del player windfield
    self.isGrounded = false

    self.spriteSheetPath = 'Assets/Sprites/player/PH_player.png'
    self.playerSprite = nil

    self.mouseX=nil
    self.mouseY=nil

    self.isAttacking = false
    self.attackHasHit = false
    self.attackTimer = 0
    self.attackDuration = 0.5
    self.attackCollider = world:newRectangleCollider(params.x, params.y, 25, 25) -- collider dell'attacco windfield

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
    self.playerSprite=love.graphics.newImage(self.spriteSheetPath)
    --local grid= anim8.newGrid(64,64, image:getWidth(), image:getHeight())
    --animation = anim8.newAnimation(grid('1-10',1),0.3)
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


         
            self.jumpNum = self.jumpNum + 1
        end
        self.isJump = false
    end
    -------------------------------------------------------------------------------------------------------

    ------------------------------LOGICA MOVIMENTO---------------------------------------------------------
    -- Se premi "a" o "d", applica una forza al collider del player per muoverlo a sinistra o a destra
    -- Se non premi nessun tasto, applica una forza al collider del player per fermarlo


    if love.keyboard.isDown("a") and px >= -300 then
        --self.dx = self.speed * -1
        self.collider:applyForce(-10000, 0)
        self.dx = "Left"
    elseif love.keyboard.isDown("d") and px <= 300  then
        --self.dx = self.speed
        self.collider:applyForce(10000, 0)
        self.dx = "Right"


    else
        if px > 0 then
            self.collider:applyForce(-(px + 9300), 0)
        elseif px < 0 then
            self.collider:applyForce(-(px - 9300), 0)
        end
    end
    
    --animation:update(dt)

end
-----------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------DRAW----------------------------------------------------------------------------------------
	
function player:draw()
    --animation:draw(image, self.x, self.y)
    -- Resetta il colore per evitare problemi di sovrapposizione
    love.graphics.setColor(1,1,1,1)
    -- Disegna il player
    love.graphics.setColor(1,0,0)
    love.graphics.draw(self.playerSprite, self.x, self.y, 0, 0.5, 0.5, self.playerSprite:getWidth()/2, self.playerSprite:getHeight()/2)
    love.graphics.setColor(1,1,1)
end
---------------------------------------

return player