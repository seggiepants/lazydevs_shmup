function UpdateGame(dt)
    Ship.sx = 0
    Ship.sy = 0
    Ship.sprite = 2
    FlameSpr = FlameSpr + 1
    if FlameSpr > 9 then
        FlameSpr = 5
    end

    if love.keyboard.isDown("up") then
        Ship.sy = -2
    end

    if love.keyboard.isDown("down") then
        Ship.sy = 2
    end

    if love.keyboard.isDown("left") then
        Ship.sx = -2
        Ship.sprite = 1
    end

    if love.keyboard.isDown("right") then
        Ship.sx = 2
        Ship.sprite = 3
    end

    if Ship.shotTimeout > 0 then
        Ship.shotTimeout = Ship.shotTimeout - 1
    else
        ShootOK = true
    end
    
    if love.keyboard.isDown("space") or love.keyboard.isDown("z") then
        if ShootOK then
            AddShot(Ship.x, Ship.y - (TileSize / 2))
            love.audio.play(Sfx["laser"])
            Muzzle = 6
            ShootOK = false
            Ship.shotTimeout = ShotTimeoutMax
        end
    else
        ShootOK = true
    end

    if love.keyboard.isDown("tab") == false and 
        love.keyboard.isDown("x") == false and
        love.keyboard.isDown("space") == false and
        love.keyboard.isDown("z") == false then
        ButtonReady = true
    end

    if love.keyboard.isDown("tab") or love.keyboard.isDown("x") then
        if SwitchOK then
            ShotType = ShotType + 1
            if ShotType > 4 then
                ShotType = 1
            end
            SwitchOK = false
        end
    else
        SwitchOK = true
    end
    
    -- Moving the ship
    Ship.x = Ship.x + Ship.sx
    Ship.y = Ship.y + Ship.sy

    if Ship.x < 0 then
        Ship.x = 0
    elseif Ship.x >= ScreenW - TileSize then
        Ship.x = ScreenW - TileSize
    end

    if Ship.y < 0 then
        Ship.y = 0
    elseif Ship.y > ScreenH - TileSize then
        Ship.y = ScreenH - TileSize
    end

    -- Move particles
    for i = #Particles, 1, -1 do
        local particle = Particles[i]
        particle.x = particle.x + particle.sx
        particle.y = particle.y + particle.sy
        particle.lifeTime = particle.lifeTime - 1
        if particle.lifeTime <= 0 then
            table.remove(Particles, i)
        end
    end

    -- Move the bullet
    for i = #Shots, 1, -1  do
        local shot = Shots[i]
        if shot.ShotType == 4 then -- wave
            shot.x = shot.x + (math.cos(shot.time) * shot.amplitude)
            shot.time = shot.time + .75
            shot.amplitude = shot.amplitude + .75
        else
            shot.x = shot.x + shot.sx
        end
        shot.y = shot.y + shot.sy
        if shot.lifetime < 0 or 
            shot.y < -1 * TileSize or
            shot.y > ScreenH + TileSize or
            shot.x < -1 * TileSize or
            shot.x > ScreenW + TileSize then
            table.remove(Shots, i)
        end
    end

    -- Move the enemies
    for i = #Enemies, 1, -1 do
        local enemy = Enemies[i]
        enemy.time = enemy.time + dt
        enemy.y = enemy.y + enemy.sy
        enemy.x = enemy.x + enemy.sx
        enemy.sprite= enemy.sprite + 0.2
        if enemy.sprite >= enemy.spriteMax + 1 then
            enemy.sprite = enemy.spriteMin
        end
        if enemy.y > ScreenH then
            table.remove(Enemies, i)
        end
        if enemy.blink > 0 then
            enemy.blink = enemy.blink - 1
        end
    end

    -- Spawn new enemies
    PreviousTime = Time
    Time = Time + dt
    for i, enemy in pairs(LevelJson["enemies"]) do
        if enemy.time >= PreviousTime and enemy.time < Time then
            AddEnemy(enemy)
        end
    end

    -- Collision Enemies x Shots
    for i = #Enemies, 1, -1 do
        local enemy = Enemies[i]
        for j = #Shots, 1, -1 do
            if Collide(enemy, Shots[j]) then
                love.audio.play(Sfx["enemyHit"])
                enemy.blink = BlinkTimeoutMax
                table.remove(Shots, j)
                enemy.hp = enemy.hp - 1
                if enemy.hp <= 0 then
                    local x, y, w, h = Quads[math.floor(enemy.sprite)]:getViewport()
                    AddExplosion(enemy.x + (w / 2), enemy.y + (h / 2))
                    table.remove(Enemies, i)
                    Score = Score + 1
                end
            end     
        end
    end

    -- Collision Ship x Enemies
    if Ship.invulnerable > 0 then
        Ship.invulnerable = Ship.invulnerable - 1
    else
        for i = #Enemies, 1, -1 do
            if Collide(Ship, Enemies[i]) then
                Lives = Lives - 1
                Ship.invulnerable = InvulnerableMax
                love.audio.play(Sfx["hurt"])
                table.remove(Enemies, i)
            end
        end
    end

    -- Animate Muzzle flash
    if Muzzle >0 then
        Muzzle = Muzzle - 2
    end

    -- Animate the star field
    UpdateStarfield()

    if Lives <= 0 then
        Mode = "OVER"
    end
end

function UpdateGetReady(dt)
    GetReadyTime = GetReadyTime + dt
    if GetReadyTime >= 4 then
        StartGame()
    end
end

function UpdateStarfield()
    for key, star in ipairs(Stars) do
        star.y = star.y + star.spd
        if star.y >= ScreenH then
            star.x = love.math.random(ScreenW)
            star.y = star.y - ScreenH - TileSize
        end
    end
end

function UpdateOver(dt)
    if love.keyboard.isDown("tab") == false and 
        love.keyboard.isDown("x") == false and
        love.keyboard.isDown("space") == false and
        love.keyboard.isDown("z") == false then
        ButtonReady = true
    end
    if ButtonReady then
        if love.keyboard.isDown("tab") or 
            love.keyboard.isDown("x") or
            love.keyboard.isDown("space") or 
            love.keyboard.isDown("z") then
            ButtonReady = false
            Mode = "START"
        end 
    end
end

function UpdateStart(dt)
    if love.keyboard.isDown("tab") == false and 
        love.keyboard.isDown("x") == false and
        love.keyboard.isDown("space") == false and
        love.keyboard.isDown("z") == false then
        ButtonReady = true
    end

    if ButtonReady then
        if love.keyboard.isDown("tab") or 
            love.keyboard.isDown("x") or
            love.keyboard.isDown("space") or 
            love.keyboard.isDown("z") then
            StartGame() -- was get ready
        end 
    end
end

function StartGame()
    T = 0
    Ship.x = (ScreenW - TileSize) / 2
    Ship.y = (ScreenH - TileSize) / 2
    Ship.sx = 0
    Ship.sy = 0
    Ship.sprite = 2
    Ship.invulnerable = 0
    Ship.shotTimeout = 0
    FlameSpr = 5
    Muzzle = 0
    Score = 0
    Lives = 3
    local starClr = {6, 7, 8, 16}
    Stars = {}
    for i=1,100 do
        local star = {} 
        star.x = love.math.random(ScreenW)
        star.y = love.math.random(ScreenH)
        star.spd = (love.math.random() * 1.5) + .05
        table.insert(Stars, star)
    end

    ShootOK = true
    SwitchOK = true
    ShotType = 1
    Shots = {}
    ButtonReady = false
    Mode = "GAME"
    Enemies = {}
    Time = 0
    PreviousTime = -1.0
end

function StartGetReady()
    GetReadyTime = 0
    Mode = "GET_READY"
end