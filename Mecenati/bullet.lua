local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(params)
    local self = setmetatable({}, Bullet)

    params = params or {}

    -- Params examples of Position and dimensions
    self.x = params.x or 0
    self.y = params.y or 0
    self.speed = params.speed or 450
    --self.width = params.width or 8
    --self.height = params.height or 4
    self.spritePath = "Assets/Sprites/bullet/proiettile.png"
    self.bulletSprite = nil
    self.angle = params.angle or 0
    self.rotation = params.angle
    self.isActive = true

    self.collider = world:newCircleCollider(params.x, params.y, 5)
    self.collider:setObject(self)

    return self
end

local function distance(x1,x2,y1,y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end


function Bullet:getParried()
    self.speed = -self.speed
    self.rotation = self.rotation - math.pi

    self.collider:setCollisionClass("PlayerAttack")
    
end

function Bullet:load()
    self.bulletSprite = love.graphics.newImage(self.spritePath)
    self.collider:setType("dynamic")
    self.collider:setFixedRotation(true)
    self.collider:setGravityScale(0)
    self.collider:setCollisionClass("EnemyAttack")



    self.collider:setPreSolve(function(bullet, other, contact)
        print(other.collision_class)
        if other.collision_class == "Player" and bullet.collision_class == "EnemyAttack" then
            local player = other:getObject()
            
            player:gotHit()
            self.collider:destroy()
            self.isActive = false
        end
        if other.collision_class == "Enemy" and bullet.collision_class == "PlayerAttack" then
            local enemy = other:getObject()
        end
    end)
    
end

function Bullet:update(dt, enemies, player)
   if self.isActive then
        if enemies then
            for _, enemy in ipairs(enemies) do
                if distance(self.x, enemy.x, self.y, enemy.y ) < 0 then
                    enemy.active = false
                end
            end
        end
        
        self.collider:setPosition(self.x, self.y)
        self.x = self.x + math.cos ( self.angle - math.pi/2) * self.speed * dt
        self.y = self.y + math.sin ( self.angle - math.pi/2) * self.speed * dt
    end
end


function Bullet:draw()
    if self.isActive then
        love.graphics.draw(self.bulletSprite, self.x, self.y, self.rotation + math.pi/2, nil, nil, self.bulletSprite:getWidth()/2, self.bulletSprite:getHeight()/2 )
    end
end

return Bullet