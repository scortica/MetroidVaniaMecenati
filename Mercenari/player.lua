local player = {}

player.__index = player
require("globals")

--local anim8 =require("anim8")
--local image,animation


function player.new(params)
    local self = setmetatable({}, player)

    params = params or {}

    -- esempi di parametri o valori preimportati
    self.x = params.x or 800
    self.y = params.y or 500
    self.dx = 0
    self.dy = 0
    self.width = params.width or 128
    self.height = params.height or 128
    self.speed = params.speed or 3
    self.gravity = 110
    self.scale = params.scale or 1
    self.defaultSpeed = self.speed
    self.lp= params.lp or 100
    self.jumpNum = 0
    self.jumpResetTime = 0.095
    self.isJump = false
    self.collider = params.collider
    self.isGrounded = false

    self.spriteSheetPath = 'Assets/Sprites/player.png'
    self.playerSprite = nil

    self.mouseX=nil
    self.mouseY=nil

    return self
end

local debugText = true
local movementDirections={up=false,down=false,left=false,right=false,shift=false}

function player.mousepressed(x, y, button, istouch, presses)

    if button == 1 then -- Left mouse button
        if debugText then print("Left mouse button pressed") end
    end
end




---------------------------------------



function player:load()
    self.playerSprite=love.graphics.newImage(self.spriteSheetPath)
    --local grid= anim8.newGrid(64,64, image:getWidth(), image:getHeight())
    --animation = anim8.newAnimation(grid('1-10',1),0.3)
end

---------------------------------------
---FUNZIONI LOVE
function player:update(dt)
    print(self.isGrounded)
    -- Gestione del salto
    local px, py = self.collider:getLinearVelocity()
    -- Movimento laterale
    

    if self.isGrounded then
        self.jumpNum = 0
    end
    
    if self.isJump then
        
        if self.jumpNum < 1 and py > -30 and py < 30 then

            self.collider:applyLinearImpulse(0, -150)
         
            self.jumpNum = self.jumpNum + 1
        end
            self.isJump = false
    end

    if love.keyboard.isDown("a") and px >= -150 then
        --self.dx = self.speed * -1
        self.collider:applyForce(-500, 0)
    elseif love.keyboard.isDown("d") and px <= 150  then
        --self.dx = self.speed
        self.collider:applyForce(500, 0)
    else
        if px > 0 then
            self.collider:applyForce(-(px + 200), 0)
        elseif px < 0 then
            self.collider:applyForce(-(px - 200), 0)
        end
    end

    

    --self.collider:setLinearVelocity(self.dx, self.dy)
    --animation:update(dt)

end

local myColor = {1, 1, 1, 1}
	
function player:draw()
    --animation:draw(image, self.x, self.y)
    love.graphics.setColor(myColor)
    love.graphics.draw(self.playerSprite, self.x, self.y, 0, 0.5, 0.5, self.playerSprite:getWidth()/2, self.playerSprite:getHeight()/2)
end
---------------------------------------

return player