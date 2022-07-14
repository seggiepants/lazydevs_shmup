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