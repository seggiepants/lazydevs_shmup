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

        Harry = 40
        Mimi = 120
        x = 64
        y = 64
        x1 = love.math.random(0, screenW)
        y1 = love.math.random(0, screenH)
        dx1 = love.math.random(-1, 1)
        dy1 = love.math.random(-1, 1)
        x2 = love.math.random(0, screenW)
        y2 = love.math.random(0, screenH)
        dx2 = love.math.random(-1, 1)
        dy2 = love.math.random(-1, 1)
        
    end
end

-- _DRAW() in Pico-8
-- 30 FPS in Pico-8
function love.draw()
    -- scale to Pico-8 screen size
    love.graphics.push()
    love.graphics.scale(screenScale, screenScale)
    
    love.graphics.clear(pal[1])
    love.graphics.setColor(pal[(Mimi % #pal) + 1])
    love.graphics.print(Harry, Mimi, 10)
    
    love.graphics.circle("line", 64, 64, Mimi)
    love.graphics.setColor(white)
    love.graphics.draw(img, quads[1], Harry, Harry)

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

--- _UPDATE in Pico-8
-- Hard 30 FPS in Pico-8
function love.update(dt)
    Harry = Harry + 2
    Mimi = Mimi - 1
    doggieZoneUpdate()

end

function doggieZoneDraw()
    love.graphics.setColor(pal[4])
    love.graphics.line(x1, y1, x2, y2)
    love.graphics.setColor(white)
    love.graphics.draw(img, quads[193], x, y)
end
function doggieZoneUpdate()
    -- make some variables and do something interesting with them.
    x = x + love.math.random(-1, 1)
    y = y + love.math.random(-1, 1)
    x1, dx1 = bounce(x1, dx1, screenW)
    y1, dy1 = bounce(y1, dy1, screenH)
    x2, dx2 = bounce(x2, dx2, screenW)
    y2, dy2 = bounce(y2, dy2, screenH)  
    if Harry > 128 then
        Harry = 0
    end

    if Mimi < 0 then
        Mimi = 128
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