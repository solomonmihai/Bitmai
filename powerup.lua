--[[ 
	
	-- Will give tha player some better stats for an amount of time
	
	Available types:

	- speed   	-> Increase player speed
	- bspeed  	-> Increase boomerang speed
	- destroy   -> Destroy all enemies in player range
		
]]--

local distance = require "help".distance
local blockSize = require "block".size()

local PowerUp = {
	new = function (self, x, y, type)
		local this = setmetatable({}, { __index = self })

		this.x = x
		this.y = y

		this.type = type

		this.pSystem = love.graphics.newParticleSystem(love.graphics.newImage("content/images/boomerang.png"), 100)
		-- Set Particle System Settings --

		this.pSystem:setColors(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b, 1, CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b, 0)
		this.pSystem:setColors(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b, 1, CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b, 0)
		this.pSystem:moveTo(this.x, this.y)
		this.pSystem:setParticleLifetime(1, 1.5)
		this.pSystem:setSizes(5, 0)
		this.pSystem:setSizeVariation(0.5)
		this.pSystem:setSpeed(50, 0)
		this.pSystem:setDirection(-math.pi / 2)
		this.pSystem:setSpread(math.pi / 10)
		this.pSystem:setSpin(math.pi)
		this.pSystem:setSpinVariation(1)
		------

		this.consumed = false
		this.dead = false
    
		return this
	end;

	draw = function(this) 
		love.graphics.setColor(1, 1, 1, 1)
		
		love.graphics.draw(this.pSystem)
		
		love.graphics.setColor(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b, 1)
	end;

	update = function(this, dt)
	
		-- Check distance to player

		if this.consumed == false then
			if  distance(this.x, this.y, PLAYER.x, PLAYER.y) < blockSize * 2 and this.consumed == false then this:consume() end

			this.pSystem:emit(1)		
		else
			if this.pSystem:getCount() == 0 then this.dead = true end 
		end

		this.pSystem:update(dt)
		
	end;

	consume = function(this)

		-- Change particles from "fire" to explosion
	    this.pSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0)
	    this.pSystem:setSizes(2, 8, 0, 0)
	    this.pSystem:setSpeed(240, 200)
	    this.pSystem:setLinearAcceleration(0, 0)
	    this.pSystem:setParticleLifetime(0.8)
	    this.pSystem:setSpread(2 * math.pi)
		
		this.pSystem:emit(30)
		this.consumed = true
		PLAYER:setPowerUp(this.type)
	end;
}

return PowerUp
