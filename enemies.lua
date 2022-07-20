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

function AddEnemyWave()
    local grid = LevelJson["waves"][Wave]["formation"]
    local y = 2.5 * TileSize
    local xStep = 1.5 * TileSize
    local yStep = (2 * TileSize) + 2
    for j, row in pairs(grid) do
        local x = (ScreenW - (#row * xStep)) / 2
        for i, enemyType in pairs(row) do
            if enemyType ~= nil and enemyType ~= "" then
                AddEnemy({x=x, y=y, sx=0, sy=0,enemyType=enemyType})
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