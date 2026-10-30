
collectgarbage("generational")

Director = require("director")
Helpers = require("helpers")
local BTN = require("btn")

require("palette")
require("sprites")
require("skull")
require("letters")
require("bg")
require("database")

Frame = 0

Game = {
    state = "playing",
    keyboard = {
        letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        selected = 1,
        used = {}
    }
}

Game.skull = MakeSkull(Game, 66, 56)
Game.letters = MakeLetters(Game, 290, 52)
Game.bg = MakeBackground(Game, 0, 0)

local KEYBOARD = {
    y = 184,
    key_width = 22,
    key_height = 16,
    gap = 2,
    rows = {
        {1, 9},
        {10, 18},
        {19, 26}
    }
}

local KEY_REPEAT_DELAY = 15
local KEY_REPEAT_INTERVAL = 5

local navigation = {
    direction = nil,
    held_frames = 0
}

local function is_available(index)
    local letter = Game.keyboard.letters:sub(index, index)
    return letter ~= "" and not Game.keyboard.used[letter]
end

local function find_available(start, step, limit)
    local index = start

    for _ = 1, limit do
        index = ((index - 1 + step) % limit) + 1

        if is_available(index) then
            return index
        end
    end

    return nil
end

local function get_row(index)
    for row_index, row in ipairs(KEYBOARD.rows) do
        if index >= row[1] and index <= row[2] then
            return row_index
        end
    end

    return nil
end

local function move_horizontal(direction)
    local selected = Game.keyboard.selected
    local row_index = get_row(selected)
    local row = KEYBOARD.rows[row_index]
    local first = row[1]
    local last = row[2]
    local count = last - first + 1
    local column = selected - first + 1

    for _ = 1, count - 1 do
        column = ((column - 1 + direction) % count) + 1

        local index = first + column - 1

        if is_available(index) then
            Game.keyboard.selected = index
            return
        end
    end
end

local function move_vertical(direction)
    local selected = Game.keyboard.selected
    local row_index = get_row(selected)
    local current_row = KEYBOARD.rows[row_index]
    local column = selected - current_row[1] + 1

    for _ = 1, #KEYBOARD.rows - 1 do
        row_index = ((row_index - 1 + direction) % #KEYBOARD.rows) + 1

        local row = KEYBOARD.rows[row_index]
        local row_count = row[2] - row[1] + 1
        local target_column = math.min(column, row_count)
        local index = row[1] + target_column - 1

        if is_available(index) then
            Game.keyboard.selected = index
            return
        end

        for offset = 1, row_count - 1 do
            local right_index = row[1]
                + ((target_column - 1 + offset) % row_count)

            if is_available(right_index) then
                Game.keyboard.selected = right_index
                return
            end

            local left_index = row[1]
                + ((target_column - 1 - offset) % row_count)

            if is_available(left_index) then
                Game.keyboard.selected = left_index
                return
            end
        end
    end
end

local function update_navigation()
    local directions = {
        {name = "left", button = BTN.LEFT, move = function()
            move_horizontal(-1)
        end},
        {name = "right", button = BTN.RIGHT, move = function()
            move_horizontal(1)
        end},
        {name = "up", button = BTN.UP, move = function()
            move_vertical(-1)
        end},
        {name = "down", button = BTN.DOWN, move = function()
            move_vertical(1)
        end}
    }

    local active_direction = nil

    for _, direction in ipairs(directions) do
        if ui.btn(direction.button) then
            active_direction = direction
            break
        end
    end

    if not active_direction then
        navigation.direction = nil
        navigation.held_frames = 0
        return
    end

    if navigation.direction ~= active_direction.name then
        navigation.direction = active_direction.name
        navigation.held_frames = 0
        active_direction.move()
        return
    end

    navigation.held_frames = navigation.held_frames + 1

    if navigation.held_frames >= KEY_REPEAT_DELAY
        and (navigation.held_frames - KEY_REPEAT_DELAY)
            % KEY_REPEAT_INTERVAL == 0 then
        active_direction.move()
    end
end

local function update_keyboard()
    update_navigation()

    if ui.btnp(BTN.Z) then
        local selected = Game.keyboard.selected
        local letter = Game.keyboard.letters:sub(selected, selected)

        if is_available(selected) then
            Game.keyboard.used[letter] = true
            Game.letters.try_letter(letter, Frame)

            local next_index = find_available(
                selected,
                1,
                #Game.keyboard.letters
            )

            if next_index then
                Game.keyboard.selected = next_index
            end
        end
    end
end

local function draw_keyboard()
    local letters = Game.keyboard.letters

    for row_index, row in ipairs(KEYBOARD.rows) do
        local first = row[1]
        local last = row[2]

        local row_width = (last - first + 1)
            * (KEYBOARD.key_width + KEYBOARD.gap)
            - KEYBOARD.gap

        local start_x = math.floor(
            (480 - row_width) / 2
        ) + 110

        local y = KEYBOARD.y
            + (row_index - 1)
            * (KEYBOARD.key_height + KEYBOARD.gap)

        for index = first, last do
            local column = index - first

            local x = start_x
                + column
                * (KEYBOARD.key_width + KEYBOARD.gap)

            local letter = letters:sub(index, index)
            local selected = index == Game.keyboard.selected
            local used = Game.keyboard.used[letter]

            local background = 0x2108
            local foreground = 0x7FFF
            local border = 0x6C1F

            if used then
                background = 0x1004
                foreground = 0x4210
                border = 0x2108
            elseif selected then
                background = 0x6C1F
                foreground = 0x0000
                border = 0x7FFF
            end

            ui.rectfill(
                x,
                y,
                x + KEYBOARD.key_width,
                y + KEYBOARD.key_height,
                background
            )

            ui.rect(
                x,
                y,
                x + KEYBOARD.key_width,
                y + KEYBOARD.key_height,
                border
            )

            ui.print(
                letter,
                x + 8,
                y + 5,
                foreground
            )
        end
    end

    ui.print(
        "SETAS: MOVER   Z: CONFIRMAR",
        160,
        246,
        0x5117
    )
end

local function draw_palette(brightness)
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
end

local function reset_game()
    Game.letters.reset()
    Game.skull.reset()

    Game.keyboard.selected = 1
    Game.keyboard.used = {}
    navigation.direction = nil
    navigation.held_frames = 0

    Director.fade_in(30)
    Game.state = "playing"
end

Director.fade_in(30)

function update()
    Frame = Frame + 1
    Director.update()

    ui.cls(1)
    ui.clip(0, 0, 480, 270)

    draw_palette(Director.get_brightness())

    Game.bg.draw(Frame)
    Game.skull.draw(Frame)
    Game.letters.draw(Frame)

    if Game.state == "playing" then
        update_keyboard()
        draw_keyboard()

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

        local title_y = math.floor(-30 + 40 * ease)
        local sub_y = math.floor(285 - 35 * ease)

        if Game.state == "won" then
            Helpers.print_sine_centered(
                "ACERTOU!",
                title_y,
                Frame,
                0x7FCD,
                0x313F
            )

            Helpers.print_centered(
                "APERTE Z PARA JOGAR DE NOVO",
                sub_y,
                0x7E80,
                0x313F
            )
        else
            Helpers.print_sine_centered(
                "OPS! ERROU!",
                title_y,
                Frame,
                0x7E80,
                0x313F
            )

            Helpers.print_centered(
                "APERTE Z PARA TENTAR DE NOVO",
                sub_y,
                0x7E80,
                0x313F
            )
        end

        if ui.btnp(BTN.Z) or ui.btnp(BTN.X) then
            Director.fade_out(30)
            Game.state = "fading_out"
        end

    elseif Game.state == "fading_out" then
        if not Director.is_fading() then
            reset_game()
        end
    end
end
