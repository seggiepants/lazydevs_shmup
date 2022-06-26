function drawGame()
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
end

function drawGetReady()
    local clr = 9
    local countDown = 3
    love.graphics.clear(pal[4])
    for x = 0, screenW, tileSize do
        spr(104, x, 0)
        spr(104, x, screenH - tileSize)
    end
    for y = tileSize, screenH - tileSize, tileSize do
        spr(104, 0, y)
        spr(104, screenW - tileSize, y)
    end

    centerPrint("GET READY", 40, 13)
    if getReadyTime < 1.0 then
        clr = 9
        countDown = 3
    elseif getReadyTime < 2.0 then
        clr = 10
        countDown = 2
    elseif getReadyTime < 3.0 then
        clr = 12
        countDown = 1
    else
        clr = 16
        countDown = "GO!"
    end
    centerPrint(countDown, 60, clr)
end

function drawStarfield()
    for key, star in ipairs(stars) do
        local clr = 8

        if star.spd < 1 then
            clr = 2
        elseif star.spd < 1.25 then
            clr = 14
        elseif star.spd < 1.5 then
            clr = 7
        end
        
        if star.spd < 1.5 then
            pset(star.x, star.y, clr)
        else
            line(star.x, star.y - 3, star.x, star.y, 6)
            line(star.x, star.y - 1, star.x, star.y, clr)
        end
    end
end

function drawOver()
    love.graphics.clear(pal[9])
    love.graphics.setColor(pal[3])
    for y=0,screenH,tileSize do
        for x = 0,screenW,tileSize do
            if ((x/tileSize) + (y/tileSize)) % 2 == 1 then
                love.graphics.rectangle("fill", x, y, tileSize, tileSize)
            end
        end
    end
    spr(108, 10, 10)
    spr(108, screenW - tileSize - 10, 10)
    spr(108, 10, screenH - tileSize - 10)
    spr(108, screenW - tileSize - 10, screenH - tileSize - 10)
    
    centerPrint("GAME OVER", 40, 8)
    centerPrint("Press any key to continue", 80, blink())
end

function drawStart()
    love.graphics.clear(pal[2])
    local x = screenW / 2
    local y = screenH / 2
    love.graphics.setColor(pal[3])
    maxRadius = math.sqrt((screenW/2)^2 + (screenH/2)^2)
    for radius = 10, maxRadius, 10 do
        love.graphics.circle("line", x, y, radius)
    end
    radius = math.max(screenW / 2, screenH / 2)
    offset = (love.timer.getTime() * 25) % 360
    for angle = 0, 360, 15 do
        line(x, y, x + (maxRadius * math.cos(math.rad(angle + offset))), y + (maxRadius * math.sin(math.rad(angle + offset))), 3)
    end
    
    spr(106, 10, 10)
    spr(107, screenW - tileSize - 10, 10)
    spr(106, 10, screenH - tileSize - 10)
    spr(107, screenW - tileSize - 10, screenH - tileSize - 10)
    
    centerPrint("My Awesome Shmup", 40, 13)
    centerPrint("Press any key to start", 80, blink())
end

function line(x1, y1, x2, y2, clr)
    love.graphics.setColor(pal[clr])
    love.graphics.line(x1, y1, x2, y2)
end

function centerPrint(message, y, clr)
    love.graphics.setColor(pal[clr])
    x = (screenW - font8:getWidth(message)) / 2
    love.graphics.print(message, x, y)
end

function pset(x, y, clr)
    -- love.graphics.points doesn't scale up properly so I am drawing rectangles.
    love.graphics.setColor(pal[clr])
    love.graphics.rectangle("fill", x, y, 1, 1)
end

function spr(id, x, y)
    love.graphics.setColor(white)
    love.graphics.draw(img, quads[id], x, y)
end