function updateGame(dt)
    ship.sx = 0
    ship.sy = 0
    ship.sprite = 2
    flameSpr = flameSpr + 1
    if flameSpr > 9 then
        flameSpr = 5
    end

    if love.keyboard.isDown("up") then
        ship.sy = -2
    end

    if love.keyboard.isDown("down") then
        ship.sy = 2
    end

    if love.keyboard.isDown("left") then
        ship.sx = -2
        ship.sprite = 1
    end

    if love.keyboard.isDown("right") then
        ship.sx = 2
        ship.sprite = 3
    end

    if love.keyboard.isDown("space") or love.keyboard.isDown("z") then
        if shootOK then
            addShot(ship.x, ship.y - (tileSize / 2))
            love.audio.play(sfx["laser"])
            muzzle = 6
            shootOK = false
        end
    else
        shootOK = true
    end

    if love.keyboard.isDown("tab") == false and 
        love.keyboard.isDown("x") == false and
        love.keyboard.isDown("space") == false and
        love.keyboard.isDown("z") == false then
        buttonReady = true
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

    if love.keyboard.isDown("q") then
        if buttonReady then
            buttonReady = false
            mode = "OVER"
        end
    end
    
    -- Moving the ship
    ship.x = ship.x + ship.sx
    ship.y = ship.y + ship.sy

    if ship.x < -1 * tileSize then
        ship.x = screenW
    elseif ship.x > screenW then
        ship.x = -1 * tileSize
    end

    if ship.y < -1 * tileSize then
        ship.y = screenH
    elseif ship.y > screenH then
        ship.y = -1 * tileSize
    end

    -- Move the bullet
    for i = #shots, 1, -1  do
        shot = shots[i]
        if shot.shotType == 4 then -- wave
            shot.x = shot.x + (math.cos(shot.time) * shot.amplitude)
            shot.time = shot.time + .75
            shot.amplitude = shot.amplitude + .75
        else
            shot.x = shot.x + shot.sx
        end
        shot.y = shot.y + shot.sy
        if shot.lifetime < 0 or 
            shot.y < -1 * tileSize or
            shot.y > screenH + tileSize or
            shot.x < -1 * tileSize or
            shot.x > screenW + tileSize then
            table.remove(shots, i)
        end
    end

    -- Move the enemies
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.time = enemy.time + dt
        enemy.y = enemy.y + enemy.sy
        enemy.x = enemy.x + enemy.sx
        enemy.sprite= enemy.sprite + 0.2
        if enemy.sprite >= enemy.spriteMax + 1 then
            enemy.sprite = enemy.spriteMin
        end
        if enemy.y > screenH then
            table.remove(enemies, i)
        end
    end

    -- Spawn new enemies
    previousTime = time
    time = time + dt
    for i, enemy in pairs(levelJson["enemies"]) do
        if enemy.time >= previousTime and enemy.time < time then
            addEnemy(enemy)
        end
    end

    -- Animate muzzle flash
    if muzzle >0 then
        muzzle = muzzle - 2
    end

    -- Animate the star field
    updateStarfield()
end

function updateGetReady(dt)
    getReadyTime = getReadyTime + dt
    if getReadyTime >= 4 then
        startGame()
    end
end

function updateStarfield()
    for key, star in ipairs(stars) do
        star.y = star.y + star.spd
        if star.y >= screenH then
            star.x = love.math.random(screenW)
            star.y = star.y - screenH - tileSize
        end
    end
end

function updateOver(dt)
    if love.keyboard.isDown("tab") == false and 
        love.keyboard.isDown("x") == false and
        love.keyboard.isDown("space") == false and
        love.keyboard.isDown("z") == false then
        buttonReady = true
    end
    if buttonReady then
        if love.keyboard.isDown("tab") or 
            love.keyboard.isDown("x") or
            love.keyboard.isDown("space") or 
            love.keyboard.isDown("z") then
            buttonReady = false
            mode = "START"
        end 
    end
end

function updateStart(dt)
    if love.keyboard.isDown("tab") == false and 
        love.keyboard.isDown("x") == false and
        love.keyboard.isDown("space") == false and
        love.keyboard.isDown("z") == false then
        buttonReady = true
    end

    if buttonReady then
        if love.keyboard.isDown("tab") or 
            love.keyboard.isDown("x") or
            love.keyboard.isDown("space") or 
            love.keyboard.isDown("z") then
            startGetReady()
        end 
    end
end

function startGame()
    ship.x = (screenW - tileSize) / 2
    ship.y = (screenH - tileSize) / 2
    ship.sx = 0
    ship.sy = 0
    ship.sprite = 2
    flameSpr = 5
    muzzle = 0
    score = 0
    lives = 3
    local starClr = {6, 7, 8, 16}
    stars = {}
    for i=1,100 do
        star = {} 
        star.x = love.math.random(screenW)
        star.y = love.math.random(screenH)
        star.spd = (love.math.random() * 1.5) + .05
        table.insert(stars, star)
    end

    shootOK = true
    switchOK = true
    shotType = 1
    shots = {}
    buttonReady = false
    mode = "GAME"
    enemies = {}
    time = 0
    previousTime = -1.0
end

function startGetReady()
    getReadyTime = 0
    mode = "GET_READY"
end