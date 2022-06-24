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

        x = 60
        y = 60        
        speed = 1
        local dx = love.math.random(0, 100) / 100.0
        local dy = love.math.random(0, 100) / 100.0
        if dx == 0 then
            dx = -1
        end
        if dy == 0 then
            dy = -1
        end
        dvd = { x = love.math.random(0, screenW - tileSize), y = math.random(0, screenH - tileSize), dx = dx, dy = dy}
    end
end

-- _DRAW() in PICO-8, 30 FPS
function love.draw()
    -- scale to Pico-8 screen size
    love.graphics.push()
    love.graphics.scale(screenScale, screenScale)
    
    love.graphics.clear(pal[1])
    spr(1, x, y)

    doggieZoneDraw()

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
    -- Moving the ship
    -- DoggieZone 1 - Move in y direction too.
    -- DoggieZone 3 - Wrap around the screen.
    if love.keyboard.isDown("up") then
        y = y - speed
    end

    if love.keyboard.isDown("down") then
        y = y + speed
    end

    if love.keyboard.isDown("left") then
        x = x - speed
    end

    if love.keyboard.isDown("right") then
        x = x + speed
    end
    if x < -1 * tileSize then
        x = screenW
    elseif x > screenW then
        x = -1 * tileSize
    end

    if y < -1 * tileSize then
        y = screenH
    elseif y > screenH then
        y = -1 * tileSize
    end
    
    --x = clamp(x, 0, screenW - tileSize)
    --y = clamp(y, 0, screenH - tileSize)
    doggieZoneUpdate()

end

function doggieZoneDraw()
    -- #3 - Draw a sprite that bounces like the dvd logo screen saver 
    spr(97, dvd.x, dvd.y)
end

function doggieZoneUpdate()
    -- #3 - Draw a sprite that bounces like the dvd logo screen saver
    dvd.x, dvd.dx = bounce(dvd.x, dvd.dx, screenW - tileSize)
    dvd.y, dvd.dy = bounce(dvd.y, dvd.dy, screenH - tileSize)
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

function spr(id, x, y)
    love.graphics.setColor(white)
    love.graphics.draw(img, quads[id], x, y)
end