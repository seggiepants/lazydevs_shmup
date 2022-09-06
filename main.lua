if (os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1") then
    require("lldebugger").start()
end
Json = require "lunajson"
require "draw"
require "update"
require "enemies"
require "behavior"
require "bullets"
require "boss"

-- To Do:
-- --------------------
-- Nicer Screens

-- DoggieZone
-- 1. Playtest the game, find bugs, balance problems. 
--    a. Don't think fire frequency is working right seem to have dive or fire but not both normally.
--    b. Want mouse support for Android Love version.

-- Other
-- --------------------
-- Stopped at 0:15

-- _INIT() in Pico-8
function love.load()

    ScreenW = 128
    ScreenH = 128
    ScreenScale = 4
    TileSize = 8
    FPS = 60
    Version = "v1.0"

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

        PalBoss = {Pal[1], Pal[2], Pal[3], Pal[9],
                    Pal[5], Pal[6], Pal[7], Pal[8],
                    Pal[9], Pal[10], Pal[11], Pal[15],
                    Pal[13], Pal[14], Pal[15], Pal[16],
                }

        PalPink = {Pal[15], Pal[15], Pal[15], Pal[15],
                    Pal[15], Pal[15], Pal[15], Pal[15],
                    Pal[15], Pal[15], Pal[15], Pal[15],
                    Pal[15], Pal[15], Pal[15], Pal[15],
                }
        
        PalWhite = {Pal[8], Pal[8], Pal[8], Pal[8],
                    Pal[8], Pal[8], Pal[8], Pal[8],
                    Pal[8], Pal[8], Pal[8], Pal[8],
                    Pal[8], Pal[8], Pal[8], Pal[8],
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
        RecolorShader:send("Pal", unpack(Pal))
        
        -- Stolen/modified from https://love2d.org/forums/viewtopic.php?t=84137
        TransparentShader = love.graphics.newShader(
            [[
            extern float alpha;
            vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc) {
                vec4 c = Texel(texture, tc);
                return vec4(c.r, c.g, c.b, c.a * alpha);
            }
            ]]
        )
        TransparentShader:send("alpha", 0.5)

        local levelTxt = love.filesystem.read("/levels/level.json")
        LevelJson = Json.decode(levelTxt)
        Quads = {}
        local quadsTxt = love.filesystem.read("/img/graphics.json")
        local quadsJson = Json.decode(quadsTxt)
        local imgW, imgH = Img:getDimensions()
        for i, quad in pairs(quadsJson["quads"]) do
            Quads[i] = love.graphics.newQuad(quad.x, quad.y, quad.w, quad.h, imgW, imgH)
        end

        Sfx = {}
        Sfx["laser"] = love.audio.newSource("audio/laser.wav", "static")
        Sfx["hurt"] = love.audio.newSource("audio/hurt.wav", "static")
        Sfx["enemyHit"] = love.audio.newSource("audio/enemyHit.wav", "static")
        Sfx["enemyShot"] = love.audio.newSource("audio/enemyShot.wav", "static")
        Sfx["enemyShieldHit"] = love.audio.newSource("audio/enemyShieldHit.wav", "static")
        Sfx["lifeUp"] = love.audio.newSource("audio/lifeUp.wav", "static")
        Sfx["nextWave"] = love.audio.newSource("audio/spawnWave.wav", "static")
        Sfx["pickup"] = love.audio.newSource("audio/pickup.wav", "static")
        Sfx["weaponPowerup"] = love.audio.newSource("audio/weaponPowerup.wav", "static")
        Sfx["weaponPowerdown"] = love.audio.newSource("audio/weaponPowerdown.wav", "static")
        Sfx["bombFail"] = love.audio.newSource("audio/bombFail.wav", "static")
        Sfx["cherryBomb"] = love.audio.newSource("audio/cherryBomb.wav", "static")
        Sfx["bossShoot"] = love.audio.newSource("audio/bossShoot.wav", "static")
        Sfx["bossIntro"] = love.audio.newSource("audio/bossIntro.wav", "static")
        Sfx["bossDeath"] = love.audio.newSource("audio/bossDeath.wav", "static")

        Music = {}
        Music["start"] = love.audio.newSource("audio/intro.xm", "stream")
        Music["game"] = love.audio.newSource("audio/gameplay.xm", "stream")
        Music["firstlevel"] = love.audio.newSource("audio/firstlevel.xm", "stream")
        Music["nextwave"] = love.audio.newSource("audio/nextwave.xm", "stream")
        Music["over"] = love.audio.newSource("audio/lose.xm", "stream")
        Music["win"] = love.audio.newSource("audio/win.xm", "stream")
        Music["bossMusic"] = love.audio.newSource("audio/bossMusic.xm", "stream")
        
        Ship = {}
        ShipPrototype = {
            frames = {1, 2, 3}
        }
        Ship.sprite = 2
        AttackFrequency = 60
        FireFrequency = 20
        NextFire = 0
        FlameSpr = 4
        Lives = 3
        Lockout = 0
        Stars = {}
        Enemies = {}
        Floats = {}
        Particles = {}
        Pickups = {}
        Shockwaves = {}
        ShootOK = true
        ShotType = 1
        ShotTypes = {
            {
                frames = {11}
                , sprite = 43
                , name = "Vulcan"
            }, 
            {
                frames = {53}
                , sprite = 44
                , name = "Laser"
            }, 
            {
                frames = {54}
                , sprite = 45
                , name = "Spread"
            }, 
            {
                frames = {55}
                , sprite = 46
                , name = "Wave"
            }} -- Fire Ball, Laser, Spread, Wave
        CherrySpr = 42
        Shots = {}
        EnemyShots = {}
        ButtonReady = false
        BlinkT = 1
        InvulnerableMax = 60
        ShotTimeoutMax = 4
        FlashTimeoutMax = 2
        FlashTimeoutBoss = 5
        T = 0
        Wave = 0
        Shake = 0
        ScreenFlash = 0
        Cherries = 0
        WebMode = false
        HighScore = 0
        PeekerX = ScreenW / 2

        -- Debug = "chicken"
        Keys = {}
        KeysPrev = {}
        CurrentJoystick = 0
        Joysticks = {}
        LoadHighScore()
        StartTitle()
    end
end

-- _DRAW() in PICO-8, 30 FPS
function love.draw()
    -- scale to Pico-8 screen size
    love.graphics.push()
    love.graphics.scale(ScreenScale, ScreenScale)
    ScreenShake()
    if Mode == "GAME" then
        DrawGame()
    elseif Mode == "GET_READY" then
        DrawGetReady()
    elseif Mode == "START" then
        DrawStart()
    elseif Mode == "WAVETEXT" then
        DrawWaveText()
    elseif Mode == "OVER" then
        DrawOver()
    elseif Mode == "WIN" then
        DrawWin()
    end
    --[[ if #Debug > 0 then
        love.graphics.setColor(Pal[8])
        love.graphics.print(Debug, 1, 1)
    end ]]
    -- restore screen size
    love.graphics.pop()
end

function love.joystickadded(joystick)
    local id = joystick:getID()
    Joysticks[id] = joystick
    if CurrentJoystick == 0 then CurrentJoystick = id end
end

function love.joystickremoved(joystick)
    local id = joystick:getID()    
    table.remove(Joysticks, id)
    if CurrentJoystick == id then CurrentJoystick = 0 end
    if #Joysticks > 0 then 
        CurrentJoystick, _ = next(Joysticks)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.quit()
    --print("Goodbye")
    SaveHighScore()
end

--- _UPDATE in PICO-8, Hard 30 FPS
function love.update(dt)
    -- Cap the FPS
    local sleepTime = (1/FPS) - dt
    if sleepTime > 0 then 
        -- print("Sleep Time: " .. sleepTime .. " dt: " .. dt)
        love.timer.sleep(sleepTime) 
    end
    BlinkT = BlinkT + 1
    T = T + 1
    ReadInput()
    if Mode == "GAME" then
        UpdateGame(dt)
    elseif Mode == "GET_READY" then
        UpdateGetReady(dt)
    elseif Mode == "START" then
        -- Start Screen
        UpdateStart(dt)
    elseif Mode == "WAVETEXT" then
        -- Wave Number Notice
        UpdateWaveText(dt)
    elseif Mode == "OVER" then
        -- Game Over Screen
        UpdateOver(dt)
    elseif Mode == "WIN" then
        -- You won the game
        UpdateWin(dt)
    end
    if Btnp("printScr") then
        love.graphics.captureScreenshot("screenshot" .. os.time() .. ".png")        
    end
end

function AddBigExplosion(centerX, centerY)
    -- center
    local particle = {}
    particle.isExplosion = true
    particle.x = centerX
    particle.y = centerY
    particle.radius = 30
    particle.clr = 8
    particle.sx = 0
    particle.sy = 0
    particle.age = 0
    particle.maxAge = 10
    table.insert(Particles, particle)

    AddShockwave(centerX, centerY, nil, true)

    local speed = 12
    local clrs = {10, 11, 8, 15}
    for i = 1, 60 do
        local particle = {}
        particle.x = centerX
        particle.y = centerY
        particle.startX = particle.x
        particle.startY = particle.y
        particle.sx = math.random(speed) - (speed / 2)
        particle.sy = math.random(speed) - (speed / 2)
        particle.age = math.random(2)
        particle.maxAge = 20 + math.random(20)
        particle.clr = clrs[love.math.random(1, #clrs)]
        particle.radius = 1 + math.random(8)

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
        particle.clr = GetParticleColorRed(particle.age)
        particle.sx = (love.math.random() - 0.5) * 6
        particle.sy = (love.math.random() - 0.5) * 6
        particle.isSpark = false
        table.insert(Particles, particle)
    end

    -- sparks
    for i = 1, 100 do
        local particle = {}
        particle.isExplosion = true
        particle.x = centerX
        particle.y = centerY
        particle.radius = 1 + love.math.random(4)
        particle.age = love.math.random(2)
        particle.maxAge = 40 + love.math.random(40)
        particle.clr = GetParticleColorRed(particle.age)
        particle.sx = (love.math.random() - 0.5) * 30
        particle.sy = (love.math.random() - 0.5) * 30
        particle.isSpark = true
        table.insert(Particles, particle)
    end
    love.audio.play(Sfx["cherryBomb"])
end

function AddExplosion(centerX,centerY, isBlue)
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

    AddShockwave(centerX, centerY, nil, true)

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

function AddFloat(text, x, y)
    local float = {}
    float.x = x
    float.y = y
    float.text = text
    float.age = 0
    table.insert(Floats, float)
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

function AddShockwave(x, y, clr, isBig)
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
    if clr ~= nil then shockwave.clr = clr end
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
    local shot = MakeSprite(ShotTypes[ShotType])
    shot.ShotType = ShotType
    shot.x = x
    shot.y = y
    shot.sx = 0
    shot.sy = -4
    shot.damage = 1
    shot.age = 0
    shot.maxAge = 300

    if ShotType == 1 then
        shot.colX = 2
        shot.colWidth = 6
        shot.sy = -4
    end

    if ShotType == 2 then
        shot.maxAge = 7
    end

    if ShotType == 4 then
        shot.amplitude = 1
        shot.time = 0.0
    end

    if ShotType == 3 then
        local offset = math.random() * 15
        for angle = 60, 120, 20 do
            local newShot = {}
            for key, value in pairs(shot) do
                newShot[key] = value
            end

            newShot.sx = math.cos(math.rad(angle + offset)) * 4
            newShot.sy = math.sin(math.rad(angle + offset)) * -4
            table.insert(Shots, newShot)
        end
    else
        table.insert(Shots, shot)
    end
end

function Animate(obj)
    obj.spriteIndex= obj.spriteIndex + obj.animationSpeed
    if math.floor(obj.spriteIndex) > #obj.frames then
        obj.sprite = obj.frames[1]
        obj.spriteIndex = 1
    else
        obj.sprite = obj.frames[math.floor(obj.spriteIndex)]
    end
end

function Blink()
    local blinkAni = {6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 8, 8, 7, 7, 6, 6}
    if BlinkT > #blinkAni then
        BlinkT = 1
    end
    return blinkAni[BlinkT]
end

function Btn(key)
    return Keys[key]
end

function Btnp(key)
    return Keys[key] and not KeysPrev[key]
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
    local x1, y1, w1, h1
    local x2, y2, w2, h2

    if a.ghost == true or b.ghost == true then return false end
    x1 = a.x + a.colX - 1
    x2 = b.x + b.colX - 1
    y1 = a.y + a.colY - 1
    y2 = b.y + b.colY - 1
    w1 = a.colWidth
    w2 = b.colWidth
    h1 = a.colHeight
    h2 = b.colHeight

    if a.ShotType == 2 then
        h1 = y1 + h1
        y1 = 0
    end

    if b.ShotType == 2 then
        h2 = y2 + h2
        y2 = 0
    end
    
    if y1 >= y2 + h2 - 1 then
        return false
     end
    
    if x1 >= x2 + w2 - 1 then
        return false
    end

    if x1 + w1 - 1 <= x2 then
        return false
    end
    
    if y1 + h1 - 1 <= y2 then
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

function MakeSprite(prototype)
    local sprite = {}

    sprite.x = 0
    sprite.y = 0
    sprite.sx = 0
    sprite.sy = 1
    sprite.spriteIndex = 1
    sprite.sprite = 0
    sprite.flash = 0
    sprite.shake = 0
    sprite.dead = false

    if prototype ~= nil then
        for key, value in pairs(prototype) do
            sprite[key] = value
        end
    end

    if sprite.frames ~= nil then
        sprite.sprite = sprite.frames[1]
    end
    local x, y, w, h = Quads[sprite.sprite]:getViewport()
    sprite.width = w
    sprite.height = h
    if sprite.colX == nil then sprite.colX = 1 end
    if sprite.colY == nil then sprite.colY = 1 end
    if sprite.colWidth == nil then sprite.colWidth = sprite.width end
    if sprite.colHeight == nil then sprite.colHeight = sprite.height end

    return sprite
end

function ReadInput()
    -- Save previous state to KeysPrev
    for key, value in pairs(Keys) do
        KeysPrev[key] = value
    end

    -- Initialize all to false
    Keys.a = false
    Keys.b = false
    Keys.up = false
    Keys.down = false
    Keys.left = false
    Keys.right = false
    Keys.escape = false
    Keys.printScr = false

    -- Read the keyboard
    if love.keyboard.isDown("z") then Keys.a = true end
    if love.keyboard.isDown("x") then Keys.b = true end
    if love.keyboard.isDown("space") then Keys.a = true end
    if love.keyboard.isDown("tab") then Keys.b = true end
    if love.keyboard.isDown("w") then Keys.up = true end
    if love.keyboard.isDown("s") then Keys.down = true end
    if love.keyboard.isDown("a") then Keys.left = true end
    if love.keyboard.isDown("d") then Keys.right = true end
    if love.keyboard.isDown("up") then Keys.up = true end
    if love.keyboard.isDown("down") then Keys.down = true end
    if love.keyboard.isDown("left") then Keys.left = true end
    if love.keyboard.isDown("right") then Keys.right = true end
    if love.keyboard.isDown("q") then Keys.escape = true end
    if love.keyboard.isDown("escape") then Keys.escape = true end
    if love.keyboard.isDown("p") then Keys.printScr = true end

    -- Override if joystick set
    if love.joystick.getJoystickCount() > 0 and CurrentJoystick > 0 then
        local joystick = Joysticks[CurrentJoystick]
        local buttonCount = joystick:getButtonCount();
        if buttonCount >= 1 then Keys.a = joystick:isDown(1) or Keys.a end
        if buttonCount >= 2 then Keys.b = joystick:isDown(2) or Keys.b end

        local threshold = 0.25
        local direction
        -- First two axis are x, and y
        if joystick:getAxisCount() >= 2 then
            direction = joystick:getAxis(1)
            if math.abs(direction) > threshold then
                if direction < 0 then Keys.left = true else Keys.right = true end
            end
            direction = joystick:getAxis(2)
            if math.abs(direction) > threshold then
                if direction < 0 then Keys.up = true else Keys.down = true end
            end
        end
        
        -- Joypad will override joystick
        if joystick:getHatCount() > 0 then
            direction = joystick:getHat(1)
            if direction == "d" then
                Keys.left = false
                Keys.right = false
                Keys.up = false
                Keys.down = true
            elseif direction == "l" then
                Keys.left = true
                Keys.right = false
                Keys.up = false
                Keys.down = false
            elseif direction == "ld" then
                Keys.left = true
                Keys.right = false
                Keys.up = false
                Keys.down = true
            elseif direction == "lu" then
                Keys.left = true
                Keys.right = false
                Keys.up = true
                Keys.down = false
            elseif direction == "r" then
                Keys.left = false
                Keys.right = true
                Keys.up = false
                Keys.down = false
            elseif direction == "rd" then
                Keys.left = false
                Keys.right = true
                Keys.up = false
                Keys.down = true
            elseif direction == "ru" then
                Keys.left = false
                Keys.right = true
                Keys.up = true
                Keys.down = false
            elseif direction == "u" then
                Keys.left = false
                Keys.right = false
                Keys.up = true
                Keys.down = false
                -- else if direction == "c" then
                --  Centered, let the 1st axis fall through
            end
        end
    end
end

function ScreenShake()
    if Shake <= 0 then return end
    local x = math.random() * Shake - (Shake / 2)
    local y = math.random() * Shake - (Shake / 2)
    love.graphics.translate(x, y)
    if Shake > 10 then
        Shake = Shake * 0.9
    else
        Shake = Shake - 1
    end
    if Shake < 0 then
        Shake = 0
    end
end

function LoadHighScore()
    if WebMode == false then
        local info = love.filesystem.getInfo("score.txt","file")
        if info ~= nil then
            local contents, size = love.filesystem.read("string", "score.txt", info.size)
            if size > 0 then
                HighScore = tonumber(contents)
            end
        end
    else
        HighScore = 0
    end
end

function SaveHighScore()
    if WebMode == false then
        local data = tostring(HighScore)
        love.filesystem.write("score.txt", data, #data)
    end
end