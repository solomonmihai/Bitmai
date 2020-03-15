local Help = {}

Help.lerp = function (start, _end, amt)
    return (1 - amt) * start + amt * _end
end

Help.mapValue = function (value, start1, stop1, start2, stop2)
    return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1))
end

Help.roundToDecimal = function (num, n)
    local mult = 10^(n or 0)
    return math.floor(num * mult + 0.5) / mult
end

Help.distance = function (x1, y1, x2, y2 )
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt (dx * dx + dy * dy )
end

Help.convertRGB = function (r, g, b)
    r = Help.mapValue(r, 0, 255, 0, 1)
    g = Help.mapValue(g, 0, 255, 0, 1)
    b = Help.mapValue(b, 0, 255, 0, 1)
    return {r = r, g = g, b = b}
end

Help.getMousePos = function (cam)
    local camScale = cam:getScale()
    local camX, camY = cam:getPosition()

    -- Calc mouse position in world + scren offset

    local mouseX = love.mouse.getX() * camScale  + camX - (love.graphics.getWidth() / 2 * camScale)
    local mouseY = love.mouse.getY() * camScale + camY - (love.graphics.getHeight() / 2 * camScale)

    return mouseX, mouseY
end;

Help.dump = function(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. Help.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

Help.Vector = {
    new = function(self, x, y)
        local this = setmetatable({}, { __index = self })

        this.x = x;
        this.y = y;
        this.mag = math.sqrt(this.x * this.x + this.y * this.y)

        return this
    end;

    div = function (self, amt)
        self.x = self.x / amt
        self.y = self.y / amt
    end;

    magnitude = function (self)
        return math.sqrt(self.x * self.x + self.y * self.y)
    end;

    squareMag = function(self)
        return self.x * self.x + (self.y * self.y)
    end;

    normalize = function(self)
        local m = self:magnitude()
        if m ~= 0 and m ~= 1 then
            self:div(m)
        end
        return self
    end;
}


Help.readFile = function(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

return Help
