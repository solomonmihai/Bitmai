--[[

	Blocks are pre rendered into a spritebatch in 'game.lua' to boost performance
	
]]--

local Block = {

    size = function ()
        return 32
    end;

    new = function(self, x, y, type)
        local this = setmetatable({}, { __index = self })

        this.x = x
        this.y = y

        this.type = type

        if type == "block" then
            this.rect = { name = "Block" }
            BUMP_WORLD:add(this.rect, x, y, this.size(), this.size())
        end

        
        this.scaleFactor = {
            x = this.size() / IMAGE_SIZE,
            y = this.size() / IMAGE_SIZE
        }

        return this

    end;
}

return Block
