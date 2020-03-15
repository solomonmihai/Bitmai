--[[

BITMAI

TOP DOWN ACTION RPG

Mai -- Main Character
    -- Uses boomerang to kill different enemies
    -- boomerang has some special powers that can be found
       random across map
    -- Kill multiple types of enemies using it

Game -- Arcade style
     -- Wirh some type of easter eggs
     -- Works around colors
     -- Graphics rely on cool color effects and particles 
        because I dont know how to draw 
     -- 3 Power ups
     -- Fluent gameplay

I used CAPS words for all global variables
so I won't mistype them with locals

]]--



local SM = require "lib.ScreenManager"

local Help = require "help"

local Flux = require "lib.flux"

CURRENT_COLOR = {}

IMAGES = {}
SOUNDS = {}

IMAGE_SIZE = 8

local colors = {
    Help.convertRGB(50, 168, 82),
    Help.convertRGB(36, 214, 214),
    Help.convertRGB(187, 22, 224),
    Help.convertRGB(237, 234, 31),
    Help.convertRGB(34, 31, 237),
    Help.convertRGB(237, 21, 21),
    Help.convertRGB(237, 21, 21),
    Help.convertRGB(255, 255, 255),
    Help.convertRGB(82, 82, 255),
    Help.convertRGB(82, 255, 171),
    Help.convertRGB(74, 74, 74),
}

local color = { r = 1, g = 1, b = 1 }

local nextColor = colors[math.random(#colors)]

local changeColorCD = 3
local c_changeColorCD = changeColorCD

local function loadImages()
	IMAGES.tiles = love.graphics.newImage("content/images/tiles.png")
    
    IMAGES.dorf = love.graphics.newImage("content/images/dorf.png")

    IMAGES.steps = love.graphics.newImage("content/images/steps.png")
end

local function loadSounds()
	SOUNDS.dorfExplosion = love.audio.newSource("content/sounds/dorf_explosion.wav", "static")

	SOUNDS.throwBoomerang = love.audio.newSource("content/sounds/throwBoomerang.wav", "static")

	SOUNDS.themeSound = love.audio.newSource("content/sounds/themeSound.ogg", "stream")
	SOUNDS.themeSound:setLooping(true)
	SOUNDS.themeSound:setVolume(0.7)
end

SOUND_ON = true

SPAWN_ENEMIES = true

function playSoundFX(source) 
	if SOUND_ON then
		source:seek(0, "seconds")
		source:play()
	end
end

function love.load()
    love.window.setTitle("Bitmai")
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    loadImages()
    loadSounds()

    local screens = {
        game = require "game",
        menu = require "menu"
    }

    SM.init(screens, "menu")
end

function love.draw()
    love.graphics.clear(0, 0, 0, 1)
        
    love.graphics.setColor(CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b)
    SM.draw()
end

function love.update(dt)

	if SOUNDS.themeSound:isPlaying() == false and SOUND_ON then 
		SOUNDS.themeSound:play()
	end

	if SOUNDS.themeSound:isPlaying() and SOUND_ON == false then
		SOUNDS.themeSound:pause()
	end

    Flux.update(dt)

    Flux.to(color, changeColorCD, {r = nextColor.r, g = nextColor.g, b = nextColor.b})

	-- Lerp through colors every 3 seconds for a cool effect

    c_changeColorCD = c_changeColorCD - dt

    if c_changeColorCD < 0 then
        c_changeColorCD = changeColorCD
        
        nextColor = colors[math.random(#colors)]
        
        Flux.to(color, changeColorCD, {r = nextColor.r, g = nextColor.g, b = nextColor.b})
    end

    CURRENT_COLOR = color

    SM.update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    SM.keypressed(key, scancode, isrepeat)
end

function love.resize(w, h)
    SM.resize(w, h)
end
