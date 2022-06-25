require "draw"
require "update"

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

        love.graphics.setColor(pal[8])

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

        shipX = (screenW - tileSize) / 2
        shipY = (screenH - tileSize) / 2
        shipSx = 0
        shipSy = 0
        shipSpr = 2
        flameSpr = 5
        muzzle = 0
        score = love.math.random(1000)
        lives = 3
        local starClr = {6, 7, 8, 16}
        stars = {}
        for i=1,100 do
            star = {} 
            star.x = love.math.random(screenW)
            star.y = love.math.random(screenH)
            star.clr = starClr[love.math.random(#starClr)]
            star.spd = love.math.random() * 3 + 1
            table.insert(stars, star)
        end

        bulX = 64
        bulY = 40
        shootOK = true
        switchOK = true
        shotType = 1
        shotTypes = {16, 103, 104, 105} -- Fire Ball, Laser, Spread, Wave
        shots = {}
    end
end

-- _DRAW() in PICO-8, 30 FPS
function love.draw()
    -- scale to Pico-8 screen size
    love.graphics.push()
    love.graphics.scale(screenScale, screenScale)
    
    love.graphics.clear(pal[1])
    drawStarfield()

    for key, shot in ipairs(shots) do
        if shot.shotType == 2 then --laser
            y = shot.y
            while y > -1 * tileSize do
                spr(shot.sprite, shot.x, y)
                y = y - tileSize
            end
        else
            spr(shot.sprite, shot.x, shot.y)
        end
    end

    spr(shipSpr, shipX, shipY)
    spr(flameSpr, shipX, shipY + tileSize)
    if muzzle > 0 then
        love.graphics.setColor(pal[7])
        love.graphics.circle("fill", shipX + 4, shipY - 2, muzzle)
    end
    --spr(2, bulX, bulY)

    love.graphics.setColor(pal[12])
    love.graphics.print("SCORE: " .. score, 40, 1)
    -- Lives
    for i=1,4 do
        if lives >= i then
            spr(13, i * 9 - 8, 1)
        else
            spr(14, i * 9 - 8, 1)
        end
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
    shipSx = 0
    shipSy = 0
    shipSpr = 2
    flameSpr = flameSpr + 1
    if flameSpr > 9 then
        flameSpr = 5
    end

    if love.keyboard.isDown("up") then
        shipSy = -2
    end

    if love.keyboard.isDown("down") then
        shipSy = 2
    end

    if love.keyboard.isDown("left") then
        shipSx = -2
        shipSpr = 1
    end

    if love.keyboard.isDown("right") then
        shipSx = 2
        shipSpr = 3
    end

    if love.keyboard.isDown("space") or love.keyboard.isDown("z") then
        if shootOK then
            --bulX = shipX
            --bulY = shipY - (tileSize/2)
            addShot(shipX, shipY - (tileSize / 2))
            love.audio.play(sfx["laser"])
            muzzle = 7
            shootOK = false
        end
    else
        shootOK = true
    end

    if love.keyboard.isDown("tab") or love.keyboard.isDown("x") then
        if switchOK then
            shotType = shotType + 1
            if shotType > 4 then
                shotType = 1
            end
            switchOK = false
        end
    else
        switchOK = true
    end

    -- Moving the ship
    shipX = shipX + shipSx
    shipY = shipY + shipSy

    if shipX < -1 * tileSize then
        shipX = screenW
    elseif shipX > screenW then
        shipX = -1 * tileSize
    end

    if shipY < -1 * tileSize then
        shipY = screenH
    elseif shipY > screenH then
        shipY = -1 * tileSize
    end

    -- Move the bullet
    --bulY = bulY - 4

    for key, shot in ipairs(shots) do
        if shot.shotType == 4 then -- wave
            shot.x = shot.x + (math.cos(shot.time) * shot.amplitude)
            shot.time = shot.time + .75
            shot.amplitude = shot.amplitude + .75
        else
            shot.x = shot.x + shot.dx
        end
        shot.y = shot.y + shot.dy
        if shot.lifetime < 0 or 
            shot.y < -1 * tileSize or
            shot.y > screenH + tileSize or
            shot.x < -1 * tileSize or
            shot.x > screenW + tileSize then
            table.remove(shots, key)
        end
    end

    -- Animate muzzle flash
    if muzzle >0 then
        muzzle = muzzle - 2
    end

    -- Animate the star field
    updateStarfield()
end

function addShot(x, y)
    shot = { x = x, y = y, homeX = x, homeY = y, sprite = shotTypes[shotType], shotType = shotType}
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
