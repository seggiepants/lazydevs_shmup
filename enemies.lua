-- Waves and Enemies

function AddEnemy(prototype)
    local enemyType = prototype.enemyType
    if enemyType == nil then
        enemyType = "eye"
    end
    local basePrototype = LevelJson["prototypes"][enemyType]
    local enemy = MakeSprite(basePrototype)

    for key, value in pairs(prototype) do
        enemy[key] = value
    end
    
    if enemy.hp == nil then
        enemy.hp = 1
    end

    enemy.time = 0
    enemy.visible = false
    
    table.insert(Enemies, enemy)
end

function AddEnemies()
    local grid = LevelJson["waves"][Wave]["formation"]
    local y = 2 * TileSize
    local xStep = 1.5 * TileSize
    local yStep = 1.5 * TileSize
    local rowCount = #grid
    for j, row in pairs(grid) do
        local x = (ScreenW - (#row * xStep)) / 2
        for i, enemyType in pairs(row) do
            if enemyType ~= nil and enemyType ~= "" then
                local x1 = math.random(ScreenW)
                local y1 = y - (yStep * rowCount) - TileSize
                local dx = x - x1
                local dy = y - y1
                local sy = 2
                local sx = 2 * (dx/dy)
                AddEnemy({x=x1, y=y1, posX=x, posY=y, sx=sx, sy=sy,enemyType=enemyType,mission="FLYIN"})
            end
            x = x + xStep
        end
        y = y + yStep
    end
end

function NextWave()
    Wave = Wave + 1
    if Wave > #LevelJson["waves"] then
        StartWin()
    else
        love.audio.stop()
        local bgm
        if Wave > 1 then
            bgm = Music["nextwave"]
        else
            bgm = Music["firstlevel"]
        end
        bgm:setLooping(false)
        bgm:play()
        WaveTime = 75
        Mode = "WAVETEXT"
        PreviousTime = -1
        Time = 0
        ColorIndex = ColorIndex + 1
        if ColorIndex > #PalGreenAlien then
            ColorIndex = 1
        end
    end
end