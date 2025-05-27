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
    self.dx = "Left"
    self.width = params.width or 128
    self.height = params.height or 128
    self.scale = params.scale or 1
    self.lp= params.lp or 5

    self.collider = world:newBSGRectangleCollider(params.x, params.y, 100/2, 141, 2)  -- collider del player windfield

    self.spriteSheetPath = {
        idle = 'Assets/Sprites/enemy/shooter_idle_sheet.png',
        attack = 'Assets/Sprites/enemy/shooter_shoot_sheet.png'
    }
    self.enemySprite = nil
    self.currentAnimation = nil

    self.isActive=true

    


    self.isAttacking = false
    self.attackHasHit = false
    self.attackTimer = 0
    self.attackDuration = 2
    self.bullet = nil
    --self.attackCollider = world:newRectangleCollider(params.x, params.y, 25, 25) -- collider dell'attacco windfield

    self.collider:setObject(self)

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
        if self.bullet then
            self.bullet.collider:destroy() -- Distruggi il vecchio collider se esiste
        end
        local bulletX = nil
        self.currentAnimation = self.enemySprite.attack
        if self.dx == "Left" then
            self.currentAnimation.animation_l:gotoFrame(1)
            self.currentAnimation.animation_l:resume()
            bulletX = self.x - 50
        else
            self.currentAnimation.animation_r:gotoFrame(1)
            self.currentAnimation.animation_r:resume()
            bulletX = self.x + 50
        end

        self.bullet = Bullet.new({
            x = bulletX,
            y = self.y,
            angle = angle,
            shooter = self
        })
        self.bullet:load()
           
            
       
    end
           
end

function EnemyShooter:gotHit(damage)
    self.lp = self.lp - damage
    if self.lp <= 0 then
        self.isActive = false
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
            animation_r = nil,
            animation_l = nil,
            frameN = 5
        },
        attack ={
            sprite = love.graphics.newImage(self.spriteSheetPath.attack),
            grid= nil,
            animation_r = nil,
            animation_l = nil,
            frameN = 7
        }
    }

    self.enemySprite.idle.grid = anim8.newGrid(100,141, self.enemySprite.idle.sprite:getWidth(), self.enemySprite.idle.sprite:getHeight())
    self.enemySprite.attack.grid = anim8.newGrid(100,141, self.enemySprite.attack.sprite:getWidth(), self.enemySprite.attack.sprite:getHeight())

    self.enemySprite.idle.animation_l = anim8.newAnimation( self.enemySprite.idle.grid('1-5',1),0.5)
    self.enemySprite.idle.animation_r = anim8.newAnimation( self.enemySprite.idle.grid('1-5',1),0.5):flipH()
    self.enemySprite.attack.animation_l = anim8.newAnimation( self.enemySprite.attack.grid('1-7',1),0.07, "pauseAtEnd")
    self.enemySprite.attack.animation_r = anim8.newAnimation( self.enemySprite.attack.grid('1-7',1),0.07, "pauseAtEnd"):flipH()

    self.currentAnimation = self.enemySprite.idle

end

function EnemyShooter:update(dt,player)

    self.x = self.collider:getX()
    self.y = self.collider:getY()
   
    -- Aggiorna il timer dell'attacco
    if self.isAttacking then
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer >= self.attackDuration then
            self.isAttacking = false
            self.attackHasHit = false
            self.attackTimer = 0
            self.currentAnimation = self.enemySprite.idle
            if self.dx == "Left" then
                self.currentAnimation.animation_l:gotoFrame(1)
                self.currentAnimation.animation_l:resume()
            else
                self.currentAnimation.animation_r:gotoFrame(1)
                self.currentAnimation.animation_r:resume()
            end
        end
    end

    if distance(self.x,player.x ,self.y, player.y) < 500 then
        local direction = player.x - self.x
        if direction < 0 then
            self.dx = "Left"
        else
            self.dx = "Right"
        end
        self:shoot(player)
    elseif not self.isAttacking then
        if self.currentAnimation ~= self.enemySprite.idle then
            self.currentAnimation = self.enemySprite.idle
        end
    end
    if self.bullet then
        self.bullet:update(dt)
    end

    if self.dx == "Left" then
        self.currentAnimation.animation_l:update(dt)
    else
        self.currentAnimation.animation_r:update(dt)
    end
end

function EnemyShooter :draw()

    love.graphics.setColor(1,1,1,1)
    if self.dx == "Left" then
        self.currentAnimation.animation_l:draw(self.currentAnimation.sprite, self.x, self.y , 0, 1, 1, 100/2 + 25, 141/2)
    else
        self.currentAnimation.animation_r:draw(self.currentAnimation.sprite, self.x + 50, self.y , 0, 1, 1, 100/2 + 25, 141/2)
    end
    
    
    if self.bullet then
        self.bullet:draw()
    end

end

-----------------------------------------------------------------------------------------------



return EnemyShooter