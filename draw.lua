function drawStarfield()
    for key, star in ipairs(stars) do
        local clr = 8

        if star.spd < 1 then
            clr = 2
        elseif star.spd < 1.25 then
            clr = 14
        elseif star.spd < 1.5 then
            clr = 7
        end
        
        if star.spd < 1.5 then
            pset(star.x, star.y, clr)
        else
            line(star.x, star.y - 3, star.x, star.y, 6)
            line(star.x, star.y - 1, star.x, star.y, clr)
        end
    end
end

function line(x1, y1, x2, y2, clr)
    love.graphics.setColor(pal[clr])
    love.graphics.line(x1, y1, x2, y2)
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