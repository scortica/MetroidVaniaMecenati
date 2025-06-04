local EnemyGhost = {}

EnemyGhost.__index = EnemyGhost
require("globals")

local anim8 =require("Libraries/anim8")

function EnemyGhost.new(params)
    local self = setmetatable({}, EnemyGhost)

    params = params or {}

    -- esempi di parametri o valori preimportati
    self.x = params.x or 800
    self.y = params.y or 500
    self.dx = "Left"
    self.width = params.width or 128
    self.height = params.height or 128
    self.scale = params.scale or 1
    self.speed = params.speed or 100
    self.isFollowing = false
    self.damage = 1

    self.lp= params.lp or 3

    self.isActive = true

    self.collider = world:newBSGRectangleCollider(params.x, params.y, 74, 117, 2)  -- collider del player windfield
    self.collider:setObject(self)

    self.attackCollider = world:newRectangleCollider(params.x, params.y, 10, 117)
    self.attackCollider:setObject(self)

    self.spriteSheetPath = 'Assets/Sprites/enemy/ghost_sheet.png'
    self.enemySprite = nil
    self.image = nil
    self.grid = nil
    self.animation_l = nil
    self.animation_r = nil
    self.animationatk_l = nil
    self.animationatk_r = nil
    self.currentAnimation = nil


    self.isAttacking = false
    self.attackHasHit = false
    self.attackTimer = 0
    self.attackDuration = 0.5


    self.knockbackVelX = 0
    self.knockbackVelY = 0
    self.knockbackTimer = 0
    self.knockbackDuration = 0.2

    self.flashTimer = 0
    self.flashDuration = 0.05


    self.isDying = false
    self.deathTimer = 0
    self.deathDuration = 1
    self.animationdeath_l = nil
    self.animationdeath_r = nil
    --self.attackCollider = world:newRectangleCollider(params.x, params.y, 25, 25) -- collider dell'attacco windfield

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
        // Lerp between original color and white
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

function EnemyGhost:attack(player, distance, dt)
    local xDist = (player.x - self.x) / distance
    local yDist = (player.y - self.y) / distance

    if distance > 50 then
        self.x = self.x + xDist * self.speed * dt
        self.y = self.y + yDist * self.speed * dt
    end
    if self.dx == "Left" then
        self.currentAnimation = self.animationatk_l
    else
        self.currentAnimation = self.animationatk_r
    end

   --Logica Attacco
   --Calcola la posizione del player rispetto a se stesso
   --Si muove a velocità costante verso il player in linea retta
   --Attiva l'animazione di attacco e il collider dell'attacco (se necessario)

end

function EnemyGhost:gotHit(damage)
    self.lp = self.lp - damage
    self.flashTimer = self.flashDuration
    if self.lp <= 0 and not self.isDying then
        self.isDying = true
        self.deathTimer = 0
        self.flashTimer = 0
        if self.dx == "Right" then
            self.currentAnimation = self.animationdeath_r
        else
            self.currentAnimation = self.animationdeath_l
        end

    end
end


function EnemyGhost:knockback(fromX)
   local dir = (fromX < self.x) and 1 or -1
    self.knockbackVelX = dir *  400
    self.knockbackVelY = -200
    self.knockbackTimer = self.knockbackDuration
end
-----------------------------------------------------------------------------------------------



---------------------------------FUNZIONI LOVE-------------------------------------------------
-----------------------------------------------------------------------------------------------
function EnemyGhost:load()
    self.image = love.graphics.newImage(self.spriteSheetPath)
    self.collider:setCollisionClass("Enemy")
    self.collider:setFixedRotation(true)
    self.attackCollider:setCollisionClass("EnemyAttack")
    self.attackCollider:setType("kinematic")
    self.attackCollider:setFixedRotation(true)
    self.attackCollider:setGravityScale(0)
    self.attackCollider:setActive(false)
    self.grid= anim8.newGrid(99,134, self.image:getWidth(), self.image:getHeight())
    self.animation_l = anim8.newAnimation(self.grid('1-2',1),0.5)
    self.animation_r = anim8.newAnimation(self.grid('1-2',1),0.5):flipH()
    self.animationatk_l = anim8.newAnimation(self.grid('3-4',1),0.5)
    self.animationatk_r = anim8.newAnimation(self.grid('3-4',1),0.5):flipH()
    self.animationdeath_l = anim8.newAnimation(self.grid('5-24',1),0.05)
    self.animationdeath_r = anim8.newAnimation(self.grid('5-24',1),0.05)
    self.currentAnimation = self.animation_l

end

function EnemyGhost:update(dt,player)

    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
    end
    if self.isDying then
        self.deathTimer = self.deathTimer + dt
        self.currentAnimation:update(dt)
        if self.deathTimer >= self.deathDuration then
            self.isActive = false 
        end
        return
    end

    if self.knockbackTimer > 0 then
        self.x = self.x + self.knockbackVelX * dt
        self.y = self.y + self.knockbackVelY * dt
        self.knockbackTimer = self.knockbackTimer - dt
        -- Optional: add friction/damping
        self.knockbackVelX = self.knockbackVelX * 0.9
        self.knockbackVelY = self.knockbackVelY * 0.9
        if self.knockbackTimer <= 0 then
            self.knockbackVelX = 0
            self.knockbackVelY = 0
        end
        -- Skip normal movement while in knockback
        self.collider:setPosition(self.x, self.y)
        if self.dx == "Right" then
            self.currentAnimation = self.animation_r
        else
            self.currentAnimation = self.animation_l
        end
        
        self.currentAnimation:update(dt)
        return
    end

    if self.dx == "Right" then
        self.attackCollider:setPosition(self.x + 50, self.y)
    elseif self.dx == "Left" then
        self.attackCollider:setPosition(self.x - 50, self.y)
    end

    -- Aggiorna il timer dell'attacco
    if self.isAttacking then
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer >= self.attackDuration then
            self.isAttacking = false
            self.attackHasHit = false
            self.attackTimer = 0
        end
    end

  

    local dist = distance(self.x,player.x ,self.y, player.y)
    if  dist < 500 then
        self.isFollowing = true

    end

    if self.isFollowing then

        local direction = player.x - self.x
        if direction < 0 then
            self.dx = "Left"
        else
            self.dx = "Right"
        end
    
        self:attack(player, dist, dt)
    end

    self.currentAnimation:update(dt)
    self.collider:setPosition(self.x, self.y)

    
    
end

function EnemyGhost:draw()

    if self.flashTimer > 0 then
        whiteFlashShader:send("flashAmount", 1)
        love.graphics.setShader(whiteFlashShader)
    else
        whiteFlashShader:send("flashAmount", 0)
        love.graphics.setShader()
    end

    love.graphics.setColor(1,1,1,1)
    self.currentAnimation:draw(self.image, self.x, self.y , 0, 1, 1, 74/2, 117/2)

    love.graphics.setShader()
    love.graphics.setColor(1,1,1,1)
    

end


-----------------------------------------------------------------------------------------------



return EnemyGhost