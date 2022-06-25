function updateStarfield()
    for key, star in ipairs(stars) do
        star.y = star.y + star.spd
        if star.y >= screenH then
            star.x = love.math.random(screenW)
            star.y = star.y - screenH - tileSize
        end
    end
end
