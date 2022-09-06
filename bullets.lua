function CherryBomb()
    local speed = 4
    local sprite = 12
    local start = (5 * math.pi) / 4.0
    local spacing = (math.pi / 2.0)/(Cherries * 2)
    for i = 0,Cherries * 2 do
        local angle = start + (spacing * i)
        local bullet = MakeSprite({ 
            x = Ship.x + (Ship.width / 2)
            , y = Ship.y + (Ship.height / 2)
            , sprite = sprite
            , sy = -4})
        bullet.colX = 0
        bullet.colY = 0
        bullet.colWidth = 8
        bullet.colHeight = 8
        bullet.age = 0
        bullet.maxAge = 100
        bullet.x = bullet.x - (bullet.width /  2)
        bullet.y = bullet.y - (bullet.height / 2)
        bullet.sx = math.cos(angle) * speed
        bullet.sy = math.sin(angle) * speed
        bullet.damage = 3
        table.insert(Shots, bullet)
    end
    love.audio.play(Sfx["cherryBomb"])
    AddShockwave(Ship.x + (Ship.width / 2), Ship.y + (Ship.height / 2), nil, true)
    Shake = 15
    Muzzle = 5
    Ship.invulnerable = 30
    ShowSkull = 1
    ScreenFlash = 4
end

function Fire(enemy, ang, speed)
    local shotPrototype = PrepareShot(enemy)
    local shot = MakeSprite(shotPrototype)
    shot.x = enemy.x + math.floor(enemy.width / 2) - math.floor(shot.width / 2)
    shot.y = enemy.y + math.floor(enemy.height / 2)
    if ang ~= nil and speed ~= nil then
        shot.sx = math.cos(ang) * speed
        shot.sy = math.sin(ang) * speed
    end
    
    -- shrink the collision area to a 2x2 area in the center.
    if shot.colX == nil then shot.colX = 3 end
    if shot.colY == nil then shot.colY = 3 end
    if shot.colWidth == nil then shot.colWidth = 2 end
    if shot.colHeight == nil then shot.colHeight = 2 end
    table.insert(EnemyShots, shot)

    if enemy.boss == true then
        shot.y = shot.y + (enemy.height / 2) - (shot.height / 2)
        love.audio.play(Sfx["bossShoot"])
    
    else
        enemy.flash = 8
        love.audio.play(Sfx["enemyShot"])
    end
    return shot
end

function FireAimed(enemy, speed)
    local shot = Fire(enemy, 0, speed)
    local angle = math.atan2((Ship.y + math.floor(Ship.height / 2)) - (shot.y + math.floor(shot.height / 2)), (Ship.x + math.floor(Ship.width / 2)) - (shot.x + math.floor(shot.width / 2)))
    shot.sx = math.cos(angle) * speed
    shot.sy = math.sin(angle) * speed
end

function FireSpread(enemy, numShots, speed)
    if numShots == nil then numShots = 8 end
    if enemy.shotOffset == nil then enemy.shotOffset = math.pi / 5 end
    local shotPrototype = PrepareShot(enemy)
    local step = (math.pi * 2.0) / numShots
    if speed == nil then
        if shotPrototype.sy == nil then 
            speed = 2.0 
        else 
            speed = shotPrototype.sy 
        end
    end
    for i=0, numShots - 1 do
        local theta = enemy.shotOffset + (i * step)
        Fire(enemy, theta, speed)
        --[[
        local shot = MakeSprite(shotPrototype)
        shot.x = enemy.x + math.floor(enemy.width / 2) - math.floor(shot.width / 2)
        shot.y = enemy.y + math.floor(enemy.height / 2)
        shot.sy = speed * math.sin(theta)
        shot.sx = speed * math.cos(theta)
        
        -- shrink the collision area to a 2x2 area in the center.
        if shot.colX == nil then shot.colX = 3 end
        if shot.colY == nil then shot.colY = 3 end
        if shot.colWidth == nil then shot.colWidth = 2 end
        if shot.colHeight == nil then shot.colHeight = 2 end
        table.insert(EnemyShots, shot)
        --]]
    end
    enemy.shotOffset = enemy.shotOffset + (math.pi / 5.0)
    -- back and forth - enemy.shotOffset = -1 * enemy.shotOffset
    while enemy.shotOffset >= math.pi * 2.0 do
        enemy.shotOffset = enemy.shotOffset - (math.pi * 2.0)
    end
    enemy.flash = 8
    --love.audio.play(Sfx["enemyShot"])
end

function PrepareShot(enemy)
    local shotPrototype
    if enemy.enemyType == "eye" then
        shotPrototype = {
            animationSpeed = 0.4
            , frames = {23, 24, 25, 24}
            , colX = 3
            , colY = 3
            , colWidth = 2
            , colHeight = 2
            , sy = 2
        }
    elseif enemy.enemyType == "jelly" then
        shotPrototype = {
            animationSpeed = 0.4
            , frames = {61, 62, 63, 64}
            , colX = 3
            , colY = 3
            , colWidth = 2
            , colHeight = 2
            , sy = 1.5
        }
    elseif enemy.enemyType == "devil" then
        shotPrototype = {
            animationSpeed = 0.4
            , frames = {59, 60}
            , colX = 1
            , colY = 5
            , colWidth = 3
            , colHeight = 2
            , sy = 2
            , sx = 0
        }
    elseif enemy.enemyType == "spinner" then
        shotPrototype = {
            animationSpeed = 0.4
            , frames = {65, 66}
            , colX = 0
            , colY = 0
            , colWidth = 3
            , colHeight = 4
            , sy = 2
        }
    elseif enemy.enemyType == "butterfly" then
        shotPrototype = {
            animationSpeed = 0.4
            , frames = {70, 71}
            , colX = 3
            , colY = 3
            , colWidth = 2
            , colHeight = 2
            , sy = 1.5
        }
    elseif enemy.enemyType == "chungus" then
        shotPrototype = {
            animationSpeed = 0.4
            , frames = {67, 68, 69, 68}
            , colX = 3
            , colY = 3
            , colWidth = 2
            , colHeight = 2
            , sy = 1.25
        }
    else
        shotPrototype = {
            animationSpeed = 0.4
            , frames = {23, 24, 25, 24}
            , colX = 3
            , colY = 3
            , colWidth = 2
            , colHeight = 2
            , sy = 2
        }
    end

    return shotPrototype
end