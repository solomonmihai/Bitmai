local Screen = require "lib.Screen"
local SM = require "lib.ScreenManager"
local Gamera = require "lib.gamera"

local Button = require "button"

local Help = require "help"

local Menu = {}

UI_CAMERA = {}

function Menu.new() 
    local self = Screen.new()

    local title = "BITMAI"

    local font = love.graphics.newFont("content/arcadeFont.TTF", 120)
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

    local titleX = screenW / 2 - font:getWidth(title) / 2
    local titleY = screenH / 3 - font:getHeight() / 2

    local buttonFont = love.graphics.newFont("content/arcadeFont.TTF", 60)

    local playButton = Button:new("Play", screenW / 2 - 100, titleY + font:getHeight() * 1.2, 200, 75, buttonFont, function ()
        SM.switch("game")
    end)
    
    local soundButton = Button:new("Sound", screenW / 2 - 100, titleY + font:getHeight() * 1.9, 200, 75, buttonFont, function() 
		if SOUND_ON then SOUND_ON = false else SOUND_ON = true end
    end)
    
    local exitButton = Button:new("Exit", screenW / 2 - 100, titleY + font:getHeight() * 2.6, 200, 75, buttonFont, function ()
        love.event.quit()
    end)

    function resize() 
        local camScale = Help.mapValue(love.graphics.getWidth(), 800, 1920, 1, 1.5)
        UI_CAMERA:setScale(camScale)
    end

    UI_CAMERA = Gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    resize()

    function self:update(this, dt)
        playButton:update(dt)
        soundButton:update(dt)
        exitButton:update(dt)
    end

    function self:draw(this)

        UI_CAMERA:draw(function ()    

            love.graphics.setFont(font)

            -- Draw Title
            love.graphics.print(title, titleX, titleY)

            playButton:draw()
            soundButton:draw()
            exitButton:draw()
        end)

    end

    function self:keypressed(key, scancode, isrepeat)
        
    end

    function self:resize(w, h)
        UI_CAMERA:setWindow(0, 0, w, h)
        resize()
    end

    return self
end

return Menu
