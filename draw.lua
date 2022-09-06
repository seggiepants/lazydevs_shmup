function DrawGame()
    if ScreenFlash > 0 then
        ScreenFlash = ScreenFlash - 1
        love.graphics.clear(Pal[3])
    else
        love.graphics.clear(Pal[1])
    end
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

    -- Draw Pickups
    for _, pickup in pairs(Pickups) do
        local pal
        if T % 16 < 8 then pal = PalWhite else pal = PalPink end
        DrawOutline(pickup, pal)
        DrawSprite(pickup)
    end

    -- Draw Enemies
    for key, enemy in pairs(Enemies) do
        local shaderOn = false
        if enemy.flash > 0 then
            if enemy.boss == true then
                enemy.sprite = 72
                if T % 8 < 4 then
                    RecolorShader:send("Target", unpack(PalBoss))
                    shaderOn = true
                end
            else
                RecolorShader:send("Target", unpack(PalWhite))
                shaderOn = true 
            end
            if shaderOn == true then
                love.graphics.setShader(RecolorShader)
            end
        end
        DrawSprite(enemy)
        if shaderOn then
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

    -- Draw Enemy Bullets
    for key, shot in ipairs(EnemyShots) do
        DrawSprite(shot)
        -- debug -- love.graphics.setColor(0, 1, 0)
        -- debug -- love.graphics.rectangle("line", shot.x + shot.colX - 1, shot.y + shot.colY - 1, shot.colWidth, shot.colHeight)
        -- debug -- love.graphics.setColor(1, 1, 1)
    end

    if ShowSkull > 0 then
        local skullSpr = 76
        if T % 8 < 4 then skullSpr = 77 end
        local scale = 1.0 + ((ShowSkull - 1) / 20.0)
        local skullX, skullY, skullW, skullH = Quads[skullSpr]:getViewport()
        skullX = ((ScreenW / scale) - skullW) / 2
        skullY = ((ScreenH / scale) - skullH) / 2
        love.graphics.setShader(TransparentShader)
        love.graphics.push()
        love.graphics.scale(scale, scale)
        Spr(skullSpr, skullX, skullY)
        love.graphics.pop()
        love.graphics.setShader()
        ShowSkull = ShowSkull + 1
        if ShowSkull > 40 then
            ShowSkull = 0
        end
    end

    -- Draw Floats
    for _, float in pairs(Floats) do
        local clr = 8
        if T % 4 < 2 then
            clr = 9
        end
        PointPrint(float.text, float.x, float.y, clr)
    end
    
    love.graphics.setColor(Pal[12])
    love.graphics.print("Score: " .. Score, 40, 1)
    -- Lives
    for i=1,4 do
        if Lives >= i then
            Spr(9, i * 9 - 8, 1)
        else
            Spr(10, i * 9 - 8, 1)
        end
    end
    Spr(42, (ScreenW - (TileSize * 3)), 2)
    love.graphics.setColor(Pal[15])
    love.graphics.print(tostring(Cherries), ScreenW - (TileSize * 1.5), 1)

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

function DrawOutline(obj, pal)
    RecolorShader:send("Target", unpack(pal)) 
    love.graphics.setShader(RecolorShader)
    Spr(obj.sprite, obj.x + 1, obj.y)
    Spr(obj.sprite, obj.x - 1, obj.y)
    Spr(obj.sprite, obj.x, obj.y + 1)
    Spr(obj.sprite, obj.x, obj.y - 1)
    love.graphics.setShader()
end

function DrawSprite(sprite)
    local x = sprite.x
    local y = sprite.y
    if sprite.shake  > 0 then
        sprite.shake = sprite.shake - 1
        if T % 4 < 2 then
            x = x + 1
        end
    end
    --[[ local ghostMode = (sprite.ghost == true)
    if ghostMode then
        love.graphics.setShader(TransparentShader)
    end ]]
    Spr(math.floor(sprite.sprite), x, y)
    --[[ if ghostMode then
        love.graphics.setShader()
    end ]]
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
    Spr(58, 10, 10)
    Spr(58, ScreenW - TileSize - 10, 10)
    Spr(58, 10, ScreenH - TileSize - 10)
    Spr(58, ScreenW - TileSize - 10, ScreenH - TileSize - 10)
    
    CenterPrint("GAME OVER", 40, 9)
    CenterPrint("Score: " .. Score, 56, 13)
    if Score > HighScore then
        local clr = 8
        if T % 8 < 4 then
            clr = 10
        end
        CenterPrint("New High Score!", 64, clr)
    end
    CenterPrint("Press any key to continue", 80, Blink())
end

function DrawStart()
    local titleSpr = 78
    local peekerSpr = 13

    love.graphics.clear(Pal[1])
    DrawStarfield()
    
    local x, y, w, h = Quads[titleSpr]:getViewport()
    x = (ScreenW - w) / 2
    y = TileSize * 3
    local delta = math.sin(love.timer.getTime() * 4)
    Spr(peekerSpr, PeekerX, y + delta * (TileSize / 2))
    if delta > 0.75 then
        PeekerX = x + (TileSize * 2) + math.random(w - (TileSize * 3))
    end
    Spr(titleSpr, x, y)
    love.graphics.setColor(Pal[4])
    love.graphics.print("My", x + TileSize / 2, y - TileSize)
    --CenterPrint("My Awesome Shmup", 40, 13)

    if HighScore > 0 then
        CenterPrint("High Score: ", 56, 13)
        CenterPrint(HighScore, 64, 13)
    end
    CenterPrint("Press any key to start", 80, Blink())

    x = TileSize
    y = 90
    love.graphics.setColor(Pal[2][1], Pal[2][2], Pal[2][3], 0.5)
    love.graphics.rectangle("fill",x, y, ScreenW - (x * 2), ScreenH - y - TileSize)
    
    love.graphics.setColor(Pal[14])
    
    local message = "Z or Space to Shoot"
    love.graphics.print(message, x, y)
    y = y + Font8:getHeight(message) + 1

    local message = "X or Tab for Bomb"
    love.graphics.print(message, x, y)
    y = y + Font8:getHeight(message) + 1

    local message = "Escape to Exit"
    love.graphics.print(message, x, y)
    y = y + Font8:getHeight(message) + 1
    
    
    love.graphics.setColor(Pal[2])
    x = ScreenW - Font8:getWidth(Version)
    y = ScreenH - Font8:getHeight(Version) 
    love.graphics.print(Version, x, y)
end

function DrawWaveText()
    DrawGame()
    --CenterPrint("Wave " .. Wave, 60, Blink())    
    local name = "Wave " .. Wave .. " of " .. #LevelJson["waves"]
    if Wave == #LevelJson["waves"] then
        name = "Final Wave!"
    end
    local description = LevelJson["waves"][Wave]["name"]
    local textHeight = 8
    local y = math.floor((ScreenH - textHeight) / 2)
    if description ~= nil then y =  math.floor((ScreenH - (textHeight * 3)) / 2) end
    CenterPrint(name, y, Blink())
    if description ~= nil then CenterPrint(description, y + (textHeight * 2), Blink()) end
end

function DrawWin()
    DrawGame()
    love.graphics.setColor({0.0, 0.0, 0.0, 0.5})
    love.graphics.rectangle("fill", 0, 0, ScreenW, ScreenH)

    Spr(56, 10, 10)
    Spr(57, ScreenW - TileSize - 10, 10)
    Spr(56, 10, ScreenH - TileSize - 10)
    Spr(57, ScreenW - TileSize - 10, ScreenH - TileSize - 10)
    
    CenterPrint("CONGRATULATIONS!", 32, 13)
    CenterPrint("YOU WIN", 40, 13)
    CenterPrint("Score: " .. Score, 56, 13)
    if Score > HighScore then
        local clr = 8
        if T % 8 < 4 then
            clr = 10
        end
        CenterPrint("New High Score!", 64, clr)
    end
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

function PointPrint(message, x, y, clr)
    love.graphics.setColor(Pal[clr])
    local posX = x - (Font8:getWidth(message) / 2)
    local posY = y - (Font8:getHeight(message) / 2)
    love.graphics.print(message, posX, posY)
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