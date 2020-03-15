local Help = require "help"

local Vector = require "help".Vector

local Boomerang = require "boomerang"

local Anim8 = require "lib.anim8"

local Player = {
    new = function(self, cam) 

        -- "this" can only be used inside constructor
        
        local this = setmetatable({}, { __index = self }) 

        this.size = require "block".size()

		this.initialSpeed = 200
        this.speed = this.initialSpeed

        this.x = MAX_X / 2
        this.y = love.graphics.getHeight() * 0.7

        this.rect = { name = "Player" }
        BUMP_WORLD:add(this.rect, this.x, this.y, this.size, this.size)

        this.cam = cam

        this.boomerang = Boomerang:new(this)

        -- Animation stuff

        this.moving = false

        this.scaleFactor = this.size / 8

        this.image = love.graphics.newImage("content/images/player.png")
        local idleGrid = Anim8.newGrid(8, 8, this.image:getWidth(), this.image:getHeight())
        local runGrid = Anim8.newGrid(8, 8, this.image:getWidth(), this.image:getHeight(), 0, 8, 0)
        this.idle = Anim8.newAnimation(idleGrid("1-3", 1), 0.15)
        this.run = Anim8.newAnimation(runGrid("1-3", 1), 0.1)
        this.currentAnim = this.idle

        -- Particles

        -- Spawn some steps every 0.1 seconds for a cool effect

        this.stepEffect = love.graphics.newParticleSystem(IMAGES.steps, 32)
        this.stepEffect:setSpeed(0)
        this.stepEffect:setParticleLifetime(1)
        this.stepEffect:setSizes(this.scaleFactor, this.scaleFactor * 0.9)

        this.placeStepsCD = 0.1

        -- POWERUPS Stuff --

        this.powerUp = nil

        this.powerUpsDuration = {
        	speed = 5,
        	bspeed = 4,
        	bsize = 4,
        	destroy = 0.01
        }

        this.currentPowerUpDuration = nil

        return this
    end;

    setPowerUp = function(this, type)
		this.powerUp = type
		this.currentPowerUpDuration = this.powerUpsDuration[type]
    end;

    updatePowerUps = function(this, dt)
    	if this.currentPowerUpDuration ~= nil and this.currentPowerUpDuration > 0 and this.powerUp ~= nil then
			this.currentPowerUpDuration = this.currentPowerUpDuration - dt

			-- Approach every powerup case and do the specified task

			if this.powerUp == "speed" then this.speed = this.initialSpeed * 1.5
			elseif this.powerUp == "bspeed" then this.boomerang.speedIncrementor = this.boomerang.initialSpeedIncrementor * 2.5
			elseif this.powerUp == "destroy" then
				for _, enemy in pairs(ENEMY_MANAGER.enemies) do
					enemy.dead = true
				end
			end
			
    	else 

    		-- Reset powerup when finished
	    	if this.powerUp == "speed" then 
				this.speed = this.initialSpeed
			elseif this.powerUp == "bspeed" then
				this.boomerang.speedIncrementor = this.boomerang.initialSpeedIncrementor
			end
			
    		this.powerUp = nil
    		this.currentPowerUpDuration = nil
    	end
    end;

    move = function (this, dt)
        -- Update coordinates using WASD keys
        -- Then pass the them to BUMP and get em back to resolve collisions

        local vel = Vector:new(0, 0)

        if love.keyboard.isDown("w") then
            vel.y = -1
        end
        if love.keyboard.isDown("s") then
            vel.y = 1
        end
        if love.keyboard.isDown("a") then
            vel.x = -1
        end
        if love.keyboard.isDown("d") then
            vel.x = 1
        end

        if vel.x ~= 0 or vel.y ~= 0 then this.moving = true else this.moving = false end

        vel = vel:normalize()

        local speed = this.speed
        if this.boomerang.attached == false then speed = this.speed * 2 end

        local nextPos = {
            x = this.x + vel.x * speed * dt,
            y = this.y + vel.y * speed * dt
        }
        this.x, this.y = BUMP_WORLD:move(this.rect, nextPos.x, nextPos.y, this.filter)
    end;

    filter = function(item, other) 
        if other["name"] == "Boomerang" then 
        	return false
        else 
            return "slide" 
        end
    end;

    update = function (this, dt)

        if love.keyboard.isDown("space") then print("S") end

        this:move(dt)

        this:updateAnimation(dt)

        this.boomerang:update(dt)

        this:updatePowerUps(dt)

        this.stepEffect:update(dt)

        if this.moving then

            this.placeStepsCD = this.placeStepsCD - dt

            if this.placeStepsCD < 0 then
                this.placeStepsCD = 0.1

                this.stepEffect:setPosition(this.x + this.size / 2, this.y + this.size / 2)
                this.stepEffect:setColors(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b, 1, CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b, 0)
                this.stepEffect:emit(1)

            end
        end
    end;

    updateAnimation = function(this, dt)
        this.currentAnim:update(dt)

        -- Swap animations according to moving state

        if this.moving and this.currentAnim ~= this.run then this.currentAnim = this.run 

        elseif this.moving == false and this.currentAnim ~= this.idle then this.currentAnim = this.idle end
    end;

    draw = function (this)

        love.graphics.draw(this.stepEffect)

        love.graphics.setColor(1, 1, 1, 1)
        this.boomerang:draw()
        this.currentAnim:draw(this.image, this.x, this.y, 0, this.scaleFactor, this.scaleFactor)
        
        love.graphics.setColor(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b)
    end;
}

return Player
