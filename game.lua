package.path = '/sdb/apps/pendu/?.lua;'
collectgarbage("generational")

require "palette"
require "sprites"
require "skull"
require "letters"
require "bg"
require "database"

Frame = 0
Game = {}

Game.skull = MakeSkull(Game, 66, 56)
Game.letters = MakeLetters(Game, 290, 52)
Game.bg = MakeBackground(Game, 0, 0)

sfx.music("sneaky")

function update()
    Frame = Frame + 1
    ui.cls(1)
    ui.clip(0, 0, 480, 270)

    for i = 1, #Palette do
        local color = Palette[i]
        ui.palset(i - 1, color)
    end
    
    Game.bg.draw(Frame)
    Game.skull.draw(Frame)
    Game.letters.draw(Frame)

    local c = ui.readtext()
    if c then Game.letters.try_letter(c, Frame) end
end 