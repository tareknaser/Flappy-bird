--[[
    Represents our player in the game, with its own sprite.
]]

Player = Class{}

local WALKING_SPEED = 120
local JUMP_VELOCITY = 300 

function Player:init(map)
    
    self.x = 0
    self.y = 0
    self.width = 12
    self.height = 16

    -- offset from top left to center to support sprite flipping
    self.xOffset = 8
    self.yOffset = 10

    -- reference to map for checking tiles
    self.map = map
    self.texture = love.graphics.newImage('graphics/Flappybird.png')

    -- sound effects
    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['game-over'] = love.audio.newSource('sounds/game-over.mp3', 'static'),
        ['coin'] = love.audio.newSource('sounds/coin.wav', 'static')
    }

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'start'

  
    -- x and y velocity
    self.dx = 0
    self.dy = 0

    -- position on top of map tiles
    self.y = (map.tileHeight * ((map.mapHeight - 2) / 2) - self.height) - 80
    self.x = map.tileWidth * 10 + 45

    -- initialize all player animations
    self.animations = {
        ['start'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, 16, 20, self.texture:getDimensions())
            }
        }), 
        ['Play'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(128, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(160, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
            },
            interval = 0.15
        })
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['start']
    self.currentFrame = self.animation:getCurrentFrame()

    -- behavior map we can call based on player state
    self.behaviors = {
        ['start'] = function(dt)
            endgame = 0
            -- add spacebar functionality to trigger jump state
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'Play'
                self.animation = self.animations['Play']
                self.sounds['jump']:play()
            else
                self.dx = 0
            end
        end,

        ['end'] = function(dt)
            self.dx = 0
            self.dy = 0
            SCROLL_SPEED = 0
            endgame = 2
            self.animation = self.animations['start']
            --self.sounds['game-over']:play()
            love.audio.play(self.sounds['game-over'])
        end,
        
        ['Play'] = function(dt)
            endgame = 1


            if self.y > 300 then
                return
            end
            self.dx = WALKING_SPEED

            if love.keyboard.wasPressed('space') then
                Score = Score + 0.5
                self.dy = -JUMP_VELOCITY
                self.sounds['jump']:play()
                self.dx =  WALKING_SPEED
            end

            

            -- apply map's gravity before y velocity
            self.dy = self.dy + self.map.gravity

            -- check if there's a tile directly beneath us
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                -- if so, reset velocity and position and change state
                self.state = 'end'
                self.animation = self.animations['start']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            
        end
    }
end

function Player:update(dt)
    if endgame == 2 then
        self.x = 0
        self.y = 0
    end
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt


    self:calculateJumps()

    -- apply velocity
    self.y = self.y + self.dy * dt
end

-- Play and block game-overting logic
function Player:calculateJumps()
    
    -- if we have negative y velocity (Play), check if we collide
    -- with any blocks above us
    if self.dy < 0 then
        if self.map:tileAt(self.x, self.y).id ~= TILE_EMPTY or
            self.map:tileAt(self.x + self.width - 1, self.y).id ~= TILE_EMPTY then
            -- reset y velocity
                self.state = 'end'
        end
    end
end


-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
            self.state = 'end'
        end
    end
end

function Player:render()
    local scaleX


    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, scaleX, 1, self.xOffset, self.yOffset)
end
