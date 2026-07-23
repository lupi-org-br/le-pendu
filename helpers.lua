local Helpers = {}

Helpers.char_widths = {
    [" "] = 3, ["!"] = 5, ['"'] = 4, ["#"] = 8, ["$"] = 5, ["%"] = 7, ["&"] = 7, ["'"] = 3,
    ["("] = 4, [")"] = 4, ["*"] = 6, ["+"] = 6, [","] = 3, ["-"] = 6, ["."] = 3, ["/"] = 4,
    ["0"] = 6, ["1"] = 4, ["2"] = 6, ["3"] = 6, ["4"] = 6, ["5"] = 6, ["6"] = 6, ["7"] = 6,
    ["8"] = 6, ["9"] = 6, [":"] = 3, [";"] = 3, ["<"] = 5, ["="] = 5, [">"] = 4, ["?"] = 6,
    ["@"] = 9, ["A"] = 6, ["B"] = 6, ["C"] = 6, ["D"] = 6, ["E"] = 6, ["F"] = 6, ["G"] = 6,
    ["H"] = 6, ["I"] = 3, ["J"] = 5, ["K"] = 7, ["L"] = 5, ["M"] = 8, ["N"] = 7, ["O"] = 7,
    ["P"] = 6, ["Q"] = 7, ["R"] = 6, ["S"] = 5, ["T"] = 7, ["U"] = 6, ["V"] = 7, ["W"] = 7,
    ["X"] = 8, ["Y"] = 7, ["Z"] = 6, ["["] = 4, ["\\"] = 4, ["]"] = 4, ["^"] = 4, ["_"] = 6,
    ["`"] = 4, ["a"] = 6, ["b"] = 6, ["c"] = 5, ["d"] = 6, ["e"] = 6, ["f"] = 4, ["g"] = 6,
    ["h"] = 6, ["i"] = 3, ["j"] = 4, ["k"] = 6, ["l"] = 3, ["m"] = 9, ["n"] = 6, ["o"] = 6,
    ["p"] = 6, ["q"] = 6, ["r"] = 5, ["s"] = 5, ["t"] = 4, ["u"] = 6, ["v"] = 6, ["w"] = 6,
    ["x"] = 8, ["y"] = 6, ["z"] = 6, ["{"] = 6, ["|"] = 3, ["}"] = 6, ["~"] = 5
}

Helpers.get_char_width = function(char)
    return Helpers.char_widths[char] or 6
end

Helpers.get_text_width = function(text)
    local width = 0
    for i = 1, #text do
        local c = text:sub(i, i)
        width = width + Helpers.get_char_width(c)
    end
    return width
end

Helpers.print_centered = function(text, y, color_fg, color_shadow, screen_width)
    screen_width = screen_width or 480
    local text_w = Helpers.get_text_width(text)
    local x = math.floor((screen_width - text_w) / 2)
    if color_shadow then
        ui.print(text, x + 1, y + 1, color_shadow)
    end
    ui.print(text, x, y, color_fg)
    return x
end

return Helpers
