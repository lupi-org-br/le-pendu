# Lupi Game API Reference

## System Overview
- Resolution: 480x270 pixels (16:9 widescreen)
- Color: 256-color indexed palette (RGB555 format)
- Frame rate: 60 FPS target
- Main callback: `update(frame)` - called 60 times per second with frame number
- **Important:** Palette must be registered each frame using `ui.palset(index, color)`

## Global Constants
- `LEFT`, `RIGHT`, `UP`, `DOWN` - Directional buttons (0-3)
- `BTN_Z`, `BTN_X` - Action buttons (4-5)
- `BTN_F`, `BTN_G` - Secondary action buttons (12-13)
- `BTN_Q`, `BTN_E` - Shoulder buttons (14-15)
- `ALIGN_START`, `ALIGN_CENTER`, `ALIGN_END` - Layout alignment
- `LEFT_TO_RIGHT`, `TOP_TO_BOTTOM` - Layout direction

## Graphics API (ui.*)

### Screen
- `ui.cls([color])` - Clear screen with color (default: 1)
- `ui.clip([x, y, w, h])` - Set/reset clipping region
- `ui.camera([x, y])` - Set/reset camera offset for drawing

### Primitives
- `ui.rect(x0, y0, x1, y1, color)` - Draw rectangle outline
- `ui.rectfill(x0, y0, x1, y1, color)` - Draw filled rectangle
- `ui.circ(x, y, radius, color)` - Draw circle outline
- `ui.circfill(x, y, radius, color)` - Draw filled circle
- `ui.line(x0, y0, x1, y1, color)` - Draw line
- `ui.trisfill(x1, y1, x2, y2, x3, y3, color)` - Draw filled triangle
- `ui.grid(x, y, cell_w, cell_h, data)` - Draw pixel grid from 2D table

### Sprites & Maps
- `ui.spr(sprite_ref, x, y, [flip_x], [flip_y])` - Draw sprite (tile 0)
- `ui.tile(sprite_ref, tile_id, x, y, [flip_x], [flip_y])` - Draw specific tile (0-1023)
- `ui.map(map_data, cam_x, cam_y)` - Draw map with camera offset

### Text
- `ui.print(text, x, y, color)` - Draw text string

### Palette & Patterns
- `ui.palset(index, color)` - Set palette color (index 0-255, color RGB555)
- `ui.fillp([b0, b1, b2, b3, b4, b5, b6, b7])` - Set fill pattern (8 bytes) or reset

### Utility
- `ui.mid(a, b, c)` - Return middle value (useful for clamping)
- `ui.stat(option)` - Get system stats: 0=memory, 1=CPU, 7=FPS

## Input API

### Gamepad
- `ui.btn(button_id, [player])` - Check if button held (returns false or pressure 0-255)
- `ui.btnp(button_id, [player])` - Check if button just pressed (edge detection)
- Player index: 0-2 (default: 0)

### Mouse
- `ui.mouse()` - Returns: x, y, buttons, wheel_x, wheel_y
- buttons bitfield: bit 0 = left, bit 1 = right

### Keyboard
- `ui.peektext()` - Peek next char without removing (returns string or nil)
- `ui.readtext()` - Read and remove next char (returns string or nil)

## Audio API (sfx.*)

- `sfx.music(music_name)` - Play music file (string), use -1 to stop
- `sfx.fx(sample_id, midi_note, [pan])` - Play sound effect (pan: 0.0-1.0, default 0.5)
- `sfx.volume(vol)` - Set global volume (0.0-1.0)

## Layout API (Clay)

### Main Function
- `ui.layout(root_node)` - Render layout tree (call in _draw)

### Elements
- `Box()` - Container element (like div)
- `Text()` - Text element
- `Image(sprite_ref)` - Image element
- `Custom(callback)` - Custom drawing callback

### Builder Methods (chainable)
- `.size.width.set.fixed(px)` / `.set.percentage(0.0-1.0)` / `.set.grow()` / `.set.fit()`
- `.size.height.set.fixed(px)` / `.set.percentage(0.0-1.0)` / `.set.grow()` / `.set.fit()`
- `.padding.set.all(px)` / `.set(x, y)`
- `.gap.set(px)` - Space between children
- `.alignment.horizontal.set(ALIGN_START|ALIGN_CENTER|ALIGN_END)`
- `.alignment.vertical.set(ALIGN_START|ALIGN_CENTER|ALIGN_END)`
- `.set.direction(LEFT_TO_RIGHT|TOP_TO_BOTTOM)`
- `.color.set(palette_index)` - Background color
- `.corner.set.radius(px)` - Rounded corners
- `.add.child(node)` - Add child element
- `.set.visible(bool)` - Show/hide

### Text-specific
- `.content(string)` - Set text content
- `.letter_spacing.set(px)` - Letter spacing
- `.line_height.set(px)` - Line height

### Custom-specific
- Callback receives: x, y, width, height

## Example Game Loop

```lua
-- Define palette (RGB555 colors, indices 0-99)
Palette = {
    0x0000, 0x0000, 0x0022, 0x02FF, 0x6FF7, 0x7EE7, 0x0001, 0x5FF7,
    0x2D00, 0x01F5, 0x3F7F, 0x2108, 0x5B5E, 0x4620, 0x00CA, 0x3DEF,
    -- ... add more colors as needed
}

-- Initialize game state (runs once when script loads)
player = { x = 240, y = 135 }

function update(frame)
    -- Register palette colors (required each frame)
    for i = 1, #Palette do
        ui.palset(i - 1, Palette[i])
    end
    
    -- Input handling
    if ui.btn(LEFT) then player.x = player.x - 2 end
    if ui.btn(RIGHT) then player.x = player.x + 2 end
    if ui.btn(UP) then player.y = player.y - 2 end
    if ui.btn(DOWN) then player.y = player.y + 2 end
    
    -- Clamp to screen
    player.x = ui.mid(0, player.x, 480)
    player.y = ui.mid(0, player.y, 270)
    
    -- Drawing
    ui.cls(1)  -- Clear with color 1
    ui.circfill(player.x, player.y, 8, 7)  -- Draw player
    ui.print("Frame: " .. frame, 10, 10, 7)
end
```