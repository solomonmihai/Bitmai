-- Takes care of every enemy in game

local Help = require "help"

local Dorf = require "dorf"

local enemy_manager = {}

enemy_manager.enemies = {}

local spawnCooldown = 5

local pSystem = nil

-- Every amount seconds increase number of enemies spawned
local spawnCount = 0
local increaseSpawnTimer = 0
local increaseSpawnCD = nil

function explosionEffect(x, y)

    -- Set particle settings

    pSystem:moveTo(x, y)
    
    pSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    
    pSystem:setSizes(2, 8, 0, 0)

    pSystem:setSpeed(240, 200)

    pSystem:setLinearAcceleration(0, 0)

    pSystem:setParticleLifetime(0.8)

    pSystem:setSpread(2 * math.pi)

    pSystem:emit(30)
end

local function getSpawnPosition(l, t, w, h) 
    local space = EMPTY_SPACES[math.random(#EMPTY_SPACES)]

    if space.x < l or space.y < t or space.x > l + w or space.y > t + h then return space.x, space.y else return getSpawnPosition(l, t, w, h) end
end

local distance = Help.distance
local size = 0

enemy_manager.init = function ()
    
    enemy_manager.enemies = {}

	spawnCount = 5
	increaseSpawnTimer = 10
	increaseSpawnCD = increaseSpawnTimer

    size = require "block".size()

    pSystem = love.graphics.newParticleSystem(love.graphics.newImage("content/images/circle.png"), 100)

	local l, t, w, h = CAMERA:getVisible()

    for _ = 1, 5 do 
        local d = Dorf:new(getSpawnPosition(l, t, w, h))
        enemy_manager.enemies[#enemy_manager.enemies+1] = d
    end
end

enemy_manager.update = function (dt)

    for i, enemy in pairs(enemy_manager.enemies) do 
        if enemy.dead == false then 
            enemy:update(dt)

			-- Check if enemy touches player

			if distance(enemy.x + size / 2, enemy.y + size / 2, PLAYER.x + size / 2, PLAYER.y + size / 2) < size * 1.3 then LOST_GAME = true end
            
        else

        	CAMERA_SHAKE = true
 			explosionEffect(enemy.x, enemy.y)
 			playSoundFX(SOUNDS.dorfExplosion)

            SCORE = SCORE + 1
            
            table.remove(enemy_manager.enemies, i)
        end
    end

	-- Increase spawn count every amount of seconds

	increaseSpawnCD = increaseSpawnCD - dt
	if increaseSpawnCD < 0 then
		increaseSpawnCD = increaseSpawnTimer
		spawnCount = spawnCount + 2
	end

	-- Spawn enemies every amount of time

    spawnCooldown = spawnCooldown - dt
    if spawnCooldown < 0 and #enemy_manager < 15 then
        spawnCooldown = 5

		local l, t, w, h = CAMERA:getVisible()

        for _ = 1, 5 do 
            local d = Dorf:new(getSpawnPosition(l, t, w, h))
            enemy_manager.enemies[#enemy_manager.enemies+1] = d
        end
    end

    pSystem:update(dt)
end

enemy_manager.draw = function ()

    local l, t, w, h = CAMERA:getVisible()

    for _, enemy in pairs(enemy_manager.enemies) do 
        if enemy.x > l - 40 and enemy.x < l + w + 40 and enemy.y > t - 40 and enemy.y < t + h + 4 then
            enemy:draw() 
        end
    end

    love.graphics.draw(pSystem)
end

return enemy_manager
