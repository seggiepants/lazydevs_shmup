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

    if enemy.wait == nil then
        enemy.wait = 0
    end

    if enemy.animationSpeed == nil then
        enemy.animationSpeed = 0.4
    end

    enemy.time = 0
    enemy.visible = false
    
    table.insert(Enemies, enemy)

    return enemy
end

function AddEnemies()
    local grid = LevelJson["waves"][Wave]["formation"]
    local y = 2 * TileSize
    local xStep = 1.5 * TileSize
    local yStep = 1.5 * TileSize
    local rowCount = #grid
    AttackFrequency = LevelJson["waves"][Wave]["attackFrequency"]
    if AttackFrequency == nil then
        AttackFrequency = 60
    end
    love.audio.play(Sfx["nextWave"])
    for j, row in pairs(grid) do
        local x = (ScreenW - (#row * xStep)) / 2
        for i, enemyType in pairs(row) do
            if enemyType ~= nil and enemyType ~= "" then
                local startX = (1.25 * x) - ScreenW
                local startY = y - (ScreenW / 2) - TileSize

                if Wave % 2 == 0 then
                    startX = (1.25 * x) + ScreenW
                end
                
                local newEnemy = AddEnemy({
                    x=startX
                    , y=startY
                    , posX=x
                    , posY=y
                    , sx=0
                    , sy=3
                    , enemyType=enemyType
                    , wait=x/2
                    , mission="FLYIN"})
                if enemyType == "boss" then
                    newEnemy.boss = true
                    newEnemy.sy = 0.5
                    newEnemy.posX = (ScreenW - newEnemy.width) / 2
                    newEnemy.posY = newEnemy.height
                    newEnemy.x = newEnemy.posX
                    newEnemy.y = newEnemy.height * -1
                end
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
        if WebMode == false then
            love.audio.stop()
            local bgm
            if Wave > 1 then
                bgm = Music["nextwave"]
            else
                bgm = Music["firstlevel"]
            end
            bgm:setLooping(false)
            bgm:play()
        end
        WaveTime = 75
        Mode = "WAVETEXT"
        PreviousTime = -1
        Time = 0
        EnemyShots = {} -- clear out old enemy fire
        Shots = {} -- clear out player enemy fire
        AttackFrequency = LevelJson["waves"][Wave]["attackFrequency"]
        FireFrequency = LevelJson["waves"][Wave]["fireFrequency"]
        if AttackFrequency == nil then
            AttackFrequency = 60
        end
        if FireFrequency == nil then
            FireFrequency = 20
        end
        NextFire = T + 20 + math.random(FireFrequency)
    end
end