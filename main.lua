if (os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1") then
    require("lldebugger").start()
end
json = require "lunajson"
require "draw"
require "update"

-- DoggieZone
-- 1. Bullet enemy collision
-- 2. Autofire - consistently spaced no initial delay for keyboard repeat
-- 3. Ship temporarily invulnerable on hit. Let enemy hang around for now instead of deleting them.

-- _INIT() in Pico-8
function love.load()

    screenW = 128
    screenH = 128
    screenScale = 4
    tileSize = 8

    success = love.window.setMode(screenW * screenScale, screenH * screenScale, {resizable=false})
    if (success) then
        love.graphics.setDefaultFilter("nearest", "nearest", 1)

        font8 = love.graphics.newFont("font/Bitstream Vera Sans Mono Roman.ttf", 8, "mono", 1)
        love.graphics.setFont(font8)

        -- pico-8 graphics page
        img = love.graphics.newImage("img/graphics.png")

        white = {1, 1, 1, 1}
        -- pio-8 pallette
        pal = {{0/255, 0/255, 0/255}
        , {29/255, 43/255, 83/255}
        , {126/255, 37/255, 83/255}
        , {0/255, 135/255, 81/255}
        , {171/255, 82/255, 54/255}
        , {95/255, 87/255, 79/255}
        , {194/255, 195/255, 199/255}
        , {255/255, 241/255, 232/255}
        , {255/255, 0/255, 77/255}
        , {255/255, 163/255, 0/255}
        , {255/255, 236/255, 39/255}
        , {0/255, 228/255, 54/255}
        , {41/255, 173/255, 255/255}
        , {131/255, 118/255, 156/255}
        , {255/255, 119/255, 168/255}
        , {255/255, 204/255, 170/255}}

        local levelTxt = love.filesystem.read("/levels/level.json")
        levelJson = json.decode(levelTxt)
        quads = {}
        imgW, imgH = img:getDimensions()
        i = 0
        for y = 0, imgH - 1, tileSize
        do
            for x = 0, imgW - 1, tileSize
            do
                if x ~= 0 or y ~= 0 then
                    i = i + 1
                    quads[i] = love.graphics.newQuad(x, y, tileSize, tileSize, img)
                end
            end
        end

        sfx = {}
        sfx["laser"] = love.audio.newSource("audio/laser.wav", "static")
        sfx["hurt"] = love.audio.newSource("audio/hurt.wav", "static")
        ship = {}
        ship.sprite = 2
        flameSpr = 5
        lives = 3
        stars = {}
        enemies = {}
        shootOK = true
        switchOK = true
        shotType = 1
        shotTypes = {16, 103, 104, 105} -- Fire Ball, Laser, Spread, Wave
        shots = {}
        buttonReady = false
        blinkT = 1
        mode = "START"
        printScreenReleased = false
        invulnerableMax = 60
        shotTimeoutMax = 10

        local enemy = {}
    end
end

-- _DRAW() in PICO-8, 30 FPS
function love.draw()
    -- scale to Pico-8 screen size
    love.graphics.push()
    love.graphics.scale(screenScale, screenScale)
    
    if mode == "GAME" then
        drawGame()
    elseif mode == "GET_READY" then
        drawGetReady()
    elseif mode == "START" then
        drawStart()
    elseif mode == "OVER" then
        drawOver()
    end

    -- restore screen size
    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.quit()
    print("Goodbye")
end

--- _UPDATE in PICO-8, Hard 30 FPS
function love.update(dt)
    blinkT = blinkT + 1
    if mode == "GAME" then
        updateGame(dt)
    elseif mode == "GET_READY" then
        updateGetReady(dt)
    elseif mode == "START" then
        -- Start Screen
        updateStart(dt)
    elseif mode == "OVER" then
        -- Game Over Screen
        updateOver(dt)
    end
    if love.keyboard.isDown("p") then
        if printScreenReleased then
            printScreenReleased = false
            love.graphics.captureScreenshot("screenshot" .. os.time() .. ".png")
        end
    else
        printScreenReleased = true
    end
end

function addShot(x, y)
    shot = {}
    shot.x = x
    shot.y = y
    shot.sprite = shotTypes[shotType]
    shot.shotType = shotType
    shot.sx = 0
    shot.sy = -4
    shot.lifetime = 300

    if shotType == 2 then
        shot.lifetime = 7
    end

    if shotType == 4 then
        shot.amplitude = 1
        shot.time = 0.0
    end

    if shotType == 3 then
        for angle = 60, 120, 10 do
            newShot = {}
            for key, value in pairs(shot) do
                newShot[key] = value
            end

            newShot.sx = math.cos(math.rad(angle)) * 4
            newShot.sy = math.sin(math.rad(angle)) * -4
            table.insert(shots, newShot)
        end
    else
        table.insert(shots, shot)
    end
end

function addEnemy(prototype)
    local enemy = {}
    for key, value in pairs(prototype) do
        enemy[key] = value
    end
    if enemy.x == nil then
        enemy.x = (screenW - tileSize) / 2
    end
    if enemy.y == nil then
        enemy.y = -1 * tileSize
    end

    if enemy.sx == nil then
        enemy.sx = 0
    end
    
    if enemy.sy == nil then
        enemy.sy = 1
    end

    if enemy.enemyType == nil or enemy.enemyType == "eye" then
        enemy.sprite = 21
        enemy.spriteMin = 21
        enemy.spriteMax = 24
    elseif enemy.enemyType == "jelly" then
        enemy.sprite = 37
        enemy.spriteMin = 37
        enemy.spriteMax = 40
    end

    if enemy.hp == nil then
        enemy.hp = 1
    end

    enemy.time = 0
    enemy.visible = false
    enemy.dead = false

    table.insert(enemies, enemy)
end

function blink()
    local blinkAni = {6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 8, 8, 7, 7, 6, 6}
    if blinkT > #blinkAni then
        blinkT = 1
    end
    return blinkAni[blinkT]
end

function bounce(x, dx, maxX)
    x = x + dx
    if x < 0 then
        x = 0
        dx = math.abs(dx)
    end
    if x > maxX then
        x = maxX
        dx = -1 * math.abs(dx)
    end

    return x, dx
end

function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

function collide(a, b)
    local x1, y1, w1, h1 = quads[math.floor(a.sprite)]:getViewport()
    local x2, y2, w2, h2 = quads[math.floor(b.sprite)]:getViewport()
    if a.y >= b.y + h2 - 1 then
        return false
     end
    
    if a.x >= b.x + w2 - 1 then
        return false
    end

    if a.x + w1 - 1 <= b.x then
        return false
    end
    
    if a.y + h1 - 1 <= b.y then
        return false
    end

    return true
end