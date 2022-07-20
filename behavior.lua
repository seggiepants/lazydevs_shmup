-- Behavior
function EnemyMission(enemy)
    if enemy.mission == "FLYIN" then
        -- Fly In
        enemy.x = enemy.x + enemy.sx
        enemy.y = enemy.y + enemy.sy
        if enemy.y >= enemy.posY then
            enemy.y = enemy.posY
            enemy.x = enemy.posX
            enemy.sx = 0
            enemy.sy = 0
            enemy.mission = "PROTEC"
        end
    elseif enemy.mission == "PROTEC" then
        -- Stay Put
        if T % 30 == 0 then
            if math.random(3 + (#Enemies * 3)) == 1 then
                enemy.sy = 2
                enemy.mission = "ATTAC"
            end
        end
    elseif enemy.mission == "ATTAC" then
        -- Attack
        enemy.x = enemy.x + enemy.sx
        enemy.y = enemy.y + enemy.sy
        if enemy.y > ScreenH  or enemy.x + TileSize < 0 or enemy.x > ScreenW then
            enemy.x = math.random(ScreenW)
            enemy.y = -1 * (TileSize * 2)
            local dx = enemy.posX - enemy.x
            local dy = enemy.posY - enemy.y
            enemy.sy = 2
            enemy.sx = 2 * (dx/dy)
            enemy.mission = "FLYIN"
            print("SX: "..enemy.sx..", SY: "..enemy.sy)
        end
    end
end