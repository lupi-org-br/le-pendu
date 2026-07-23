local kBodyPart = {
    head = 1,
    torso = 2,
    left_arm = 3,
    right_arm = 4,
    left_forearm = 5,
    right_forearm = 6,
    left_leg = 7,
    right_leg = 8,
    left_foot = 9,
    right_foot = 10,
}

function MakeSkull(game,x,y)
    local sk = { 
        x = x,
        y = y,
        ctx = {},
        bodyparts = 10
    }

    for i = 1, sk.bodyparts do
        sk.ctx[i] = {
            taken = false,
            cx = 0,
            cy = 0
        }
    end

    local function _count_taken()
        local count = 0
        for i = 1, sk.bodyparts do
            if sk.ctx[i].taken then count = count + 1 end
        end
        return count
    end
    
    local _compute_acel = function(ctx)
        if _count_taken() < sk.bodyparts then
            return
        end

        if not ctx.ax then 
            ctx.cx = 0
            ctx.cy = 0
            ctx.ax = math.random(-10, 10) / 10
            ctx.ay = math.random(-30, -10) / 10
        end

        ctx.cx = ctx.cx + ctx.ax
        ctx.cy = ctx.cy + ctx.ay
        ctx.ay = ctx.ay + 0.08

        if ctx.cy > 272 then
            ctx.cy = 272
            ctx.cx = 0
        end
    end

    sk.add_one_more_bodypart = function()
        
        for i = 1, sk.bodyparts do
            if not sk.ctx[i].taken then
                sk.ctx[i].taken = true
                return true
            end 
        end

        return false
    end

    sk.draw = function(frame)

        local bodypart_lookup = {
            [kBodyPart.head] = function(ctx)
                local d = math.sin(ctx.cy / 20) * 1
                ui.tile(SpriteSheets.caveira, 20, sk.x + d, sk.y - 4)
                
                if not ctx.taken then return end
                _compute_acel(ctx)
                if not ctx.random_sprite then  ctx.random_sprite = math.random(1, 5) end
                ui.tile(SpriteSheets.caveira, ctx.random_sprite, sk.x + ctx.cx, sk.y + ctx.cy)
            end,
            [kBodyPart.torso] = function(ctx)
                if not ctx.taken then return end
                _compute_acel(ctx)
                ui.tile(SpriteSheets.caveira, 7, sk.x + ctx.cx, sk.y + 20 + ctx.cy)
                ui.tile(SpriteSheets.caveira, 10, sk.x + ctx.cx, sk.y + 52 + ctx.cy)
            end,
            [kBodyPart.left_arm] = function(ctx)
                if not ctx.taken then return end
                _compute_acel(ctx)
                ui.tile(SpriteSheets.caveira, 6, sk.x - 17 + ctx.cx, sk.y + 24 + ctx.cy)
            end,
            [kBodyPart.right_arm] = function(ctx)
                if not ctx.taken then return end
                _compute_acel(ctx)
                ui.tile(SpriteSheets.caveira, 8, sk.x + 17 + ctx.cx, sk.y + 24 + ctx.cy)
            end,
            [kBodyPart.left_forearm] = function(ctx)
                if not ctx.taken then return end
                _compute_acel(ctx)
                ui.tile(SpriteSheets.caveira, 9, sk.x - 18 + ctx.cx, sk.y + 49 + ctx.cy)
            end,
            [kBodyPart.right_forearm] = function(ctx)
                if not ctx.taken then return end
                _compute_acel(ctx)
                ui.tile(SpriteSheets.caveira, 11, sk.x + 17 + ctx.cx, sk.y + 49 + ctx.cy)
            end,
            [kBodyPart.left_leg] = function(ctx)
                if not ctx.taken then return end
                _compute_acel(ctx)
                ui.tile(SpriteSheets.caveira, 12, sk.x - 8 + ctx.cx, sk.y + 60 + ctx.cy)
            end,
            [kBodyPart.right_leg] = function(ctx)
                if not ctx.taken then return end
                _compute_acel(ctx)
                ui.tile(SpriteSheets.caveira, 13, sk.x + 8 + ctx.cx, sk.y + 60 + ctx.cy)
            end,
            [kBodyPart.left_foot] = function(ctx)
                if not ctx.taken then return end
                _compute_acel(ctx)
                ui.tile(SpriteSheets.caveira, 15, sk.x - 11 + ctx.cx, sk.y + 85 + ctx.cy)
                ui.tile(SpriteSheets.caveira, 18, sk.x - 12 + ctx.cx, sk.y + 105 + ctx.cy)
            end,
            [kBodyPart.right_foot] = function(ctx)
                if not ctx.taken then return end
                _compute_acel(ctx)
                ui.tile(SpriteSheets.caveira, 16, sk.x + 11 + ctx.cx, sk.y + 85 + ctx.cy)
                ui.tile(SpriteSheets.caveira, 19, sk.x + 12 + ctx.cx, sk.y + 105 + ctx.cy)
            end,
        }

        bodypart_lookup[kBodyPart.left_forearm](sk.ctx[kBodyPart.left_forearm])
        bodypart_lookup[kBodyPart.right_forearm](sk.ctx[kBodyPart.right_forearm])
        bodypart_lookup[kBodyPart.left_arm](sk.ctx[kBodyPart.left_arm])
        bodypart_lookup[kBodyPart.right_arm](sk.ctx[kBodyPart.right_arm])
        bodypart_lookup[kBodyPart.left_foot](sk.ctx[kBodyPart.left_foot])
        bodypart_lookup[kBodyPart.right_foot](sk.ctx[kBodyPart.right_foot])
        bodypart_lookup[kBodyPart.left_leg](sk.ctx[kBodyPart.left_leg])
        bodypart_lookup[kBodyPart.right_leg](sk.ctx[kBodyPart.right_leg])
        bodypart_lookup[kBodyPart.torso](sk.ctx[kBodyPart.torso])
        bodypart_lookup[kBodyPart.head](sk.ctx[kBodyPart.head])
    end

    return sk
end