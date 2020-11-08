Class = require 'class'
push = require 'push'

require 'Animation'
require 'Map'
require 'Player'

-- close resolution to NES but 16:9
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

endgame = 0
SCROLL_SPEED = 0 
Score = 0


-- actual window resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- seed RNG
math.randomseed(os.time())

-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')

-- an object to contain our map data
map = Map()

-- performs initialization of all objects and data needed by program
function love.load()    
    --scoreFont = love.graphics.newFont('fonts/font.ttf', 16)
    
    -- sets up virtual screen resolution for an authentic retro feel
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })
    love.window.setTitle('Flappy bird')

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end


-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is pressed
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'space' then
        if endgame == 2 then endgame = 0 end
    end
    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- called every frame, with dt passed in as delta in time since last frame
function love.update(dt)
    map:update(dt)

    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- called each frame, used to render to the screen
function love.draw()

    -- begin virtual resolution drawing
    push:apply('start')
    love.graphics.clear(108/255, 140/255, 255/255, 255/ 255)
    if endgame == 0 then
        love.graphics.clear(108/255, 140/255, 255/255, 255/255)
        SCROLL_SPEED = 0
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 16))
        love.graphics.print('Welcome to Flappy bird!',5, 20)
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 8))
        love.graphics.print('Press space to begin',15, 40)
    elseif endgame == 1 then
        displayScore()
        SCROLL_SPEED = 125
    elseif endgame == 2 then
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 40))
        love.graphics.print('Game over!',100, 85)
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 17))
        love.graphics.print('Your Score is '..tostring(math.floor(Score)) ,140, 130)
    end

    -- renders our map object onto the screen
    love.graphics.translate(math.floor(-map.camX ), math.floor(-map.camY ))
    map:render()

    -- end virtual resolution
    push:apply('end')
end

function displayScore()
    love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 10))
    love.graphics.print(tostring(math.floor(Score)))
end
