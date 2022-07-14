if (os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1") then
    require("lldebugger").start()
end
Json = require "lunajson"
require "draw"
require "update"

-- To Do:
-- --------------------
-- General Game Flow
-- Music
-- Multiple Enemies
-- Big Enemies (Boss)
-- Enemy Shots

-- DoggieZone
-- 1. Create more enemies 3 more (4 total) (counting my jellyfish as one)
-- 2. Expand particle effects.

-- _INIT() in Pico-8
function love.load()

    ScreenW = 128
    ScreenH = 128
    ScreenScale = 4
    TileSize = 8

    local success = love.window.setMode(ScreenW * ScreenScale, ScreenH * ScreenScale, {resizable=false})
    if (success) then
        love.graphics.setDefaultFilter("nearest", "nearest", 1)

        Font8 = love.graphics.newFont("font/Bitstream Vera Sans Mono Roman.ttf", 8, "mono", 1)
        love.graphics.setFont(Font8)

        -- pico-8 graphics page
        Img = love.graphics.newImage("img/graphics.png", nil)

        White = {1, 1, 1, 1}
        -- pio-8 pallette
        Pal = {{0/255, 0/255, 0/255, 1.0}
        , {29/255, 43/255, 83/255, 1.0}
        , {126/255, 37/255, 83/255, 1.0}
        , {0/255, 135/255, 81/255, 1.0}
        , {171/255, 82/255, 54/255, 1.0}
        , {95/255, 87/255, 79/255, 1.0}
        , {194/255, 195/255, 199/255, 1.0}
        , {255/255, 241/255, 232/255, 1.0}
        , {255/255, 0/255, 77/255, 1.0}
        , {255/255, 163/255, 0/255, 1.0}
        , {255/255, 236/255, 39/255, 1.0}
        , {0/255, 228/255, 54/255, 1.0}
        , {41/255, 173/255, 255/255, 1.0}
        , {131/255, 118/255, 156/255, 1.0}
        , {255/255, 119/255, 168/255, 1.0}
        , {255/255, 204/255, 170/255, 1.0}}

        PalWhite = {Pal[8], Pal[8], Pal[8], Pal[8],
                    Pal[8], Pal[8], Pal[8], Pal[8],
                    Pal[8], Pal[8], Pal[8], Pal[8],
                    Pal[8], Pal[8], Pal[8], Pal[8],
                }
        
        -- Normal (green), Red, Blue
        PalGreenAlien = {
            {
                Pal[1], Pal[2], Pal[3], Pal[4],
                Pal[5], Pal[6], Pal[7], Pal[8],
                Pal[9], Pal[10], Pal[11], Pal[12],
                Pal[13], Pal[14], Pal[15], Pal[16]
            }, 
            {
                Pal[1], Pal[2], Pal[3], Pal[3],
                Pal[5], Pal[6], Pal[7], Pal[8],
                Pal[9], Pal[10], Pal[11], Pal[9],
                Pal[13], Pal[14], Pal[15], Pal[16]
            },
            {
                Pal[1], Pal[2], Pal[3], Pal[2],
                Pal[5], Pal[6], Pal[7], Pal[8],
                Pal[9], Pal[10], Pal[11], Pal[13],
                Pal[13], Pal[14], Pal[15], Pal[16]
            },
        }

        -- Shader stolen from the love2d.org forums by s-ol
        RecolorShader = love.graphics.newShader(
            [[
                #ifdef VERTEX
                vec4 position( mat4 transform_projection, vec4 vertex_position)
                {
                    return (transform_projection * vertex_position);
                }
                #endif
                #ifdef PIXEL
                extern vec4 Pal[16]; // size of color palette (16 colors)
                extern vec4 Target[16];
                vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
                {
                    vec4 pixel = Texel(texture, texture_coords);
                    for(int i = 0; i < 16; i++)
                    {
                        if (pixel == Pal[i])
                        {
                            return Target[i];
                        }
                    }
                    return pixel;
                }
                #endif
            ]]
        )
        RecolorShader:send("Pal", unpack(Pal)) -- Pal[2], Pal[3], Pal[4], Pal[5], Pal[6], Pal[7], Pal[8], Pal[9], Pal[10], Pal[11], Pal[12], Pal[13], Pal[14], Pal[15])

        local levelTxt = love.filesystem.read("/levels/level.json")
        LevelJson = Json.decode(levelTxt)
        Quads = {}
        local imgW, imgH = Img:getDimensions()
        local i = 0
        for y = 0, imgH - 1, TileSize
        do
            for x = 0, imgW - 1, TileSize
            do
                if x ~= 0 or y ~= 0 then
                    i = i + 1
                    Quads[i] = love.graphics.newQuad(x, y, TileSize, TileSize, Img)
                end
            end
        end
        --[[
            -- Update big sprite quads.
        SprExplosion = 48
        local x, y, w, h = Quads[SprExplosion]:getViewport()
        for i = 0, 4 do
            Quads[SprExplosion + i]:setViewport(x + (w * i * 2), y, w * 2, h * 2, imgW, imgH)
        end
        ]]--

        Sfx = {}
        Sfx["laser"] = love.audio.newSource("audio/laser.wav", "static")
        Sfx["hurt"] = love.audio.newSource("audio/hurt.wav", "static")
        Sfx["enemyHit"] = love.audio.newSource("audio/enemyHit.wav", "static")
        Sfx["enemyShieldHit"] = love.audio.newSource("audio/enemyShieldHit.wav", "static")
        Ship = {}
        Ship.sprite = 2
        FlameSpr = 5
        Lives = 3
        Stars = {}
        Enemies = {}
        Particles = {}
        Shockwaves = {}
        ShootOK = true
        SwitchOK = true
        ShotType = 1
        ShotTypes = {16, 103, 104, 105} -- Fire Ball, Laser, Spread, Wave
        Shots = {}
        ButtonReady = false
        BlinkT = 1
        Mode = "START"
        PrintScreenReleased = false
        InvulnerableMax = 60
        ShotTimeoutMax = 4
        FlashTimeoutMax = 2
        T = 0
        ColorIndex = 2
    end
end

-- _DRAW() in PICO-8, 30 FPS
function love.draw()
    -- scale to Pico-8 screen size
    love.graphics.push()
    love.graphics.scale(ScreenScale, ScreenScale)
    
    if Mode == "GAME" then
        DrawGame()
    elseif Mode == "GET_READY" then
        DrawGetReady()
    elseif Mode == "START" then
        DrawStart()
    elseif Mode == "OVER" then
        DrawOver()
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
    BlinkT = BlinkT + 1
    T = T + 1
    if Mode == "GAME" then
        UpdateGame(dt)
    elseif Mode == "GET_READY" then
        UpdateGetReady(dt)
    elseif Mode == "START" then
        -- Start Screen
        UpdateStart(dt)
    elseif Mode == "OVER" then
        -- Game Over Screen
        UpdateOver(dt)
    end
    if love.keyboard.isDown("p") then
        if PrintScreenReleased then
            PrintScreenReleased = false
            love.graphics.captureScreenshot("screenshot" .. os.time() .. ".png")
        end
    else
        PrintScreenReleased = true
    end
end

function AddEnemy(prototype)
    local enemy = {}
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
    enemy.flash = 0
    enemy.dead = false

    table.insert(Enemies, enemy)
end

function AddExplosion(centerX,centerY, isBlue)
    --[[
    local explosion = {}
    local x, y, w, h = Quads[SprExplosion]:getViewport()
    explosion.age = 1
    explosion.x = centerX - (w / 2)
    explosion.y = centerY - (h / 2)
    table.insert(Explosions, explosion)
    ]]--
    -- center
    local particle = {}
    particle.isExplosion = true
    particle.x = centerX
    particle.y = centerY
    particle.radius = 10
    particle.clr = 8
    particle.sx = 0
    particle.sy = 0
    particle.age = 0
    particle.maxAge = 10
    particle.isBlue = isBlue
    table.insert(Particles, particle)

    AddShockwave(centerX, centerY, true)

    -- beams
    local speed = 1.5
    local clrs = {10, 11, 8, 15}
    for ang=0, 359, 30 do
        local rad = math.rad(ang)
        local particle = {}
        particle.x = centerX
        particle.y = centerY
        particle.startX = particle.x
        particle.startY = particle.y
        particle.sx = speed * math.cos(rad)
        particle.sy = speed * math.sin(rad)
        particle.age = 0
        particle.maxAge = 20
        particle.radius = 100
        particle.clr = clrs[love.math.random(1, #clrs)]
        particle.radius = 1
        particle.isBeam = true
        table.insert(Particles, particle)
    end
    -- clouds
    for i = 1, 30 do
        local particle = {}
        particle.isExplosion = true
        particle.x = centerX
        particle.y = centerY
        particle.radius = 1 + love.math.random(4)
        particle.age = love.math.random(2)
        particle.maxAge = 20 + love.math.random(20)
        particle.isBlue = isBlue
        if isBlue then
            particle.clr = GetParticleColorBlue(particle.age)
        else
            particle.clr = GetParticleColorRed(particle.age)
        end
        particle.sx = (love.math.random() - 0.5) * 6
        particle.sy = (love.math.random() - 0.5) * 6
        particle.isSpark = false
        table.insert(Particles, particle)
    end

    -- sparks
    for i = 1, 20 do
        local particle = {}
        particle.isExplosion = true
        particle.x = centerX
        particle.y = centerY
        particle.radius = 1 + love.math.random(4)
        particle.age = love.math.random(2)
        particle.maxAge = 20 + love.math.random(20)
        particle.isBlue = isBlue
        if isBlue then
            particle.clr = GetParticleColorBlue(particle.age)
        else
            particle.clr = GetParticleColorRed(particle.age)
        end
        particle.sx = (love.math.random() - 0.5) * 10
        particle.sy = (love.math.random() - 0.5) * 10
        particle.isSpark = true
        table.insert(Particles, particle)
    end
end

function AddParticle(x, y, sx, sy, lifeTime, clr, radius)
    local particle = {}
    particle.x = x
    particle.y = y
    particle.sx = sx
    particle.sy = sy
    particle.age = 0
    particle.maxAge = lifeTime
    particle.clr = clr
    particle.radius = radius
    table.insert(Particles, particle)
end

function AddShockwave(x, y, isBig)
    local shockwave = {}
    shockwave.x = x
    shockwave.y = y
    shockwave.radius = 3
    if isBig then
        shockwave.targetRadius = 25
        shockwave.speed = 3.5
        shockwave.clr = 8
    else
        shockwave.targetRadius = 6
        shockwave.speed = 1
        shockwave.clr = 10
    end
    table.insert(Shockwaves, shockwave)
end

function AddSpark(centerX, centerY)
    -- spark
    local particle = {}
    particle.isExplosion = true
    particle.x = centerX
    particle.y = centerY
    particle.radius = 1 + love.math.random(4)
    particle.age = love.math.random(2)
    particle.maxAge = 20 + love.math.random(20)
    particle.sx = (love.math.random() - 0.5) * 8
    particle.sy = (love.math.random() - 1) * 3
    particle.isSpark = true
    particle.clr = 8
    table.insert(Particles, particle)
end

function AddShot(x, y)
    local shot = {}
    shot.x = x
    shot.y = y
    shot.sprite = ShotTypes[ShotType]
    shot.ShotType = ShotType
    shot.sx = 0
    shot.sy = -4
    shot.age = 0
    shot.maxAge = 300

    if ShotType == 2 then
        shot.maxAge = 7
    end

    if ShotType == 4 then
        shot.amplitude = 1
        shot.time = 0.0
    end

    if ShotType == 3 then
        for angle = 60, 120, 10 do
            local newShot = {}
            for key, value in pairs(shot) do
                newShot[key] = value
            end

            newShot.sx = math.cos(math.rad(angle)) * 4
            newShot.sy = math.sin(math.rad(angle)) * -4
            table.insert(Shots, newShot)
        end
    else
        table.insert(Shots, shot)
    end
end

function AddShotSpray(centerX,centerY)
    local speed = 1
    local clrs = {10, 11, 8, 15}
    for ang=0, 359, 60 do
        local rad = math.rad(ang)
        AddParticle(centerX, centerY, speed * math.cos(rad), speed * math.sin(rad), 8, clrs[love.math.random(1, #clrs)], 1)
    end
end

function Blink()
    local blinkAni = {6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 8, 8, 7, 7, 6, 6}
    if BlinkT > #blinkAni then
        BlinkT = 1
    end
    return blinkAni[BlinkT]
end

function Bounce(x, dx, maxX)
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

function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

function Collide(a, b)
    local x1, y1, w1, h1 = Quads[math.floor(a.sprite)]:getViewport()
    local x2, y2, w2, h2 = Quads[math.floor(b.sprite)]:getViewport()
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

function GetParticleColorBlue(age)
    local clr = 8
    if age > 10 then -- 5 then
        clr = 7
    end
    if age > 14 then --7 then
        clr = 13
    end
    if age > 20 then --10 then
        clr = 14
    end
    if age > 24 then --12 then
        clr = 2
    end
    if age > 30 then --15 then
        clr = 2
    end

    return clr
end

function GetParticleColorRed(age)
    local clr = 8
    if age > 10 then -- 5 then
        clr = 11
    end
    if age > 14 then --7 then
        clr = 10
    end
    if age > 20 then --10 then
        clr = 9
    end
    if age > 24 then --12 then
        clr = 3
    end
    if age > 30 then --15 then
        clr = 6
    end

    return clr
end