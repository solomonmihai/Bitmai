local Flux = require "lib.flux"

local Help = require "help"

local Button = {
    new = function(self, text, x, y, w, h, font, action)
        local this = setmetatable({}, { __index = self })

        this.text = text

        this.x = x; 
        this.y = y;
        this.w = w;
        this.h = h

        this.hoverW = this.w * 1.2
        this.hoverH = this.h * 0.9

        this.action = action

        this.font = font

        this.textWidth = font:getWidth(this.text)
        this.textHeight = font:getHeight()

        this.textX = this.x + this.w / 2 - this.textWidth / 2
        this.textY = this.y + this.h / 2 - this.textHeight / 2

        this.hover = false

        this.lastState = {}

        return this
    end;

    draw = function (this)
        -- Draw Border
        love.graphics.setLineWidth(6)

        if this.hover then 
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", this.x - (this.hoverW - this.w) / 2, this.y - (this.hoverH - this.h) / 2, this.hoverW, this.hoverH)
        else
            love.graphics.rectangle("line", this.x, this.y, this.w, this.h)
        end

        love.graphics.setLineWidth(1)

        -- Draw text

        love.graphics.setFont(this.font)
        love.graphics.print(this.text, this.textX, this.textY)

        love.graphics.setColor(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b)
    end;

    update = function(this, dt)
        this:checkHover()

        if this.hover and love.mouse.isDown(1) == false and this.lastState == true then
            this.canPerform = false
            this.action()
        end

        this.lastState = love.mouse.isDown(1)
    end;

    checkHover = function (this)
        local mouseX, mouseY = love.mouse.getPosition()
        mouseX, mouseY = UI_CAMERA:toWorld(mouseX, mouseY)

        if mouseX > this.x and mouseX < this.x + this.w and mouseY > this.y and mouseY < this.y + this.h then
            this.hover = true
        else
            this.hover = false
        end
    end
}

return Button
