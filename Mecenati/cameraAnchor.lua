local CameraAnchor = {}
CameraAnchor.__index = CameraAnchor

function CameraAnchor.new(x, y, smooth)
    local self = setmetatable({}, CameraAnchor)
    self.x = x or 0
    self.y = y or 0
    self.smooth = smooth or 5 -- higher = faster follow
    return self
end

function CameraAnchor:update(dt, targetX, targetY)
    -- Smoothly interpolate towards the target (player)
    self.x = self.x + (targetX - self.x) * math.min(self.smooth * dt, 1)
    self.y = self.y + (targetY - self.y) * math.min(self.smooth * dt, 1)
end

return CameraAnchor