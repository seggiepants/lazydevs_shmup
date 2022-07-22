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
        if enemy.enemyType == "jelly" then
            enemy.x = enemy.x + 3 * math.cos(T / 4)
        else
            enemy.x = enemy.x + enemy.sx
        end

        enemy.y = enemy.y + enemy.sy
        if enemy.enemyType == "butterfly" then
            enemy.y = enemy.y + math.sin(T / 4)
        end

        if enemy.enemyType == "spinner" then
            enemy.sy = enemy.sy + 0.1
        end

        -- Respawn if offscreen
        if enemy.y > ScreenH  or enemy.x + TileSize < 0 or enemy.x > ScreenW then
            enemy.x = enemy.posX
            enemy.y = -1 * (TileSize * 2)
            enemy.sy = 1
            enemy.sx = 0
            enemy.mission = "FLYIN"
        end
    end
end

function PickEnemy()
    if Mode ~= "GAME" or #Enemies == 0 then
        return
    end
    if T % 60 == 0 then
        -- Get lowest Y position
        local minY = -5 * ScreenH
        local maxY = -5 * ScreenH
        for _, candidate in pairs(Enemies) do
            if math.floor(candidate.y) > maxY and candidate.mission == "PROTEC" then
                minY = maxY
                maxY = math.floor(candidate.y)
            end
        end

        -- Save a list of all enemies at lowest Y position
        local candidates = {}
        for _, candidate in pairs(Enemies) do
            if math.floor(candidate.y) >= maxY and candidate.mission == "PROTEC" then
                table.insert(candidates, candidate)
            end
        end
        if #candidates < 3 then
            for _, candidate in pairs(Enemies) do
                if math.floor(candidate.y) == minY and candidate.mission == "PROTEC" then
                    table.insert(candidates, candidate)
                end
            end
        end
        if #candidates > 0 then
            local enemy = candidates[math.random(#candidates)]
            if enemy.enemyType == "jelly" or enemy.enemyType == "chungus" or enemy.enemyType == "spinner" then
                enemy.sy = 0.5
            elseif enemy.enemyType == "butterfly" then
                enemy.sy = 1
            else
                enemy.sy = 2
            end
            if enemy.enemyType == "devil" then
                if enemy.x == Ship.x then
                    enemy.sx = 0
                elseif enemy.x < Ship.x then
                    enemy.sx = 1
                else
                    enemy.sx = -1
                end
            elseif enemy.enemyType == "spinner" then
                enemy.sx = math.random() * 2 - 1.0
            end
            
            enemy.mission = "ATTAC"
        end
    end
    --return enemy
end