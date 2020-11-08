--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]

require 'Util'

Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = 4

-- PIPE tiles
PIPE_BUTTOM = 9
PIPE_TOP = 10
PIPE_MIDDLE = 11


-- a speed to multiply delta time to scroll map; smooth value
-- constructor for our map object
function Map:init()


    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.sprites = generateQuads(self.spritesheet, 16, 16)
    self.music = love.audio.newSource('sounds/Music.mp3', 'static')

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 1000
    self.mapHeight = 28
    self.tiles = {}

    -- applies positive Y influence on anything affected
    self.gravity = 20

    -- associate player with map
    self.player = Player(self)

    -- camera offsets
    self.camX = 0
    self.camY = 0

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- begin generating the terrain using vertical scan lines
    local x = 1
    while x < self.mapWidth do        

        while x > 20 and x < self.mapWidth do
            if math.random(3) == 1 then
                self:setTile(x, self.mapHeight / 2 - 3, PIPE_TOP)
                self:setTile(x, self.mapHeight / 2 - 1, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 2, PIPE_MIDDLE)

                self:setTile(x, self.mapHeight / 2 - 8, PIPE_BUTTOM)
                self:setTile(x, self.mapHeight / 2 - 9, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 10, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 11, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 12, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 13, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 14, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 15, PIPE_MIDDLE)
            
            elseif math.random(3) == 1 then
                self:setTile(x, self.mapHeight / 2 - 4, PIPE_TOP)
                self:setTile(x, self.mapHeight / 2 - 1, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 2, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 3, PIPE_MIDDLE)

                self:setTile(x, self.mapHeight / 2 - 9, PIPE_BUTTOM)
                self:setTile(x, self.mapHeight / 2 - 10, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 11, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 12, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 13, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 14, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 15, PIPE_MIDDLE)
            

            elseif math.random(3) == 1 then
                self:setTile(x, self.mapHeight / 2 - 5, PIPE_TOP)
                self:setTile(x, self.mapHeight / 2 - 1, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 2, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 3, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 4, PIPE_MIDDLE)

                self:setTile(x, self.mapHeight / 2 - 10, PIPE_BUTTOM)
                self:setTile(x, self.mapHeight / 2 - 11, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 12, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 13, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 14, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 15, PIPE_MIDDLE)
            else
                self:setTile(x, self.mapHeight / 2 - 1, PIPE_TOP)
                
                self:setTile(x, self.mapHeight / 2 - 6, PIPE_BUTTOM)
                self:setTile(x, self.mapHeight / 2 - 7, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 8, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 9, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 10, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 11, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 12, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 13, PIPE_MIDDLE)
                self:setTile(x, self.mapHeight / 2 - 14, PIPE_MIDDLE)
            end

            x = x + 5
        end
        for y = self.mapHeight / 2, self.mapHeight do
            for x = 2, self.mapWidth do
                self:setTile(x,y, TILE_BRICK)
            end
        end
        

        if x < self.mapWidth - 3 then
            local bushLevel = self.mapHeight / 2 - 1

            -- place bush component and then column of bricks
            self:setTile(x, bushLevel, TILE_EMPTY)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

            self:setTile(x, bushLevel, TILE_EMPTY)
            x = x + 1
        end

    end

    
end

-- return whether a given tile is collidable
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {
        TILE_BRICK, PIPE_BUTTOM,
        PIPE_TOP, PIPE_MIDDLE, 
    }

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

-- function to update camera offset with delta time
function Map:update(dt)
    if endgame == 2 then
        for y = 6, 10 do
            for x = 5, 400 do
                
                -- support for multiple sheets per tile; storing tiles as tables 
                self:setTile(x, y, TILE_EMPTY)
            end
        end    
        self.music:stop()
    else 
        self.music:play()
    end
    self.camX = self.camX + SCROLL_SPEED * dt
    self.player:update(dt)
    
    
end

-- gets the tile type at a given pixel coordinate
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

-- renders our map to the screen, to be called by main's render
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.sprites[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    self.player:render()
end
