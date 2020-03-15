local Help = require "help"

local Vector = require "help".Vector

local Boomerang = {
    new = function (self, player)
        local this = setmetatable({},{ __index = self })

        this.image = love.graphics.newImage("content/images/boomerang.png")

        this.size = 32
        this.scaleFactor = this.size / this.image:getWidth()

        this.player = player

        this.x = player.x
        this.y = player.y

        -- Place origin in center of image so it will pivot rotation in that point
        this.origin = { x = this.image:getWidth() / 2, y = this.image:getHeight() / 2}

        this.rotation = 0

        this.attached = true

        this.canLaunch = false

        this.start = {x = 0, y = 0}
        this.target = {x = 0, y = 0}

        this.speed = 700
        this.currentSpeed = this.speed
        this.initialSpeedIncrementor = 1000
        this.speedIncrementor = this.initialSpeedIncrementor

        this.travelTime = 0
        this.maxTravelTime = 1

        
	    this.filter = function(item, other) 
	        if other["name"] == "Block" then 
	            this.travelTime = this.maxTravelTime
	            return "touch"
	        else return false end
	    end;

        -- Collison stuff

        this.rect = { name = "Boomerang" }

        -- Particle stuff

        this.trail = love.graphics.newParticleSystem(this.image, 32)

        this.trail:setSpeed(0)
        this.trail:setParticleLifetime(0.1)
        this.trail:setSizes(this.scaleFactor * 1.1, this.scaleFactor, this.scaleFactor / 10)
        
       return this
    end;

    draw = function (this)
        
        love.graphics.draw(this.image, this.x + this.size / 2, this.y + this.size / 2, this.rotation, this.scaleFactor, this.scaleFactor, this.origin.x, this.origin.y)
        
        love.graphics.draw(this.trail)

        -- -- Debugging rectangle
        -- love.graphics.setColor(1, 0, 0)
        -- love.graphics.rectangle("line", this.x, this.y, this.size, this.size)
        -- love.graphics.setColor(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b)
    end;

    calcIdlePos = function (this)
        
        local mouseX, mouseY = Help.getMousePos(this.player.cam)

        local angle = math.atan2(mouseY - this.player.y, mouseX - this.player.x)

        -- Calc boomerang position according to mouse position in world

        local newX = this.player.x + math.cos(angle) * this.size
        local newY = this.player.y + math.sin(angle) * this.size

        return newX, newY
    end;

    ----------------- Main Mechanics -------------------

    update = function (this, dt)

        if this.attached then
            this.x, this.y = this:calcIdlePos()
        else

            -- Main mechanic
            -- launch and return to player after an amount of distance
            -- Or if you hit a wall

            local dir = Vector:new(this.target.x - this.start.x, this.target.y - this.start.y)
            dir = dir:normalize()

            -- Slow down as it gets closer to the target point

            this.x = this.x + dir.x * this.currentSpeed * dt
            this.y = this.y + dir.y * this.currentSpeed * dt
            

            BUMP_WORLD:move(this.rect, this.x, this.y, this.filter)

            -- Increase rotation for a cooler effect
            this.rotation = this.rotation + 10 * dt

            if this.travelTime >= this.maxTravelTime then

                -- After it traveld an amount of time 

                -- Increase speed when coming back to player
                this.currentSpeed = this.currentSpeed + this.speedIncrementor * dt
                
                this.target.x, this.target.y = this.player.x, this.player.y
                this.start.x, this.start.y = this.x, this.y
            else 
                
                this.travelTime = this.travelTime + dt  
                
                -- Decrease speed as it gets colser to the target
                if this.currentSpeed > 0 then 
                	this.currentSpeed = this.currentSpeed - this.speedIncrementor / 2 * dt 
                else
                	this.travelTime = this.maxTravelTime
                end
            end

            
            -- IF boomerang is close to player, attach it to the player
            if Help.distance(this.x, this.y, this.player.x, this.player.y ) < this.size / 2 then 
                
                this.attached = true
                this.travelTime = 0

                -- Remove body from world if it is attached
                BUMP_WORLD:remove(this.rect)
            end

            
            -- Emit particles
            -- Update position color and rotation
            this.trail:setPosition(this.x + this.size / 2, this.y + this.size / 2)
            this.trail:setColors(1, 1, 1, 1, CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b, 1)
            this.trail:setRotation(this.rotation)
            this.trail:emit(1)

        end


        -- if left click is down
        if love.mouse.isDown(1) and this.attached then 

            this.canLaunch = false
            this.attached = false

            playSoundFX(SOUNDS.throwBoomerang)

            -- Include rect to the world if it's detached
            BUMP_WORLD:add(this.rect, this.x, this.y, this.size, this.size)

            -- set starting point and target point according to self position and mouse position

            local mouseX, mouseY = Help.getMousePos(this.player.cam)

            this.target.x, this.target.y = mouseX, mouseY
            this.start.x, this.start.y = this.x, this.y

            this.currentSpeed = this.speed

        else this.canLaunch = true end

        -- Update Particles
        this.trail:update(dt)
        
    end;
}

return Boomerang
