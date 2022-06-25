function drawStarfield()
    for key, star in ipairs(stars) do
        pset(star.x, star.y, star.clr)
    end
end

function pset(x, y, clr)
    -- love.graphics.points doesn't scale up properly so I am drawing rectangles.
    love.graphics.setColor(pal[clr])
    love.graphics.rectangle("fill", x, y, 1, 1)
end

function spr(id, x, y)
    love.graphics.setColor(white)
    love.graphics.draw(img, quads[id], x, y)
end