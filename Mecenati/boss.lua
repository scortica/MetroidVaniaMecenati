require("globals")
local anim8 =require("Libraries/anim8")

local Boss = {}
Boss.__index = Boss


function Boss.new(params)
    local self = setmetatable({}, Boss)
    self.x = params.x or 0
    self.y = params.y or 0
    self.attackRange = params.attackRange or 400
    self.attackCooldown = params.attackCooldown or 2
    self.attackTimer = 0
    self.isAttacking = false
    self.currentAttack = nil

    self.attacks = {
       
        
        
    }

    self.spriteSheetPath = {
        idle = 'Assets/Sprites/enemy/boss_r_idle_sheet.png',
        atk = 'Assets/Sprites/enemy/boss_r_sheet.png',
        death = 'Assets/Sprites/enemy/boss_r_death_sheet.png'
    }
    self.bossSprite = nil
    self.currentAnimation = nil

    return self
end

function Boss:attack()

end

function Boss:load()
    self.bossSprite = {
        idle = {
            sprite = love.graphics.newImage(self.spriteSheetPath.idle),
            grid= nil,
            animation_r = nil,
            animation_l = nil,
            frameN = 5
        },
        attack ={
            sprite = love.graphics.newImage(self.spriteSheetPath.atk),
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

    self.bossSprite.idle.grid = anim8.newGrid(144, 144, self.bossSprite.idle.sprite:getWidth(), self.bossSprite.idle.sprite:getHeight())
    self.bossSprite.idle.animation_r = anim8.newAnimation(self.bossSprite.idle.grid('1-5', 1), 0.15)
    self.bossSprite.idle.animation_l = anim8.newAnimation(self.bossSprite.idle.grid('1-5', 1), 0.15):flipH()

    self.bossSprite.attack.grid = anim8.newGrid(340, 286, self.bossSprite.attack.sprite:getWidth(), self.bossSprite.attack.sprite:getHeight())
    self.bossSprite.attack.animation_r = anim8.newAnimation(self.bossSprite.attack.grid('1-40', 1), 0.12)
    self.bossSprite.attack.animation_l = anim8.newAnimation(self.bossSprite.attack.grid('1-40', 1), 0.12):flipH()

    self.bossSprite.death.grid = anim8.newGrid(144, 144, self.bossSprite.death.sprite:getWidth(), self.bossSprite.death.sprite:getHeight())
    self.bossSprite.death.animation_r = anim8.newAnimation(self.bossSprite.death.grid('1-8', 1), 0.10)
    self.bossSprite.death.animation_l = anim8.newAnimation(self.bossSprite.death.grid('1-8', 1), 0.10):flipH()

    -- Set default animation
    self.currentAnimation = self.bossSprite.idle.animation_r
    self.currentAnimName = "idle"
end

function Boss:update(dt, player)
    -- Check distance to player
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx*dx + dy*dy)

    self.attackTimer = self.attackTimer - dt

    if dist <= self.attackRange then
        if self.attackTimer <= 0 then
            -- Pick a random attack
            local attackIndex = love.math.random(1, #self.attacks)
            self.currentAttack = self.attacks[attackIndex]
            self:attack()
            self.attackTimer = self.attackCooldown
        end
    end
end

function Boss:draw()

end

return Boss