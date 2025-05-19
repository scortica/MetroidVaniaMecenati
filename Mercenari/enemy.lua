local enemy = {}

enemy.__index = enemy
require("globals")

function enemy.new(params)
    local self = setmetatable({}, enemy)

    params = params or {}

    -- esempi di parametri o valori preimportati
    self.x = params.x or 800
    self.y = params.y or 500
    self.dx = 0
    self.width = params.width or 128
    self.height = params.height or 128
    self.speed = params.speed or 3
    self.gravity = 110
    self.scale = params.scale or 1
    self.defaultSpeed = self.speed
    self.lp= params.lp or 100
    self.jumpNum = 0
    self.jumpResetTime = 0.095
    self.isJump = false
    self.collider = world:newBSGRectangleCollider(params.x, params.y, 25, 25, 2)  -- collider del player windfield
    self.isGrounded = false

    self.spriteSheetPath = 'Assets/Sprites/player.png'
    self.enemySprite = nil

    self.mouseX=nil
    self.mouseY=nil

    self.isAttacking = false
    self.attackHasHit = false
    self.attackTimer = 0
    self.attackDuration = 0.5
    self.attackCollider = world:newRectangleCollider(params.x, params.y, 25, 25) -- collider dell'attacco windfield

    return self
end
-----------------------------------------------------------------------------------------------

local debugText = true

---------------------------------FUNZIONI ENEMY------------------------------------------------
-----------------------------------------------------------------------------------------------
function enemy:findPlayer(player)
    -- Trova la posizione del player
    self.playerX, self.playerY = player.collider:getPosition()
end

function enemy:shoot()
    -- Se il player è in un raggio di 100 pixel, attacca
    if self.playerX and self.playerY then
        local distance = math.sqrt((self.playerX - self.collider:getX())^2 + (self.playerY - self.collider:getY())^2)
        if distance < 100 then
            self.isAttacking = true
            self.attackHasHit = false
            self.attackTimer = 0
        end
    end
end

local function atan2(y, x)
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 and y >= 0 then
        return math.atan(y / x) + math.pi
    elseif x < 0 and y < 0 then
        return math.atan(y / x) - math.pi
    elseif x == 0 and y > 0 then
        return math.pi / 2
    elseif x == 0 and y < 0 then
        return -math.pi / 2
    else
        return 0 -- for the case when x == 0 and y == 0
    end
end

local function getLookAtPointRotation(x, y, playerX,playerY)
    return atan2((y - playerY), (x - playerX)) - math.pi/2
end

local function distance(x1,x2,y1,y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

-----------------------------------------------------------------------------------------------



---------------------------------FUNZIONI LOVE-------------------------------------------------
-----------------------------------------------------------------------------------------------
function enemy:load()
    self.enemySprite = love.graphics.newImage(self.spriteSheetPath)
    self.collider:setCollisionClass("Enemy")
    self.collider:setFixedRotation(true)
end

function enemy:update(dt,player)


    -- Aggiorna la posizione del collider dell'attacco in base alla posizione del player
    self.attackCollider:setPosition(self.collider:getPosition())
    self.attackCollider:setCollisionClass("EnemyAttack")
    self.attackCollider:setType("dynamic")

    -- Aggiorna il timer dell'attacco
    if self.isAttacking then
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer >= self.attackDuration then
            self.isAttacking = false
            self.attackHasHit = false
            self.attackTimer = 0
        end
    end

    if distance(self.x,player.x ,self.y, player.y) < 20 then
        print("Distanza tra nemico e player: " .. distance(self.x,player.x, self.y, player.y))
    end

    -- Logica di movimento e gravità qui (se necessario)
end

function enemy:draw()
    --animation:draw(image, self.x, self.y)
    -- Resetta il colore per evitare problemi di sovrapposizione
    love.graphics.setColor(1,1,1,1)
    -- Disegna il player
    love.graphics.draw(self.enemySprite, self.x, self.y, 0, 1, 1, self.enemySprite:getWidth()/2, self.enemySprite:getHeight()/2)
end


-----------------------------------------------------------------------------------------------



return enemy