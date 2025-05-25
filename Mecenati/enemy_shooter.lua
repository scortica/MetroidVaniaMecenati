local EnemyShooter = {}

EnemyShooter.__index = EnemyShooter
require("globals")
local Bullet = require("bullet")

local anim8 =require("Libraries/anim8")

function EnemyShooter.new(params)
    local self = setmetatable({}, EnemyShooter)

    params = params or {}

    -- esempi di parametri o valori preimportati
    self.x = params.x or 800
    self.y = params.y or 500
    self.dx = 0
    self.width = params.width or 128
    self.height = params.height or 128
    self.scale = params.scale or 1

    self.collider = world:newBSGRectangleCollider(params.x, params.y, 100/2, 141, 2)  -- collider del player windfield

    self.spriteSheetPath = {
        idle = 'Assets/Sprites/enemy/shooter_idle_sheet.png',
        attack = 'Assets/Sprites/enemy/shooter_shoot_sheet.png'
    }
    self.enemySprite = nil
    self.currentAnimation = nil


    self.isAttacking = false
    self.attackHasHit = false
    self.attackTimer = 0
    self.attackDuration = 2
    self.bullet = nil
    --self.attackCollider = world:newRectangleCollider(params.x, params.y, 25, 25) -- collider dell'attacco windfield

    return self
end
-----------------------------------------------------------------------------------------------

local debugText = true

---------------------------------FUNZIONI ENEMY------------------------------------------------
-----------------------------------------------------------------------------------------------
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


function EnemyShooter:shoot(player)
    -- Se il player è in un raggio di 100 pixel, attacca   
    if not self.isAttacking then
        self.isAttacking = true
        self.attackHasHit = false
        self.attackTimer = 0
        local angle = getLookAtPointRotation(self.x, self.y, player.x, player.y)
        self.bullet = Bullet.new({
            x = self.x - 50,
            y = self.y,
            angle = angle
        })
        self.bullet:load()
         
            self.currentAnimation = self.enemySprite.attack
            self.currentAnimation.animation:gotoFrame(1)
            self.currentAnimation.animation:resume()
       
    end
           
end



-----------------------------------------------------------------------------------------------



---------------------------------FUNZIONI LOVE-------------------------------------------------
-----------------------------------------------------------------------------------------------
function EnemyShooter:load()
    self.image = love.graphics.newImage(self.spriteSheetPath.idle)
    self.collider:setCollisionClass("Enemy")
    self.collider:setFixedRotation(true)
   

    self.enemySprite = {
        idle = {
            sprite = love.graphics.newImage(self.spriteSheetPath.idle),
            grid= nil,
            animation = nil,
            frameN = 5
        },
        attack ={
            sprite = love.graphics.newImage(self.spriteSheetPath.attack),
            grid= nil,
            animation = nil,
            frameN = 7
        }
    }

    self.enemySprite.idle.grid = anim8.newGrid(100,141, self.enemySprite.idle.sprite:getWidth(), self.enemySprite.idle.sprite:getHeight())
    self.enemySprite.attack.grid = anim8.newGrid(100,141, self.enemySprite.attack.sprite:getWidth(), self.enemySprite.attack.sprite:getHeight())

    self.enemySprite.idle.animation = anim8.newAnimation( self.enemySprite.idle.grid('1-5',1),0.5)
    self.enemySprite.attack.animation = anim8.newAnimation( self.enemySprite.attack.grid('1-7',1),0.07, "pauseAtEnd")

    self.currentAnimation = self.enemySprite.idle

end

function EnemyShooter:update(dt,player)


    -- Aggiorna la posizione del collider dell'attacco in base alla posizione del player
    --self.attackCollider:setPosition(self.collider:getPosition())
    --self.attackCollider:setCollisionClass("EnemyAttack")
    --self.attackCollider:setType("dynamic")

    -- Aggiorna il timer dell'attacco

    self.x = self.collider:getX()
    self.y = self.collider:getY()
   

    if self.isAttacking then
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer >= self.attackDuration then
            self.isAttacking = false
            self.attackHasHit = false
            self.attackTimer = 0
            self.currentAnimation = self.enemySprite.idle
            self.currentAnimation.animation:gotoFrame(1)
            self.currentAnimation.animation:resume()
        end
    end

    if distance(self.x,player.x ,self.y, player.y) < 500 then
        self:shoot(player)
    elseif not self.isAttacking then
        if self.currentAnimation ~= self.enemySprite.idle then
            self.currentAnimation = self.enemySprite.idle
        end
    end
    if self.bullet then
        self.bullet:update(dt)
    end
    -- Logica di movimento e gravità qui (se necessario)

    self.currentAnimation.animation:update(dt)
end

function EnemyShooter:draw()

    love.graphics.setColor(1,1,1,1)
    -- Resetta il colore per evitare problemi di sovrapposizione
    self.currentAnimation.animation:draw(self.currentAnimation.sprite, self.x, self.y , 0, 1, 1, 100/2 + 25, 141/2)
    
    if self.bullet then
        self.bullet:draw()
    end
    -- Disegna il player
    --love.graphics.draw(self.enemySprite, self.x, self.y, 0, 1, 1, self.enemySprite:getWidth()/2, self.enemySprite:getHeight()/2)

end


-----------------------------------------------------------------------------------------------



return EnemyShooter