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
    return self
end

local function distance(x1,x2,y1,y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

function Bullet:load()
    self.bulletSprite = love.graphics.newImage(self.spritePath)
end

function Bullet:update(dt, enemies, player)
    if enemies then
        for _, enemy in ipairs(enemies) do
            if distance(self.x, enemy.x, self.y, enemy.y ) < 0 then
                enemy.active = false
            end
        end
    end
    
    
    self.x = self.x + math.cos ( self.angle - math.pi/2) * self.speed * dt
    self.y = self.y + math.sin ( self.angle - math.pi/2) * self.speed * dt
end


function Bullet:draw()
    love.graphics.draw(self.bulletSprite, self.x, self.y, self.angle + math.pi/2, nil, nil, self.bulletSprite:getWidth()/2, self.bulletSprite:getHeight()/2 )
end

return Bullet