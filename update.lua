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
    
    if Ship.dead == false then
        if love.keyboard.isDown("space") or love.keyboard.isDown("z") then
            if ShootOK then
                AddShot(Ship.x, Ship.y - (TileSize / 2))
                love.audio.play(Sfx["laser"])
                Muzzle = 5
                ShootOK = false
                Ship.shotTimeout = ShotTimeoutMax
            end
        else
            ShootOK = true
        end
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
    if Ship.dead == false then
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
    else
        Ship.deadTime = Ship.deadTime + 1
    end

    -- Animate Shockwaves
    for i = #Shockwaves, 1, -1 do
        local shockwave = Shockwaves[i]
        if shockwave.radius >= shockwave.targetRadius then
            table.remove(Shockwaves, i)
        else
            shockwave.radius = shockwave.radius + shockwave.speed
        end
    end

    -- Move particles
    for i = #Particles, 1, -1 do
        local particle = Particles[i]

        particle.x = particle.x + particle.sx
        particle.y = particle.y + particle.sy

        if particle.isBeam and particle.age > 10 then
            particle.isBeam = nil
        end

        if particle.isExplosion then
            particle.sx = particle.sx * 0.9
            particle.sy = particle.sy * 0.9
            if particle.isBlue == nil or particle.isBlue == false then
                particle.clr = GetParticleColorRed(particle.age) 
            else
                particle.clr = GetParticleColorBlue(particle.age)
            end
        end

        particle.age = particle.age + 1
        if particle.age >= particle.maxAge then
            particle.radius = particle.radius - 0.5
            if particle.radius <= 0  or particle.isExplosion == nil then
                table.remove(Particles, i)
            end
        end
    end

    -- Remove "dead" shots
    for i = #Shots, 1, -1  do
        if Shots[i].dead == true then
            table.remove(Shots, i)
        end
    end
    
    -- Move the bullet
    for i, shot in pairs(Shots)  do
        if shot.ShotType == 4 then -- wave
            shot.x = shot.x + (math.cos(shot.time) * shot.amplitude)
            shot.time = shot.time + .75
            shot.amplitude = shot.amplitude + .75
        else
            shot.x = shot.x + shot.sx
        end
        shot.y = shot.y + shot.sy
        if shot.age >= shot.maxAge or 
            shot.y < -1 * TileSize or
            shot.y > ScreenH + TileSize or
            shot.x < -1 * TileSize or
            shot.x > ScreenW + TileSize then
            shot.dead = true
        end
        shot.age = shot.age + 1
    end

    -- Move the enemies
    for i = #Enemies, 1, -1 do
        local enemy = Enemies[i]
        enemy.time = enemy.time + dt

        -- Enemy Mission
        --enemy.y = enemy.y + enemy.sy
        --enemy.x = enemy.x + enemy.sx
        EnemyMission(enemy)
        
        -- Enemy Animation
        enemy.spriteIndex= enemy.spriteIndex + 0.2
        if math.floor(enemy.spriteIndex) > #enemy.frames then
            enemy.sprite = enemy.frames[1]
            enemy.spriteIndex = 1
        else
            enemy.sprite = enemy.frames[math.floor(enemy.spriteIndex)]
        end

        -- Clip enemy to screen
        if enemy.y > ScreenH then
            table.remove(Enemies, i)
        end

        if enemy.flash > 0 then
            enemy.flash = enemy.flash - 1
        end
    end
    
    -- Check for Next Wave
    if Mode == "GAME" then
        if #Enemies == 0 then 
            NextWave()
        end
    end

    -- Collision Enemies x Shots
    local halfTile = (TileSize / 2)
    for i = #Enemies, 1, -1 do
        local enemy = Enemies[i]
        for j, shot in pairs(Shots) do
            if shot.dead ~= true then
                if Collide(enemy, Shots[j]) then
                    local shot = Shots[j]
                    --AddShotSpray(shot.x + halfTile, shot.y + halfTile)
                    shot.dead = true
                    AddShockwave(shot.x + halfTile, shot.y + halfTile, false)
                    AddSpark(enemy.x + halfTile, enemy.y + halfTile)
                    enemy.hp = enemy.hp - 1
                    enemy.flash = FlashTimeoutMax
                    if enemy.hp <= 0 then
                        love.audio.play(Sfx["enemyHit"])
                        local x, y, w, h = Quads[math.floor(enemy.sprite)]:getViewport()
                        AddExplosion(enemy.x + (w / 2), enemy.y + (h / 2), false)
                        table.remove(Enemies, i)
                        Score = Score + 1
                    else
                        love.audio.play(Sfx["enemyShieldHit"])
                    end
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
                AddExplosion(Ship.x + (TileSize / 2), Ship.y + (TileSize / 2), true)
                if Lives <= 0 and Ship.dead == false then
                    Ship.dead = true
                    Ship.deadTime = 0
                end
            end
        end
    end

    -- Animate Muzzle flash
    if Muzzle >0 then
        Muzzle = Muzzle - 2
    end

    -- Animate the star field
    UpdateStarfield()

    if Lives <= 0 and Ship.deadTime >= Ship.maxDeadTime then
        StartGameOver()
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
    if T < Lockout then
        return
    end
    
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
            StartTitle()
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

function UpdateWaveText(dt)
    UpdateGame(dt)
    WaveTime = WaveTime - 1
    if WaveTime <= 0 then
        Mode = "GAME"
        local bgm = Music["game"]
        bgm:setLooping(true)
        bgm:play()
        AddEnemies()
    end
end

function UpdateWin(dt)
    if T < Lockout then
        return
    end
    
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
            StartTitle()
        end 
    end
end

function StartGame()
    T = 0
    Enemies = {}
    Shots = {}
    Stars = {}
    Wave = 0
    NextWave()
    Ship = MakeSprite(ShipPrototype)
    Ship.x = (ScreenW - TileSize) / 2
    Ship.y = (ScreenH - TileSize) / 2
    Ship.sx = 0
    Ship.sy = 0
    Ship.spriteIndex = 2
    Ship.sprite = Ship.frames[Ship.spriteIndex]
    Ship.invulnerable = 0
    Ship.shotTimeout = 0
    Ship.deadTime = 0
    Ship.maxDeadTime = 45
    FlameSpr = 5
    Muzzle = 0
    Score = 0
    Lives = 3
    local starClr = {6, 7, 8, 16}
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
    ButtonReady = false    
end

function StartGameOver()
    ButtonReady = false
    Mode = "OVER"
    Lockout = T + 30
    love.audio.stop()
    local bgm = Music["over"]
    bgm:setLooping(false)
    bgm:play()
end

function StartGetReady()
    GetReadyTime = 0
    Mode = "GET_READY"
end

function StartTitle()
    ButtonReady = false
    Mode = "START"
    love.audio.stop()
    local bgm = Music["start"]
    bgm:setLooping(false)
    bgm:play()
end

function StartWin()
    ButtonReady = false
    Mode = "WIN"
    Lockout = T + 30
    love.audio.stop()
    local bgm = Music["win"]
    bgm:setLooping(false)
    bgm:play()
end