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
        enemy.x = enemy.x + (enemy.posX - enemy.x) / 7
        enemy.y = enemy.y + (enemy.posY - enemy.y) / 7
        if math.abs(enemy.y - enemy.posY) < 0.7 then
            enemy.y = math.floor(enemy.posY)
            enemy.x = math.floor(enemy.posX)
            enemy.sx = 0
            enemy.sy = 0
            enemy.mission = "PROTEC"
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
            end
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
    end
end

function PickEnemy()
    if Mode ~= "GAME" or #Enemies == 0 then
        return
    end
    if T % AttackFrequency == 0 then
        local idx = #Enemies - math.random(math.min(10, #Enemies)) + 1
        --print("Enemies: " .. #Enemies .. " chose: " .. idx)
        if idx > 0 and idx <= #Enemies then
            local enemy = Enemies[idx]
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
    --return enemy
end