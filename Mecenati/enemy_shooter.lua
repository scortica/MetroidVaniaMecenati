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

    self.collider = world:newRectangleCollider(params.x, params.y, 100/2, 141)  -- collider del player windfield

    self.spriteSheetPath = {
        idle = 'Assets/Sprites/enemy/shooter_idle_sheet.png',
        attack = 'Assets/Sprites/enemy/shooter_shoot_sheet.png',
        death = 'Assets/Sprites/enemy/shooter_death_sheet.png'
    }
    self.enemySprite = nil
    self.currentAnimation = nil

    self.isActive=true

    


    self.isAttacking = false
    self.attackHasHit = false
    self.attackTimer = 0
    self.attackDuration = 2
    self.bullet = nil
    self.shootCooldown = 2
    self.shootCooldownTimer = 0

    self.knockbackVelX = 0
    self.knockbackVelY = 0
    self.knockbackTimer = 0
    self.knockbackDuration = 0.2
    self.hitIdleTimer = 0
    self.hitIdleDuration = 0.25

    self.flashTimer = 0
    self.flashDuration = 0.05


    self.isDying = false
    self.deathTimer = 0
    self.deathDuration = 0.8

    self.collider:setObject(self)

    return self
end
-----------------------------------------------------------------------------------------------

local debugText = true

---------------------------------FUNZIONI ENEMY------------------------------------------------
-----------------------------------------------------------------------------------------------
local whiteFlashShader = love.graphics.newShader[[
    extern number flashAmount;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texColor = Texel(texture, texture_coords) * color;
        texColor.rgb = mix(texColor.rgb, vec3(1.0), flashAmount);
        return texColor;
    }
]]

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

local function angleBetween(x1, y1, x2, y2)
    return atan2(y2 - y1, x2 - x1)
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
    self.flashTimer = self.flashDuration
    self.hitIdleTimer = self.hitIdleDuration
    if self.lp <= 0 and not self.isDying then
        self.isDying = true
        self.deathTimer = 0
        self.flashTimer = 0
        if self.dx == "Left" then
            self.currentAnimation = self.enemySprite.death
            self.currentAnimation.animation_l:gotoFrame(1)
            self.currentAnimation.animation_l:resume()
        else
            self.currentAnimation = self.enemySprite.death
            self.currentAnimation.animation_r:gotoFrame(1)
            self.currentAnimation.animation_r:resume()
        end
    end
end



function EnemyShooter:knockback(fromX)
   local dir = (fromX < self.x) and 1 or -1
    self.knockbackVelX = dir * 400
    self.knockbackVelY = -200
    self.knockbackTimer = self.knockbackDuration
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
        },
        death ={
            sprite = love.graphics.newImage(self.spriteSheetPath.death),
            grid= nil,
            animation_r = nil,
            animation_l = nil,
            frameN = 8
        }
    }

    self.enemySprite.idle.grid = anim8.newGrid(100,141, self.enemySprite.idle.sprite:getWidth(), self.enemySprite.idle.sprite:getHeight())
    self.enemySprite.attack.grid = anim8.newGrid(100,141, self.enemySprite.attack.sprite:getWidth(), self.enemySprite.attack.sprite:getHeight())
    self.enemySprite.death.grid = anim8.newGrid(99, 145, self.enemySprite.death.sprite:getWidth(), self.enemySprite.death.sprite:getHeight())

    self.enemySprite.idle.animation_l = anim8.newAnimation( self.enemySprite.idle.grid('1-5',1),0.5)
    self.enemySprite.idle.animation_r = anim8.newAnimation( self.enemySprite.idle.grid('1-5',1),0.5):flipH()
    self.enemySprite.attack.animation_l = anim8.newAnimation( self.enemySprite.attack.grid('1-7',1),0.07, "pauseAtEnd")
    self.enemySprite.attack.animation_r = anim8.newAnimation( self.enemySprite.attack.grid('1-7',1),0.07, "pauseAtEnd"):flipH()
    self.enemySprite.death.animation_l = anim8.newAnimation(self.enemySprite.death.grid('1-8', 1), 0.1, "pauseAtEnd")
    self.enemySprite.death.animation_r = anim8.newAnimation(self.enemySprite.death.grid('1-8', 1), 0.1, "pauseAtEnd"):flipH()

    self.currentAnimation = self.enemySprite.idle

end

function EnemyShooter:update(dt,player)

    self.x = self.collider:getX()
    self.y = self.collider:getY()

    local vx, vy = self.collider:getLinearVelocity()
    if math.abs(vy) < 1 then
        -- Likely on ground
        self.collider:setLinearDamping(10)
    else
        -- In air (falling or jumping)
        self.collider:setLinearDamping(0)
    end


    if self.shootCooldownTimer > 0 then
        self.shootCooldownTimer = self.shootCooldownTimer - dt
    end


    if self.isDying then
        self.deathTimer = self.deathTimer + dt
        if self.dx == "Left" then
            self.currentAnimation.animation_l:update(dt)
        else
            self.currentAnimation.animation_r:update(dt)
        end
        if self.deathTimer >= self.deathDuration then
            self.isActive = false
        end
        return
    end

    

    if self.knockbackTimer > 0 then
        self.x = self.x + self.knockbackVelX * dt
        self.y = self.y + self.knockbackVelY * dt
        self.knockbackTimer = self.knockbackTimer - dt
        self.knockbackVelX = self.knockbackVelX * 0.9
        self.knockbackVelY = self.knockbackVelY * 0.9
        if self.knockbackTimer <= 0 then
            self.knockbackVelX = 0
            self.knockbackVelY = 0
        end
        self.collider:setPosition(self.x, self.y)
        if self.dx == "Left" then
            self.currentAnimation.animation_l:update(dt)
        else
            self.currentAnimation.animation_r:update(dt)
        end
            return
    end

    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
    end

    if self.hitIdleTimer > 0 then
        self.hitIdleTimer = self.hitIdleTimer - dt
        self.isAttacking = false
        self.currentAnimation = self.enemySprite.idle
        if self.dx == "Left" then
            self.currentAnimation.animation_l:update(dt)
        else
            self.currentAnimation.animation_r:update(dt)
        end
        return
    end
    
   
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

    

    if distance(self.x, player.x, self.y, player.y) < 500 then
        local direction = player.x - self.x
        if direction < 0 then
            self.dx = "Left"
        else
            self.dx = "Right"
        end

        -- Angle check
        local facingAngle = (self.dx == "Left") and math.pi or 0
        local toPlayerAngle = angleBetween(self.x, self.y, player.x, player.y)
        local diff = atan2(math.sin(toPlayerAngle - facingAngle), math.cos(toPlayerAngle - facingAngle))
        local fov = math.rad(60) / 2 -- ±30°

        if math.abs(diff) < fov and self.shootCooldownTimer <= 0 then
            self:shoot(player)
            self.shootCooldownTimer = self.shootCooldown
        end

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

    if self.flashTimer > 0 then
        whiteFlashShader:send("flashAmount", 1)
        love.graphics.setShader(whiteFlashShader)
    else
        whiteFlashShader:send("flashAmount", 0)
        love.graphics.setShader()
    end

    love.graphics.setColor(1,1,1,1)
    if self.dx == "Left" then
        self.currentAnimation.animation_l:draw(self.currentAnimation.sprite, self.x, self.y , 0, 1, 1, 100/2 + 25, 141/2)
    else
        self.currentAnimation.animation_r:draw(self.currentAnimation.sprite, self.x + 50, self.y , 0, 1, 1, 100/2 + 25, 141/2)
    end

    love.graphics.setShader()
    love.graphics.setColor(1,1,1,1)

    if self.bullet then
        self.bullet:draw()
    end

end

-----------------------------------------------------------------------------------------------



return EnemyShooter