function AddEnemy(prototype)
    local enemyType = prototype.enemyType
    if enemyType == nil then
        enemyType = "eye"
    end
    local basePrototype = LevelJson["prototypes"][enemyType]
    local enemy = {}

    if basePrototype ~= nil then
        for key, value in pairs(basePrototype) do
            enemy[key] = value
        end
    end

    for key, value in pairs(prototype) do
        enemy[key] = value
    end
    if enemy.x == nil then
        enemy.x = (ScreenW - TileSize) / 2
    end
    if enemy.y == nil then
        enemy.y = -1 * TileSize
    end

    if enemy.sx == nil then
        enemy.sx = 0
    end
    
    if enemy.sy == nil then
        enemy.sy = 1
    end

    enemy.spriteIndex = 1
    enemy.sprite = enemy.frames[enemy.spriteIndex]

    if enemy.hp == nil then
        enemy.hp = 1
    end

    enemy.time = 0
    enemy.visible = false
    enemy.flash = 0
    enemy.dead = false

    table.insert(Enemies, enemy)
end

function AddEnemyWave()
    Time = 0
    PreviousTime = -1.0
end

function NextWave()
    Wave = Wave + 1
    if Wave > 4 then
        StartWin()
    else
        if Wave > 1 then
            love.audio.stop()
            local bgm = Music["nextwave"]
            bgm:setLooping(false)
            bgm:play()
        end
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