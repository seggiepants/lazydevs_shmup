-- Boss behavior

function Boss1(enemy)
    local speed = 1

    --Debug = "BOSS1"
    
    -- Movement
    if enemy.sx == 0 or (enemy.x >= (ScreenW - enemy.width - 3)) then
        enemy.sx = -1 * speed
    elseif enemy.x <= 3 then
        enemy.sx = speed
    end
    -- Shooting
    if T % 4 == 0 then 
        if T % 30 > 3 and T % 30 < 26 then
            Fire(enemy, math.rad(90), 2)
        end
    end

    -- Phase Transition
    if enemy.phaseBegin + (8 * 60) < T then
        enemy.mission = "BOSS2"
        enemy.phaseBegin = T
        enemy.sx = 0
        enemy.sy = 0
        enemy.subPhase = 1
    end
    Move(enemy)
end

function Boss2(enemy)
    --Debug = "BOSS2"
    
    -- Movement
    -- Around the screen left/down/right/up
    local speed = 1.5
    local border = 5
    if enemy.subPhase == nil then enemy.subPhase = 1 end
    if enemy.subPhase == 1 then
        enemy.sy = 0
        enemy.sx = -1 * speed
        if enemy.x <= border then
            enemy.x = border
            enemy.subPhase = 2
        end
    elseif enemy.subPhase == 2 then
        enemy.sy = speed
        enemy.sx = 0
        if enemy.y > (ScreenH - enemy.height - border) then
            enemy.y = (ScreenH - enemy.height - border)
            enemy.subPhase = 3
        end
    elseif enemy.subPhase == 3 then
        enemy.sy = 0
        enemy.sx = speed
        if enemy.x >= (ScreenW - enemy.width - border) then
            enemy.x = (ScreenW - enemy.width - border)
            enemy.subPhase = 4
        end
    else -- subPhase == 4
        enemy.sy = -1 * speed
        enemy.sx = 0
        if enemy.y <= enemy.posY then
            enemy.y = enemy.posY
            enemy.mission = "BOSS3"
            enemy.phaseBegin = T
            enemy.sx = 0
            enemy.sy = 0
        end
    end
    -- Shooting
    if T % 15 == 0 then
        FireAimed(enemy, speed)
    end

    -- Phase Transition
    -- Transitions on Sub Phase 4 Complete

    Move(enemy)
end

function Boss3(enemy)
    local speed = 0.5
    local shotSpeed = 2
    local numShots = 8

    -- Debug = "BOSS3"
    
    -- Movement
    if enemy.sx == 0 or (enemy.x >= (ScreenW - enemy.width - 3)) then
        enemy.sx = -1 * speed
    elseif enemy.x <= 3 then
        enemy.sx = speed
    end


    -- Shooting
    if T % 20 == 0 then
        enemy.shotOffset = (love.timer.getTime() * 25) % 360
        FireSpread(enemy, numShots, shotSpeed)
    end

    -- Phase Transition
    if enemy.phaseBegin + (8 * 60) < T then
        enemy.mission = "BOSS4"
        enemy.phaseBegin = T
        enemy.subPhase = 1
        enemy.sx = 0
        enemy.sy = 0
    end
    Move(enemy)
end

function Boss4(enemy)
    -- Debug = "BOSS4"
    
    -- Movement
    -- Around the screen right/down/left/up
    local speed = 1
    local speedShot = 2
    local border = 5
    if enemy.subPhase == nil then enemy.subPhase = 1 end
    if enemy.subPhase == 1 then
        enemy.sy = 0
        enemy.sx = speed
        if enemy.x >= (ScreenW - enemy.width - border) then
            enemy.x = (ScreenW - enemy.width - border)
            enemy.subPhase = 2
        end
    elseif enemy.subPhase == 2 then
        enemy.sy = speed
        enemy.sx = 0
        if enemy.y > (ScreenH - enemy.height - border) then
            enemy.y = (ScreenH - enemy.height - border)
            enemy.subPhase = 3
        end
    elseif enemy.subPhase == 3 then
        enemy.sy = 0
        enemy.sx = -1 * speed
        if enemy.x <= border then
            enemy.x = border
            enemy.subPhase = 4
        end
    else -- subPhase == 4
        enemy.sy = -1 * speed
        enemy.sx = 0
        if enemy.y <= enemy.posY then
            enemy.y = enemy.posY
            enemy.mission = "BOSS1"
            enemy.phaseBegin = T
            enemy.sx = 0
            enemy.sy = 0
        end
    end
    
    -- Shooting
    if T % 15 == 0 then
        local angle = 0
        if enemy.subPhase == 1 then
            angle = math.rad(90)
        elseif enemy.subPhase == 2 then
            angle = math.rad(180)
        elseif enemy.subPhase == 3 then
            angle = math.rad(280)
        else -- enemy.subPhase == 4
            angle = math.rad(0)
        end
        Fire(enemy, angle, speedShot)
    end
    -- Phase Transition
    -- Done at end of loop
    Move(enemy)
end

function Boss5(enemy)
    -- Debug = "BOSS5"
    
    -- Explosion
    -- Movement
    enemy.shake = 10
    enemy.flash = 10
    ScreenFlash = 4
    
    if T % 8 == 0 then
        local centerX = enemy.x + math.random(enemy.width)
        local centerY = enemy.y + math.random(enemy.height)
        AddExplosion(centerX, centerY, false)
        love.audio.play(Sfx["enemyHit"])
        Shake = 2
    end

    if enemy.phaseBegin + (3 * 60) < T then
        if T % 4 == 2 then
            local centerX = enemy.x + math.random(enemy.width)
            local centerY = enemy.y + math.random(enemy.height)
            AddExplosion(centerX, centerY, false)
            love.audio.play(Sfx["enemyHit"])
            Shake = 2
        end
    end

    -- Shooting
    -- N/A

    -- Phase Transition
    local ticks = (6 * 60) -- 4 seconds @ 60 fps
    if enemy.phaseBegin + ticks < T then
        Shake = 15
        Enemies = {}
        local centerX = enemy.x + (enemy.width / 2)
        local centerY = enemy.y + (enemy.height / 2)
        AddBigExplosion(centerX, centerY)
        local points = enemy.points
        if points == nil then
            points = 1000
        end
        Score = Score + enemy.points
        AddFloat(enemy.points, centerX, enemy.y)
    end  
end