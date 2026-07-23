function MakeLetters(Game,x,y)

    local current_db_index = 34 + 28
    local debug = true
    local word, hints = nil, nil
    local letters_right = {}
    local letters_wrong = {}
    local letters_wrong_timming = {}
    local hints_timming = {}
    local lt = {
        x = x,
        y = y
    }

    local function _get_word_from_db()
        local db = Database
        if debug then
            return db[current_db_index].word, db[current_db_index].hints 
        end 
        
        math.randomseed(os.time() + Frame)
        current_db_index = math.random(1, #db)
        return db[current_db_index].word, db[current_db_index].hints
    end

    lt.try_letter = function(letter, frame)
        letter = string.upper(letter)
        if #letter ~= 1 then return end
        if letter < 'A' or letter > 'Z' then return end

        local guessed = letters_right
        local wrong = letters_wrong

        for i = 1, #word do
            if word:sub(i,i) == letter then
                for j = 1, #guessed do
                    if guessed[j] == letter then return end
                end
                table.insert(letters_right, letter)
                return
            end
        end

        for j = 1, #wrong do
            if wrong[j] == letter then return end
        end

        table.insert(letters_wrong, letter)
        letters_wrong_timming[letter] = frame
        Game.skull.add_one_more_bodypart()
    end

    local function _update_hints_timming(y, frame)
        if hints_timming[y] == nil then 
            hints_timming[y] = {frame, 0}
        end
        
        local total_x_change = 210
        local total_frames   = 60
        local start_frame   = hints_timming[y][1]
        local end_frame     = start_frame + total_frames
        local completion    = (frame - start_frame) / total_frames

        -- clamp completion between 0 and 1
        if completion < 0 then completion = 0 end
        if completion > 1 then completion = 1 end

        local function strong_ease_out(t)
            return 1 - (1 - t) * (1 - t) * (1 - t)
        end

        local dx = math.floor(strong_ease_out(completion) * total_x_change)
        hints_timming[y][2] = total_x_change -  dx
    end 

    local function _draw_hints_bg(y, frame)
        local dx = hints_timming[y] and hints_timming[y][2] or 120
        ui.tile(Sprites.sprites.dicas, 0, dx + lt.x - 7, lt.y + 72 + y * 20)
        for x = 1, 9 do
            ui.tile(Sprites.sprites.dicas, 1, dx + lt.x - 7 + x * 16, lt.y + 72 + y * 20)
        end
        ui.tile(Sprites.sprites.dicas, 2, dx + lt.x - 7 + 10 * 16, lt.y + 72 + y * 20)
    end

    local function _draw_hints(frame)

        if debug and ui.btnp(BTN_E, 2) then 
            current_db_index = current_db_index + 1
            word, hints = _get_word_from_db()
        end 

        if debug and ui.btnp(BTN_Q, 2) then 
            current_db_index = current_db_index - 1
            word, hints = _get_word_from_db()
        end

        if debug or #letters_wrong >= 3 then 
            _update_hints_timming(0, frame)
            _draw_hints_bg(0, frame)
        end
        
        if debug or #letters_wrong >= 6 then 
            _update_hints_timming(1, frame)
            _draw_hints_bg(1, frame)
        end
        
        if debug or #letters_wrong >= 9 then
            _update_hints_timming(2, frame)
            _draw_hints_bg(2, frame)
        end

        if debug or #letters_wrong >= 3 then
            local dx = hints_timming[0][2]
            ui.print(hints[1], dx + lt.x + 5, lt.y + 73, Palette.hex(0x807880))
            ui.print(hints[1], dx + lt.x + 5, lt.y + 74, Palette.hex(0xf8f8f8))
        end

        if debug or #letters_wrong >= 6 then
            local dx = hints_timming[1][2]
            ui.print(hints[2], dx + lt.x + 5, lt.y + 93, Palette.hex(0x807880))
            ui.print(hints[2], dx + lt.x + 5, lt.y + 94, Palette.hex(0xf8f8f8))
        end

        if debug or #letters_wrong >= 9 then
            local dx = hints_timming[2][2]
            ui.print(hints[3], dx + lt.x + 5, lt.y + 113, Palette.hex(0x807880))
            ui.print(hints[3], dx + lt.x + 5, lt.y + 114, Palette.hex(0xf8f8f8))
        end
    end

    local function is_guessed(char)
        local guessed = letters_right
        for i = 1, #guessed do
            if guessed[i] == char then return true end
        end
        return false
    end

    lt.draw = function(frame)

        if not word then 
            word, hints = _get_word_from_db()
        end

        for ly = 0, 1 do 
            for lx = 0, 4 do
                if not letters_wrong[lx+1+ly*5] then
                    ui.circfill(lt.x + 16 + 32 * lx, lt.y + 16 + 32 * ly, 6, Palette.hex(0x607088))
                end
            end
        end

        for ly = 0, 1 do 
            for lx = 0, 4 do
                if letters_wrong[lx+1+ly*5] then
                    local time_since_wrong = frame - letters_wrong_timming[letters_wrong[lx+1+ly*5]]
                    local sprite_frame = math.floor(time_since_wrong / 2)
                    if sprite_frame > 2 then sprite_frame = 2 end
                    ui.tile(Sprites.sprites.bgletras, sprite_frame + ly * 3,
                    lt.x + 32 * lx, lt.y + 32 * ly)
                end
            end
        end

        for ly = 0, 1 do 
            for lx = 0, 4 do
                if letters_wrong[lx+1+ly*5] then
                    ui.print(letters_wrong[lx+1+ly*5],
                    lt.x + 12 + 32 * lx, lt.y + 11  + 32 * ly, Palette.hex(0xf8f8f8))
                end
            end
        end 

        for i = 1, #word do
            local char = word:sub(i, i)
            local char_code = string.byte(char)
            local sprite_index = char_code - string.byte('A')
            
            local text_width = #word * 16
            local text_start = 480 / 2 - text_width / 2
            if is_guessed(char) then
                ui.tile(Sprites.sprites.letras, sprite_index, text_start + (i - 1) * 16, 216)
                ui.tile(Sprites.sprites.letras, 26, text_start + (i - 1) * 16, 216+8)
            else 
                ui.tile(Sprites.sprites.letras, 27, text_start + (i - 1) * 16, 216+8)
            end 
        end

        _draw_hints(frame)
    end
    
    return lt
end