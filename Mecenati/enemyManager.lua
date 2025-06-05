local Enemy_ghost = require("enemy_ghost")
local Enemy_shooter = require("enemy_shooter")
local Boss = require("boss")
local EnemyManager = {}
EnemyManager.__index = EnemyManager

function EnemyManager
.new(params)
    local self = setmetatable({}, EnemyManager)

    params = params or {}

    self.ghosts = {}
    self.shooters = {}
    self.boss = {}

    return self
end

local function isInCameraView(cam, x, y, margin)
    margin = margin or 100 -- Optional: allow a margin for offscreen updates
    local camX, camY = cam.x, cam.y
    local halfW, halfH = love.graphics.getWidth()/2, love.graphics.getHeight()/2
    return
        x > camX - halfW - margin and x < camX + halfW + margin and
        y > camY - halfH - margin and y < camY + halfH + margin
end


function EnemyManager:load()
    if map.layers["EnemySpawn"] then
        for i, obj in ipairs(map.layers["EnemySpawn"].objects) do
            if obj.name == "Ghost" then
                local enemy = Enemy_ghost.new({x = obj.x, y = obj.y, speed = 100})
                table.insert(self.ghosts, enemy)
                enemy:load()
            elseif obj.name == "Shooter" then
                local enemy = Enemy_shooter.new({x = obj.x, y = obj.y, speed = 100})
                table.insert(self.shooters, enemy)
                enemy:load()
            elseif obj.name == "Boss" then
                local boss = Boss.new({x = obj.x, y = obj.y, speed = 100})
                table.insert(self.boss, boss)
                boss:load()
            end
        end
    end
end

function EnemyManager:update(dt, player)
    for i, ghost in ipairs(self.ghosts) do

        if ghost.isActive then
            if isInCameraView(cam, ghost.x, ghost.y) then
                ghost:update(dt, player)
            end
        else
            -- Se il fantasma non è attivo, rimuovilo dalla lista
            ghost.collider:destroy() -- Distruggi il collider del fantasma
            ghost.attackCollider:destroy()
            table.remove(self.ghosts, i)
        end
    end

   for i, shooter in ipairs(self.shooters) do
    
        if shooter.isActive then
            if isInCameraView(cam, shooter.x, shooter.y) then
                shooter:update(dt, player)
            end
        else
            -- Se il fantasma non è attivo, rimuovilo dalla lista
            shooter.collider:destroy() -- Distruggi il collider del fantasma
            if shooter.bullet then
                shooter.bullet.collider:destroy() -- Distruggi il collider del proiettile se esiste
            end
            table.remove(self.shooters, i)
        end
        
    end

    for i, boss in ipairs(self.boss) do
        if boss.isActive then
            if isInCameraView(cam, boss.x, boss.y) then
                boss:update(dt)
            end
        end
    end
end


function EnemyManager:draw()
    for i, ghost in ipairs(self.ghosts) do
        ghost:draw()
    end

    for i, shooter in ipairs(self.shooters) do
        shooter:draw()
    end

    for i, boss in ipairs(self.boss) do
        boss:draw()
    end
end

return EnemyManager