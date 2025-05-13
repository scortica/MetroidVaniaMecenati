local player = {}

player.__index = player
require("globals")

--local anim8 =require("anim8")
--local image,animation


function player.new(params)
    local self = setmetatable({}, player)

    params = params or {}

    -- esempi di parametri o valori preimportati
    self.x = params.x or 100
    self.y = params.y or 100
    self.width = params.width or 10
    self.height = params.height or 10
    self.speed = params.speed or 3
    self.scale = params.scale or 1
    self.defaultSpeed = self.speed
    self.lp= params.lp or 100

    self.isjump=false
    self.jumpHeight=30
    self.jumpVelocity = 100 -- Velocità del salto
    self.groundLevel = self.y -- Livello del suolo

    --self.spriteSheetPath = 'sprites/playerSheet.png'

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

--[[local function atan2(x,y)
    if x>0 then return math.atan(y/x)
    elseif x<0 and y>=0 then return math.atan(y/x)+math.pi
    elseif x<0 and y<0 then return math.atan(y/x)-math.pi
    elseif x==0 and y>0 then return math.pi/2
    elseif x==0 and y<0 then return -math.pi/2
    else return 0 --nel caso in cui x e y sono 0 end 
    end
end

function player:getLookAtPointRotation()
    return atan2((self.x-self.mouseX),(self.y-self.mouseY))-math.pi/2
end]]
---------------------------------------


function player:load()
    --image=love.graphics.newImage(self.spriteSheetPath)
    --local grid= anim8.newGrid(64,64, image:getWidth(), image:getHeight())
    --animation = anim8.newAnimation(grid('1-10',1),0.3)
    print("Player loaded")
end

---------------------------------------
---FUNZIONI LOVE
function player:update(dt)

    -- Gestione del salto
    if self.isjump then
        self.y = self.y - self.jumpVelocity * dt
        

        if  self.y >= self.groundLevel + self.jumpHeight then
            self.y = self.y + self.jumpHeight
        end

        -- Controllo per atterraggio
        if self.y >= self.groundLevel then
    
        end
    end

    -- Movimento laterale
    if love.keyboard.isDown("a") then
        if not movementDirections.left and not movementDirections.right then
            self.x = self.x - self.speed * dt
        end
    end

    if love.keyboard.isDown("d") then
        if not movementDirections.right and not movementDirections.left then
            self.x = self.x + self.speed * dt
        end
    end


    --animation:update(dt)

end

local myColor = {1, 1, 1, 1}
	
function player:draw()
    --animation:draw(image, self.x, self.y)
    love.graphics.setColor(myColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
---------------------------------------

return player