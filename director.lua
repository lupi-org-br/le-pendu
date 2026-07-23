local M = {}

M.brightness = 0
M.brightness_target = 1
M.fade_remaining = 30

M.init = function()
    M.brightness = 0
    M.brightness_target = 1
    M.fade_remaining = 30
end

M.update = function()
    if M.fade_remaining > 0 then
        local step = (M.brightness_target - M.brightness) / M.fade_remaining
        M.brightness = M.brightness + step
        M.fade_remaining = M.fade_remaining - 1
    else
        M.brightness = M.brightness_target
    end
end

M.get_brightness = function()
    return math.max(0, math.min(1, M.brightness))
end

M.fade_in = function(frames)
    M.brightness_target = 1
    M.fade_remaining = frames or 30
end

M.fade_out = function(frames)
    M.brightness_target = 0
    M.fade_remaining = frames or 30
end

M.is_fading = function()
    return M.fade_remaining > 0
end

return M
