collectgarbage("generational")

Director = require "director"
Helpers = require "helpers"
require "palette"
require "sprites"
require "skull"
require "letters"
require "bg"
require "database"

Frame = 0
Game = {
    state = "playing" -- "playing", "won", "lost", "fading_out"
}

Game.skull = MakeSkull(Game, 66, 56)
Game.letters = MakeLetters(Game, 290, 52)
Game.bg = MakeBackground(Game, 0, 0)

Director.fade_in(30)

-- sfx.music("sneaky")

function update()
    Frame = Frame + 1
    Director.update()

    ui.cls(1)
    ui.clip(0, 0, 480, 270)

    local brightness = Director.get_brightness()
    for i = 1, #Palette do
        local color = Palette[i]
        local r = color & 0x1F
        local g = (color & 0x3E0) >> 5
        local b = (color & 0x7C00) >> 10

        r = math.floor(r * brightness)
        g = math.floor(g * brightness)
        b = math.floor(b * brightness)

        ui.palset(i - 1, r | (g << 5) | (b << 10))
    end
    
    Game.bg.draw(Frame)
    Game.skull.draw(Frame)
    Game.letters.draw(Frame)

    local input_char = ui.readtext()

    if Game.state == "playing" then
        if input_char then
            Game.letters.try_letter(input_char, Frame)
        end

        if Game.letters.is_word_guessed() then
            Game.state = "won"
            Game.state_start_frame = Frame
        elseif Game.letters.is_game_over() then
            Game.state = "lost"
            Game.state_start_frame = Frame
        end

    elseif Game.state == "won" or Game.state == "lost" then
        local elapsed = Frame - (Game.state_start_frame or Frame)
        local ease = Helpers.ease_out_cubic(elapsed / 25)

        local title_y = math.floor(-30 + (10 - (-30)) * ease)
        local sub_y = math.floor(285 - (285 - 250) * ease)

        if Game.state == "won" then
            Helpers.print_sine_centered("ACERTOU!", title_y, Frame, Palette.hex(0x6098f8), Palette.hex(0x201818))
            Helpers.print_centered("Pressione qualquer tecla para jogar de novo", sub_y, Palette.hex(0xf8f8f8), Palette.hex(0x0000))
        else
            Helpers.print_sine_centered("OPS! ERROU!", title_y, Frame, Palette.hex(0xd85060), Palette.hex(0x201818))
            Helpers.print_centered("Pressione qualquer tecla para tentar de novo", sub_y, Palette.hex(0xf8f8f8), Palette.hex(0x0000))
        end

        if input_char or ui.btnp(BTN_Z) or ui.btnp(BTN_X) then
            Director.fade_out(30)
            Game.state = "fading_out"
        end

    elseif Game.state == "fading_out" then
        if not Director.is_fading() then
            Game.letters.reset()
            Game.skull.reset()
            Director.fade_in(30)
            Game.state = "playing"
        end
    end
end