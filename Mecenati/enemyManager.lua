local Enemy_ghost = require("enemy_ghost")
local Enemy_shooter = require("enemy_shooter")

local EnemyManager = {}
EnemyManager.__index = EnemyManager

function EnemyManager
.new(params)
    local self = setmetatable({}, EnemyManager)

    params = params or {}

    self.ghosts = {}
    self.shooters = {}

    return self
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
            --elseif  then

            end
        end
    end
end

function EnemyManager:update(dt, player)
    for i, ghost in ipairs(self.ghosts) do

        if ghost.isActive then
            ghost:update(dt, player)
        else
            -- Se il fantasma non è attivo, rimuovilo dalla lista
            table.remove(self.ghosts, i)
        end
    end

   for i, shooter in ipairs(self.shooters) do
    
        if shooter.isActive then
            shooter:update(dt, player)
        else
            -- Se il fantasma non è attivo, rimuovilo dalla lista
            table.remove(self.shooters, i)
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
end

return EnemyManager