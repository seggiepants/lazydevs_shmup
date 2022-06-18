function love.load()

    screenW = 128
    screenH = 128
    screenScale = 4
    tileSize = 8

    success = love.window.setMode(screenW * screenScale, screenH * screenScale, {resizable=false})
    if (success) then
        font8 = love.graphics.newFont("font/Bitstream Vera Sans Mono Roman.ttf", 8, "mono", 1)
        love.graphics.setFont(font8)

        
        -- pico-8 graphics page
        img = love.graphics.newImage("img/graphics.png")

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
    end
end

function love.draw()
    -- scale to pico-8 screen size
    love.graphics.push()
    love.graphics.scale(screenScale, screenScale)
    
    love.graphics.clear(pal[3])
    love.graphics.print("HELLO WORLD", 0, 0)
    love.graphics.print("HELLO THIS IS DOG", 0, 8)
    love.graphics.print("NEVER GONNA GIVE YOU UP", 0, 16)
    love.graphics.print("OHAI", 20, 50)
    love.graphics.print({pal[9], "I'M HERE"}, 80, 100)

    love.graphics.draw(img, quads[1], 50, 70)
    love.graphics.draw(img, quads[2], 80, 90)
    love.graphics.setColor(pal[12])
    love.graphics.circle("fill", 64, 64, 30)
    love.graphics.setColor(pal[13])
    love.graphics.rectangle("fill", 20, 20, 60, 20)
    love.graphics.setColor(pal[8])

    doggieZone()

    -- restore screen size
    love.graphics.pop()
end

function doggieZone()
    -- game mockup with a ship an enemy and a bullet/projectile/shot
    local ship = 3
    local enemy = 4
    local shot = 5
    love.math.setRandomSeed(42) -- 42 = Magic Number
    --love.graphics.clear(pal[1])
    love.graphics.setColor({0, 0, 0, 0.90})
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    love.graphics.setColor(pal[8])

    for i =0, 100 do
        local x = love.math.random(0, screenW - 1)
        local y = love.math.random(0, screenH - 1)
        local clr = love.math.random(6, 8)
        love.graphics.setColor(pal[clr])
        love.graphics.rectangle("fill", x, y, 1, 1)
    end
    love.graphics.setColor(pal[8])

    for i = 0, 5 do
        local x = love.math.random(0, screenW - tileSize)
        local y = love.math.random(0, screenH / 2)
        love.graphics.draw(img, quads[enemy], x, y)
    end
    local x = (screenW - tileSize) / 2
    local y = 2 * screenH / 3
    love.graphics.draw(img, quads[ship], x, y)
    y = y - tileSize
    for i = y, y - tileSize * 5, -tileSize do
        love.graphics.draw(img, quads[shot], x, i)
    end 
end