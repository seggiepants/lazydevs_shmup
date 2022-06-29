require "draw"
require "update"

-- DoggieZone
-- 1. More bullet attributes -- done previously already have a spread shot.

-- _INIT() in Pico-8
function love.load()

    screenW = 128
    screenH = 128
    screenScale = 4
    tileSize = 8

    success = love.window.setMode(screenW * screenScale, screenH * screenScale, {resizable=false})
    if (success) then
        love.graphics.setDefaultFilter("nearest", "nearest", 1)

        font8 = love.graphics.newFont("font/Bitstream Vera Sans Mono Roman.ttf", 8, "mono", 1)
        love.graphics.setFont(font8)

        -- pico-8 graphics page
        img = love.graphics.newImage("img/graphics.png")

        white = {1, 1, 1, 1}
        -- pio-8 pallette
        pal = {{0/255, 0/255, 0/255}
        , {29/255, 43/255, 83/255}
        , {126/255, 37/255, 83/255}
        , {0/255, 135/255, 81/255}
        , {171/255, 82/255, 54/255}
        , {95/255, 87/255, 79/255}
        , {194/255, 195/255, 199/255}
        , {255/255, 241/255, 232/255}
        , {255/255, 0/255, 77/255}
        , {255/255, 163/255, 0/255}
        , {255/255, 236/255, 39/255}
        , {0/255, 228/255, 54/255}
        , {41/255, 173/255, 255/255}
        , {131/255, 118/255, 156/255}
        , {255/255, 119/255, 168/255}
        , {255/255, 204/255, 170/255}}

        quads = {}
        imgW, imgH = img:getDimensions()
        i = 0
        for y = 0, imgH - 1, tileSize
        do
            for x = 0, imgW - 1, tileSize
            do
                if x ~= 0 or y ~= 0 then
                    i = i + 1
                    quads[i] = love.graphics.newQuad(x, y, tileSize, tileSize, img)
                end
            end
        end

        sfx = {}
        sfx["laser"] = love.audio.newSource("audio/laser.wav", "static")

        shipSpr = 2
        flameSpr = 5
        lives = 3
        stars = {}
        shootOK = true
        switchOK = true
        shotType = 1
        shotTypes = {16, 103, 104, 105} -- Fire Ball, Laser, Spread, Wave
        shots = {}
        buttonReady = false
        blinkT = 1
        mode = "START"
    end
end

-- _DRAW() in PICO-8, 30 FPS
function love.draw()
    -- scale to Pico-8 screen size
    love.graphics.push()
    love.graphics.scale(screenScale, screenScale)
    
    if mode == "GAME" then
        drawGame()
    elseif mode == "GET_READY" then
        drawGetReady()
    elseif mode == "START" then
        drawStart()
    elseif mode == "OVER" then
        drawOver()
    end

    -- restore screen size
    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.quit()
    print("Goodbye")
end

--- _UPDATE in PICO-8, Hard 30 FPS
function love.update(dt)
    blinkT = blinkT + 1
    if mode == "GAME" then
        updateGame(dt)
    elseif mode == "GET_READY" then
        updateGetReady(dt)
    elseif mode == "START" then
        -- Start Screen
        updateStart(dt)
    elseif mode == "OVER" then
        -- Game Over Screen
        updateOver(dt)
    end
end

function addShot(x, y)
    shot = {}
    shot.x = x
    shot.y = y
    shot.homeX = x
    shot.homeY = y
    shot.sprite = shotTypes[shotType]
    shot.shotType = shotType
    shot.dx = 0
    shot.dy = -4
    shot.lifetime = 300

    if shotType == 2 then
        shot.lifetime = 7
    end

    if shotType == 4 then
        shot.amplitude = 1
        shot.time = 0.0
    end

    if shotType == 3 then
        for angle = 60, 120, 10 do
            newShot = {}
            for key, value in pairs(shot) do
                newShot[key] = value
            end

            newShot.dx = math.cos(math.rad(angle)) * 4
            newShot.dy = math.sin(math.rad(angle)) * -4
            table.insert(shots, newShot)
        end
    else
        table.insert(shots, shot)
    end
end

function blink()
    local blinkAni = {6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 8, 8, 7, 7, 6, 6}
    if blinkT > #blinkAni then
        blinkT = 1
    end
    return blinkAni[blinkT]
end

function bounce(x, dx, maxX)
    x = x + dx
    if x < 0 then
        x = 0
        dx = math.abs(dx)
    end
    if x > maxX then
        x = maxX
        dx = -1 * math.abs(dx)
    end

    return x, dx
end

function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end
