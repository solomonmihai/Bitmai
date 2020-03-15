local Anim8 = require "lib.anim8"

local Flux = require "lib.flux"

local Vector = require "help".Vector

local distance = require "help".distance

local Dorf = {
    new = function (self, x, y)
        local this = setmetatable({}, { __index = self })

        -- Animation

        this.image = IMAGES.dorf
        local grid = Anim8.newGrid(8, 8, this.image:getWidth(), this.image:getHeight())
        this.anim = Anim8.newAnimation(grid("1-3", 1), 0.1)

        -- Mechanics

        this.x = x;
        this.y = y;
        this.size = require "block".size()
        this.scaleFactor = this.size / 8
        this.speed = 300
        
        this.dead = false

        this.rect = { name = "Dorf" }
        BUMP_WORLD:add(this.rect, this.x, this.y, this.size, this.size)

        return this
    end;

    draw = function (this)
        love.graphics.setColor(1, 0, 0)
        this.anim:draw(this.image, this.x, this.y, 0, this.scaleFactor, this.scaleFactor)
        love.graphics.setColor(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b)
    end;

    update = function (this, dt)
        this.anim:update(dt)

        -- Follow player

        local dir = Vector:new(PLAYER.x - this.x, PLAYER.y - this.y)
        dir = dir:normalize()

        local x = this.x + this.speed * dt * dir.x
        local y = this.y + this.speed * dt * dir.y

        if this.dead == false then this.x, this.y = BUMP_WORLD:move(this.rect, x, y, this.filter) end        

        if distance(this.x, this.y, PLAYER.boomerang.x, PLAYER.boomerang.y) < this.size * 1.2 then this.dead = true end

		if this.dead == true then BUMP_WORLD:remove(this.rect) end        
    end;


    filter = function(item, other)
		if other["name"] == "Boomerang" then return false else return "slide" end
    end;
}

return Dorf
