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
    self.playerSprite = nil

    self.mouseX=nil
    self.mouseY=nil

    self.isAttacking = false
    self.attackHasHit = false
    self.attackTimer = 0
    self.attackDuration = 0.5
    self.attackCollider = world:newRectangleCollider(params.x, params.y, 25, 25) -- collider dell'attacco windfield

    self.playerX = nil
    self.playerY = nil

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


-----------------------------------------------------------------------------------------------



---------------------------------FUNZIONI LOVE-------------------------------------------------
-----------------------------------------------------------------------------------------------
function enemy:load()
    self.playerSprite = love.graphics.newImage(self.spriteSheetPath)
    self.collider:setCollisionClass("Enemy")
    self.collider:setType("dynamic")
    self.collider:setFixedRotation(true)
    self.collider:setMass(1)
end

function enemy:update(dt)
    -- Aggiorna la posizione del collider dell'attacco in base alla posizione del player
    self.attackCollider:setPosition(self.collider:getPosition())
    self.attackCollider:setCollisionClass("EnemyAttack")
    self.attackCollider:setType("static")

    -- Aggiorna il timer dell'attacco
    if self.isAttacking then
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer >= self.attackDuration then
            self.isAttacking = false
            self.attackHasHit = false
            self.attackTimer = 0
        end
    end

    -- Logica di movimento e gravità qui (se necessario)
end

function enemy:draw()
    love.graphics.draw(self.playerSprite, self.collider:getX(), self.collider:getY(), 0, self.scale, self.scale, self.width / 2, self.height / 2)
    if debugText then
        love.graphics.print("Enemy X: " .. self.collider:getX() .. " Y: " .. self.collider:getY(), 10, 10)
    end
end
-----------------------------------------------------------------------------------------------



return enemy