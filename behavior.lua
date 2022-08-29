-- Behavior
function EnemyMission(enemy)
    if enemy.wait > 0 then
        enemy.wait = enemy.wait - 1
        return
    end

    if enemy.mission == "FLYIN" then
        -- Fly In

        -- Basic Easing Function
        -- x = x + (TargetX - x) / n
        local dx = (enemy.posX - enemy.x) / 7
        local dy = (enemy.posY - enemy.y) / 7

        if enemy.boss == true then
            local sign = 1
            if dx < 0 then sign = -1 else sign = 1 end
            dx = sign * math.min(1, math.abs(dx))
            if dy < 0 then sign = -1 else sign = 1 end
            dy = sign * math.min(1, math.abs(dy))
        end
        enemy.x = enemy.x + dx
        enemy.y = enemy.y + dy
        
        if math.abs(enemy.y - enemy.posY) < 0.7 then
            enemy.y = enemy.posY
            enemy.x = enemy.posX
            enemy.sx = 0
            enemy.sy = 0
            if enemy.boss == true then
                -- ZZZ uncomment when have boss intro sound
                -- love.audio.play(Sfx["BossIntro"])
                enemy.mission = "BOSS1"
                enemy.phaseBegin = T
                enemy.wait = 30
                enemy.shake = enemy.wait
            else
                enemy.mission = "PROTEC"
            end
        end
    elseif enemy.mission == "PROTEC" then
        -- Stay Put
        --[[if T % 30 == 0 then
            if math.random(3 + (#Enemies * 3)) == 1 then
                enemy.sy = 2
                enemy.mission = "ATTAC"
            end
        end
        ]]--
    elseif enemy.mission == "ATTAC" then
        -- Attack
        if enemy.enemyType == "eye" then
            enemy.sx = math.sin(T/7)
            enemy.sy = 1.7
            if enemy.x < (4 * TileSize) then
                enemy.sx = enemy.sx + 1 - (enemy.x / (TileSize * 4))
            elseif enemy.x > ScreenW - (TileSize * 4) then
                enemy.sx = enemy.sx - (enemy.x - ScreenW + (TileSize * 4))/(TileSize * 4)
            end
        elseif enemy.enemyType == "jelly" then
            enemy.sx = 3 * math.cos(T / 4)
            enemy.sy = 0.5
        elseif enemy.enemyType == "devil" then
            enemy.sx = math.sin(T/3)
            enemy.sy = 2.5
            if enemy.x < (4 * TileSize) then
                enemy.sx = enemy.sx + 1 - (enemy.x / (TileSize * 4))
            elseif enemy.x > ScreenW - (TileSize * 4) then
                enemy.sx = enemy.sx - (enemy.x - ScreenW + (TileSize * 4))/(TileSize * 4)
            end
        elseif enemy.enemyType == "spinner" then
            if enemy.sx == 0 then
                enemy.sy = 2
                if Ship.y <= enemy.y then
                    if Ship.x < enemy.x then
                        enemy.sx = -2
                    else
                        enemy.sx = 2
                    end
                    enemy.sy = 0
                end
            end
        elseif enemy.enemyType == "butterfly" then
            enemy.sx = 0
            enemy.sy = 1 + math.sin(T/4)
        elseif enemy.enemyType == "chungus" then
            enemy.sx = 0
            enemy.sy = 0.35
            if enemy.y > ScreenH - (TileSize * 6) then
                enemy.sy = 1
            else
                if T % 25 == 3 then FireSpread(enemy, 8, 1.5) end
            end
        elseif enemy.enemyType == "boss" then
            
        else
            enemy.sx = 0
            enemy.sy = 1
        end

        Move(enemy)

        -- Respawn if offscreen
        if enemy.y > ScreenH  or enemy.x + TileSize < 0 or enemy.x > ScreenW then
            enemy.x = enemy.posX
            enemy.y = -1 * (TileSize * 2)
            enemy.sy = 1
            enemy.sx = 0
            enemy.animationSpeed = enemy.animationSpeed / 3
            enemy.mission = "FLYIN"
        end
    elseif enemy.mission == "BOSS1" then
        Boss1(enemy)
    elseif enemy.mission == "BOSS2" then
        Boss2(enemy)
    elseif enemy.mission == "BOSS3" then
        Boss3(enemy)
    elseif enemy.mission == "BOSS4" then
        Boss4(enemy)
    elseif enemy.mission == "BOSS5" then
        Boss5(enemy)
    end
end

function Move(obj)
    obj.x = obj.x + obj.sx
    obj.y = obj.y + obj.sy
end

function PickAttacker()
    local idx = #Enemies - math.random(math.min(10, #Enemies)) + 1
    --print("Enemies: " .. #Enemies .. " chose: " .. idx)
    if idx > 0 and idx <= #Enemies then
        local enemy = Enemies[idx]
        if enemy == nil then return end
        if enemy.mission ~= "PROTEC" then
            return
        end
        
        enemy.sx = 0
        enemy.sy = 0
        enemy.animationSpeed =  enemy.animationSpeed * 3
        enemy.mission = "ATTAC"
        enemy.wait = 60
        enemy.shake = enemy.wait
    end
end

function PickFire()
    local down = math.pi / 2.0

    for _, enemy in pairs(Enemies) do
        if enemy.enemyType == "chungus" and enemy.mission == "PROTEC" then
            if math.random() < 0.5 then
                FireSpread(enemy, 8, 1.5)
                return
            end
        end
    end
    local idx = #Enemies - math.random(math.min(10, #Enemies)) + 1
    --print("Enemies: " .. #Enemies .. " chose: " .. idx)
    if idx > 0 and idx <= #Enemies then
        local enemy = Enemies[idx]
        if enemy == nil then return end
        if enemy.mission ~= "PROTEC" then
            return
        end
        if enemy.enemyType == "chungus" then
            FireSpread(enemy, 8, 1.5)
        elseif enemy.enemyType == "devil" then
            FireAimed(enemy, 2)
        else
            Fire(enemy)
        end
    end
end

function PickTimer()
    if Mode ~= "GAME" or #Enemies == 0 then
        return
    end

    if T % AttackFrequency == 0 then
        PickAttacker()
    end

    if T > NextFire then
        PickFire()
        NextFire = T + 20 + math.random(20)
    end

    --return enemy
end

function PickupLogic(pickup)
    if pickup.sprite == CherrySpr then
        love.audio.play(Sfx["pickup"])
        Cherries = Cherries + 1
        if Cherries >= 10 and Lives < 4 then
            Lives = Lives + 1
            Cherries = Cherries - 10
            love.audio.play(Sfx["lifeUp"])
            AddFloat("1UP!", pickup.x + pickup.width / 2, pickup.y + pickup.height / 2)
        elseif Cherries >= 10 then
            -- Bombs
            Score = Score + Cherries
            Cherries = 0
        end
        Score = Score + 1
    else
        for i, shotType in pairs(ShotTypes) do
            if shotType.sprite == pickup.sprite then
                PowerupTimeout = 300
                ShotType = i
                love.audio.play(Sfx["weaponPowerup"])
                AddFloat(ShotTypes[i].name, pickup.x + pickup.width / 2, pickup.y + pickup.height / 2)
                break
            end
        end
    end
    --
    AddShockwave(pickup.x + math.floor(pickup.width / 2), pickup.y + math.floor(pickup.height /2), 15, false)
end
