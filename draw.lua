function DrawGame()
    love.graphics.clear(Pal[1])
    DrawStarfield()

    -- Draw Shockwaves
    for key, shockwave in pairs(Shockwaves) do
        love.graphics.setColor(Pal[shockwave.clr])
        love.graphics.circle("line", shockwave.x, shockwave.y, shockwave.radius)
    end

    -- Draw Particles
    for key, particle in pairs(Particles) do
        love.graphics.setColor(Pal[particle.clr])
        if particle.isBeam then
            love.graphics.line(particle.startX, particle.startY, particle.x, particle.y)
        elseif particle.isSpark then
            Pset(particle.x, particle.y, 8)
        else
            love.graphics.circle("fill", particle.x, particle.y, particle.radius)
        end
        --Pset(particle.x, particle.y, 8) --particle.clr)
    end

    -- Draw Enemies
    for key, enemy in pairs(Enemies) do
        if enemy.flash > 0 then
            RecolorShader:send("Target", unpack(PalWhite)) 
            love.graphics.setShader(RecolorShader)
        elseif enemy.enemyType == "eye" then
            RecolorShader:send("Target", unpack(PalGreenAlien[ColorIndex])) 
            love.graphics.setShader(RecolorShader)
        end
        DrawSprite(enemy)
        if enemy.flash > 0 or enemy.enemyType == "eye" then
            love.graphics.setShader()
        end
    end        
    

    -- Draw Bullets
    for key, shot in ipairs(Shots) do
        if shot.ShotType == 2 then --laser
            local y = shot.y
            while y > -1 * TileSize do
                Spr(shot.sprite, shot.x, y)
                y = y - TileSize
            end
        else
            DrawSprite(shot)

            -- Uncomment for a debug collision rectangle
            -- love.graphics.setColor(0, 1, 0, 1)
            -- love.graphics.rectangle("line", shot.x + shot.colX - 1, shot.y + shot.colY - 1, shot.colWidth, shot.colHeight)
    
        end
    end

    if Ship.dead == false then
        if Ship.invulnerable <= 0 then
            DrawSprite(Ship)
            --spr(ship.sprite, ship.x, ship.y)
            Spr(FlameSpr, Ship.x, Ship.y + TileSize)
        else
            if T % 6 >= 3 then
                if T % 2 == 1 then
                    RecolorShader:send("Target", unpack(PalWhite)) 
                    love.graphics.setShader(RecolorShader)
                end
                DrawSprite(Ship)
                if T % 2 == 1 then
                    love.graphics.setShader()
                end
                --spr(ship.sprite, ship.x, ship.y)
                Spr(FlameSpr, Ship.x, Ship.y + TileSize)
            end
        end
        if Muzzle > 0 then
            love.graphics.setColor(Pal[7])
            love.graphics.circle("fill", Ship.x + 3, Ship.y - 2, Muzzle)
            love.graphics.circle("fill", Ship.x + 4, Ship.y - 2, Muzzle)
        end
    end
    love.graphics.setColor(Pal[12])
    love.graphics.print("Score: " .. Score, 40, 1)
    -- Lives
    for i=1,4 do
        if Lives >= i then
            Spr(13, i * 9 - 8, 1)
        else
            Spr(14, i * 9 - 8, 1)
        end
    end
end

function DrawGetReady()
    local clr = 9
    local countDown = "3"
    love.graphics.clear(Pal[4])
    for x = 0, ScreenW, TileSize do
        Spr(104, x, 0)
        Spr(104, x, ScreenH - TileSize)
    end
    for y = TileSize, ScreenH - TileSize, TileSize do
        Spr(104, 0, y)
        Spr(104, ScreenW - TileSize, y)
    end

    CenterPrint("GET READY", 40, 13)
    if GetReadyTime < 1.0 then
        clr = 9
        countDown = "3"
    elseif GetReadyTime < 2.0 then
        clr = 10
        countDown = "2"
    elseif GetReadyTime < 3.0 then
        clr = 12
        countDown = "1"
    else
        clr = 16
        countDown = "GO!"
    end
    CenterPrint(countDown, 60, clr)
end

function DrawSprite(sprite)
    Spr(math.floor(sprite.sprite), sprite.x, sprite.y)
end

function DrawStarfield()
    for key, star in ipairs(Stars) do
        local clr = 8

        if star.spd < 1 then
            clr = 2
        elseif star.spd < 1.25 then
            clr = 14
        elseif star.spd < 1.5 then
            clr = 7
        end
        
        if star.spd < 1.5 then
            Pset(star.x, star.y, clr)
        else
            Line(star.x, star.y - 3, star.x, star.y, 6)
            Line(star.x, star.y - 1, star.x, star.y, clr)
        end
    end
end

function DrawOver()
    DrawGame()
    love.graphics.setColor({0.0, 0.0, 0.0, 0.5})
    love.graphics.rectangle("fill", 0, 0, ScreenW, ScreenH)
    Spr(108, 10, 10)
    Spr(108, ScreenW - TileSize - 10, 10)
    Spr(108, 10, ScreenH - TileSize - 10)
    Spr(108, ScreenW - TileSize - 10, ScreenH - TileSize - 10)
    
    CenterPrint("GAME OVER", 40, 9)
    CenterPrint("Press any key to continue", 80, Blink())
end

function DrawStart()
    love.graphics.clear(Pal[2])
    local x = ScreenW / 2
    local y = ScreenH / 2
    love.graphics.setColor(Pal[3])
    MaxRadius = math.sqrt((ScreenW/2)^2 + (ScreenH/2)^2)
    for radius = 10, MaxRadius, 10 do
        love.graphics.circle("line", x, y, radius)
    end
    local radius = math.max(ScreenW / 2, ScreenH / 2)
    local offset = (love.timer.getTime() * 25) % 360
    for angle = 0, 360, 15 do
        Line(x, y, x + (MaxRadius * math.cos(math.rad(angle + offset))), y + (MaxRadius * math.sin(math.rad(angle + offset))), 3)
    end
    
    Spr(106, 10, 10)
    Spr(107, ScreenW - TileSize - 10, 10)
    Spr(106, 10, ScreenH - TileSize - 10)
    Spr(107, ScreenW - TileSize - 10, ScreenH - TileSize - 10)
    
    if (T % 8 < 4) then
        Spr(41, 48, 56) -- Red Bat
        Spr(58, 56, 56) -- Big Guy
    else
        Spr(42, 48, 56) -- Red Bat
        Spr(59, 56, 56) -- Big Guy
    end
    -- Spinner
    Spr(25 + math.floor((T % 16)/4), 72, 56)
    
    CenterPrint("My Awesome Shmup", 40, 13)
    CenterPrint("Press any key to start", 80, Blink())
end

function DrawWaveText()
    DrawGame()
    --CenterPrint("Wave " .. Wave, 60, Blink())
    CenterPrint(LevelJson["waves"][Wave]["name"], 60, Blink())
end

function DrawWin()
    DrawGame()
    love.graphics.setColor({0.0, 0.0, 0.0, 0.5})
    love.graphics.rectangle("fill", 0, 0, ScreenW, ScreenH)

    Spr(106, 10, 10)
    Spr(107, ScreenW - TileSize - 10, 10)
    Spr(106, 10, ScreenH - TileSize - 10)
    Spr(107, ScreenW - TileSize - 10, ScreenH - TileSize - 10)
    
    CenterPrint("CONGRATULATIONS!", 40, 13)
    CenterPrint("YOU WIN", 56, 13)
    CenterPrint("Press any key to continue", 80, Blink())
end

function Line(x1, y1, x2, y2, clr)
    love.graphics.setColor(Pal[clr])
    love.graphics.line(x1, y1, x2, y2)
end

function CenterPrint(message, y, clr)
    love.graphics.setColor(Pal[clr])
    local x = (ScreenW - Font8:getWidth(message)) / 2
    love.graphics.print(message, x, y)
end

function Pset(x, y, clr)
    -- love.graphics.points doesn't scale up properly so I am drawing rectangles.
    love.graphics.setColor(Pal[clr])
    love.graphics.rectangle("fill", x, y, 1, 1)
end

function Spr(id, x, y)
    love.graphics.setColor(White)
    love.graphics.draw(Img, Quads[id], x, y)
end