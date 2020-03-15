-- libraries

local Screen = require "lib.Screen"
local JSON = require "lib.json"
local Bump = require "lib.bump"
local Gamera = require "lib.gamera"
local SM = require "lib.ScreenManager"

-- local classes

local map = require "map"

local Help = require "help"

local Player = require "player"
local Block = require "block"
local PowerUp = require "powerup"

--variables

local GameScreen = {}

-- Globals

CAMERA = nil
BUMP_WORLD = nil
PLAYER = nil
MAX_X, MAX_Y = nil, nil
SCORE = nil
ENEMY_MANAGER = require "enemy_manager"

-- locals

local camSpeed = 0.1
local camScale = 1

local blocks = {}

EMPTY_SPACES = {}

-- functions

local function loadMap()
    local coords = map.grid

    local newBlocks = {}
    local mX, mY = map.cellsX * Block.size(), map.cellsY * Block.size()

    for _, block1 in pairs(coords) do 

        local y = _ * Block.size()

        for __, block2 in pairs(block1) do
            
            local x = __ * Block.size()

            if block2 == 0 or block2 == 1 then
                newBlocks[#newBlocks + 1] = Block:new(x, y, "block")
            else 
                if math.random(0, 100) < 1 then
                    newBlocks[#newBlocks + 1] = Block:new(x, y, "grass")
                end
                
            	EMPTY_SPACES[#EMPTY_SPACES + 1] = { x = x, y = y }
            end
        end
    end

    return newBlocks, mX, mY
end 

-- Camera Shake Code --

-- Turn this var true to shake the camera

CAMERA_SHAKE = false

local shakeLength = 0.3
local shakePower = 10

-- LOST GAME EFFECT --

local lostAnimationLength = nil
LOST_GAME = nil

function GameScreen.new()
    local self = Screen.new()
    
    local started = nil

    local startingCooldown = nil

    local font1 = love.graphics.newFont("content/arcadeFont.TTF", 120)
    local font2 = love.graphics.newFont("content/arcadeFont.TTF", 90)

    local startingText = "Get ready!"

    BUMP_WORLD = Bump.newWorld(Block.size())
    blocks, MAX_X, MAX_Y = loadMap()

	-- Pre render map into spritebatch for more performance

    local blockSpritebatch = love.graphics.newSpriteBatch(IMAGES.tiles)
    
    local blocksQuad = love.graphics.newQuad(0, 0, 8, 8, 40, 8)

    -- Make Quads for every grass tile
    
    local grassQuads = {}

    for i = 1, 4 do grassQuads[#grassQuads + 1] = love.graphics.newQuad(8 * i, 0, 8, 8, 40, 8) end
    
    blockSpritebatch:clear()

    for _, block in pairs(blocks) do
    
    	if block.type == "block" then	
			blockSpritebatch:add(blocksQuad, block.x, block.y, 0, block.scaleFactor.x, block.scaleFactor.y)
		elseif block.type == "grass" then
			-- Render a random grass asset
			blockSpritebatch:add(grassQuads[math.random(#grassQuads)], block.x, block.y, 0, block.scaleFactor.x, block.scaleFactor.y)
		end
		
    end

    local blackBarHeight = 0

    local powerup = nil

    local powerUpTypes = { "speed", "bspeed", "destroy" }

    local function getPowerUpPos() 
		local space = EMPTY_SPACES[math.random(#EMPTY_SPACES)]
		local pos = { x = space.x, y = space.y }
		return pos
    end


    function self:setPowerUp()
		local type = powerUpTypes[math.random(#powerUpTypes)]
		local pos = getPowerUpPos()
		powerup = PowerUp:new(pos.x, pos.y, type)
    end
    
    function self:init()

        SCORE = 0

        CAMERA = Gamera.new(-200, -200, MAX_X + 400, MAX_Y + 600)

        LOST_GAME = false
        lostAnimationLength = 2

        PLAYER = Player:new(CAMERA)
        
        CAMERA:setPosition(PLAYER.x, PLAYER.y)
        CAMERA:setScale(camScale)

        ENEMY_MANAGER.init() 

        started = false

        startingCooldown = 3

        blackBarHeight = 0
    end

    function self:updateLostGame(dt) 
    	if LOST_GAME then
			lostAnimationLength = lostAnimationLength - dt

			if lostAnimationLength > 1.5 then blackBarHeight = blackBarHeight + dt * 200 end

			if lostAnimationLength < 0 then SM.switch("menu") end
    	end
    end

    function self:update(dt)
    
        -- Set title to current fps
        -- local memUsage = math.floor(collectgarbage('count'))
        -- love.window.setTitle("Bitmai | FPS: " .. tostring(love.timer.getFPS()) .. " | Mem Usage: " .. memUsage.. " kB")
        --

        if started and LOST_GAME == false  then 

			if powerup == nil or powerup.dead then self:setPowerUp() end

			powerup:update(dt)
        
            PLAYER:update(dt)

            if SPAWN_ENEMIES then ENEMY_MANAGER.update(dt) end

            self:updateCamera()
            
        	self:shakeGameCamera(dt)

        else
            startingCooldown = startingCooldown - dt

            if startingCooldown < 0 then started = true end
        end

       	self:updateLostGame(dt)
    end

    function self:updateCamera()
        -- Update camera position smoothly
        -- Also it won't show black parts of the world

        local halfWidth = love.graphics.getWidth() / 2
        local halfHeight = love.graphics.getHeight() / 2

        local nextCamPosX, nextCamPosY = CAMERA:getPosition()

        if PLAYER.x > halfWidth and PLAYER.x < MAX_X - halfWidth then
            nextCamPosX = Help.lerp(nextCamPosX, PLAYER.x, camSpeed)
        end
        
        if PLAYER.y > halfHeight and PLAYER.y < MAX_Y - halfHeight then
            nextCamPosY = Help.lerp(nextCamPosY, PLAYER.y, camSpeed)
        end

        CAMERA:setPosition(nextCamPosX, nextCamPosY)
    end

    function self:shakeGameCamera(dt)
    	local rand = math.random
    	if CAMERA_SHAKE then
    		shakeLength = shakeLength - dt
    
    		local xOffset = rand(-shakePower, shakePower)
    		local yOffset = rand(-shakePower, shakePower)
    
    		local camPosX, camPosY = CAMERA:getPosition()
    
    		camPosX = camPosX + xOffset
    		camPosY = camPosY + yOffset
    
    		CAMERA:setPosition(camPosX, camPosY)
    
    		if shakeLength < 0 then
    			shakeLength = 0.3
    			CAMERA_SHAKE = false
    		end
    	end
    end

    function self:draw()

        CAMERA:draw(function (l, t, w, h)

            love.graphics.draw(blockSpritebatch)

            ENEMY_MANAGER.draw()

            PLAYER:draw() 

            if started and powerup ~= nil  then powerup:draw() end
        end)

        if started == false then

            -- Draw starting countdown
        
            love.graphics.setColor(0, 0, 0, 0.8)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

            love.graphics.setColor(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b, 1)

            love.graphics.setFont(font2)
            love.graphics.printf(startingText, 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")

            love.graphics.setFont(font1)
            love.graphics.printf(math.floor(startingCooldown) + 1, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        else 
            -- Draw SCORE

            love.graphics.setFont(font2)
            love.graphics.printf(SCORE, 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")
        end

        -- If lost game then draw some bars on top and bottom of the screen for a cool effect

        if LOST_GAME then
			love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), blackBarHeight)
			love.graphics.rectangle("fill", 0, love.graphics.getHeight() - blackBarHeight, love.graphics.getWidth(), blackBarHeight)
        end
    end

    function self:resize(w, h)
        CAMERA:setWindow(0, 0, w, h)
    end

    return self
end

return GameScreen
