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

    self.lp= params.lp or 3

    self.isActive = true

    self.collider = world:newBSGRectangleCollider(params.x, params.y, 74, 117, 2)  -- collider del player windfield
    self.collider:setObject(self)

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

function EnemyGhost:attack(player, distance, dt)
    local xDist = (player.x - self.x) / distance
    local yDist = (player.y - self.y) / distance

    self.x = self.x + xDist * self.speed * dt
    self.y = self.y + yDist * self.speed * dt

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
    if self.lp <= 0 then
        -- Logica per la morte del nemico
        print("Nemico morto")
        -- Rimuovi il collider e l'animazione, se necessario
        self.isActive = false

    end
end
-----------------------------------------------------------------------------------------------



---------------------------------FUNZIONI LOVE-------------------------------------------------
-----------------------------------------------------------------------------------------------
function EnemyGhost:load()
    self.image = love.graphics.newImage(self.spriteSheetPath)
    self.collider:setCollisionClass("Enemy")
    self.collider:setFixedRotation(true)
    self.grid= anim8.newGrid(99,134, self.image:getWidth(), self.image:getHeight())
    self.animation_l = anim8.newAnimation(self.grid('1-2',1),0.5)
    self.animation_r = anim8.newAnimation(self.grid('1-2',1),0.5):flipH()
    self.animationatk_l = anim8.newAnimation(self.grid('3-4',1),0.5)
    self.animationatk_r = anim8.newAnimation(self.grid('3-4',1),0.5):flipH()
    self.currentAnimation = self.animation_l

end

function EnemyGhost:update(dt,player)



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

    love.graphics.setColor(1,1,1,1)
    self.currentAnimation:draw(self.image, self.x, self.y , 0, 1, 1, 74/2, 117/2)
    

end


-----------------------------------------------------------------------------------------------



return EnemyGhost