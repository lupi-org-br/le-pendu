function MakeBackground(game, x, y)
    local bgmap = require("sprites.bgmap")
    local bg = {
        x = x,
        y = y,
        fg_frame = 0,
        fg_sprite = 1
    }

    local function foreground_sprite_name()
        bg.fg_frame = bg.fg_frame + 1

        if (bg.fg_frame > 200 and math.random(1,100) == 1) then
            bg.fg_sprite = math.random(2,3)
            bg.fg_frame = 0
        end

        if bg.fg_frame < 20 then return "arbusto" .. bg.fg_sprite
        else return "arbusto1" end
    end

    local function draw_cloud(x, y, frame)
        local offset = math.sin(frame / 200)
        ui.rectfill(x + 0, y + 9, x + 480, y + 20, 52)

        for i = 0, 38 do
            local t = i / 38
            local d = (1 - (2*t - 1)^2) * 20
            ui.circfill(x + 14 * i + offset * d, y + 34 - d, 16 - (i%3)*2, Palette.hex(0x302840))
        end

        offset = math.sin(frame / 100)
        ui.rectfill(x + 0, x + 0, x + 480, y + 10, Palette.hex(0x383050))

        for i = 0, 26 do
            local t = i / 26
            local d = (1 - (2*t - 1)^2) * 20
            ui.circfill(x + 20 * i + offset * d, y + 20 - d, 18 - (i%4)*2, Palette.hex(0x383050))
        end
    end

    bg.draw = function(frame)
        ui.map(bgmap.bg1, bg.x, bg.y)
        draw_cloud(0, 20, frame)
        ui.spr(Sprites.sprites.tree, 0, 32)
        ui.spr(Sprites.sprites[foreground_sprite_name()], 352, 190)
    end
    
    return bg
end