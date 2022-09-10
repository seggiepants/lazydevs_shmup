function love.conf(t)
    ScreenW = 128
    ScreenH = 128
    ScreenScale = 4

    t.window.width = ScreenW * ScreenScale
    t.window.height = ScreenH * ScreenScale
    t.console = false
    t.audio.mic = false
    t.window.title = "My Awesome Shmup"
    t.window.resizable = false
    t.window.borderless = false
    t.window.vsync = 1
    t.modules.physics = false
    t.modules.video = false
end