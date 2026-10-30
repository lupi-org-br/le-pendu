-- Adaptador de input para Lupi/Lupinho
-- Mantém o restante do jogo independente da API de controle.

local Input = {}
local BTN = require("btn")

-- Estados dos jogadores.
-- O Lupi utiliza índices de jogador começando em 0.
local pad_states = {
    [0] = {},
    [1] = {},
    [2] = {}
}

function Input.init()
    for i = 0, 2 do
        pad_states[i] = {}
    end
end

function Input.update(frame)
    for i = 0, 2 do
        pad_states[i].Z = ui.btn(BTN.Z, i) ~= false
        pad_states[i].UP = ui.btn(BTN.UP, i) ~= false
        pad_states[i].DOWN = ui.btn(BTN.DOWN, i) ~= false
        pad_states[i].LEFT = ui.btn(BTN.LEFT, i) ~= false
        pad_states[i].RIGHT = ui.btn(BTN.RIGHT, i) ~= false
    end
end

local ACTION_BUTTONS = {
    left = BTN.LEFT,
    right = BTN.RIGHT,
    up = BTN.UP,
    down = BTN.DOWN,
    confirm = BTN.Z
}

function Input.is_action(action, player_idx)
    local key = string.lower(action)
    local button = ACTION_BUTTONS[key]

    if button == nil then
        return false
    end

    local player = player_idx or 0

    return ui.btn(button, player) ~= false
end

function Input.is_action_pressed(action, player_idx)
    local key = string.lower(action)
    local button = ACTION_BUTTONS[key]

    if button == nil then
        return false
    end

    if player_idx ~= nil then
        return ui.btnp(button, player_idx) ~= false
    end

    return ui.btnp(button) ~= false
end

return Input
