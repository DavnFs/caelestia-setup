-- Personal overrides, loaded after the Caelestia defaults

-- Smooth cubic deceleration curve without long sub-pixel tail
hl.curve("smoothDecel", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

-- Precision render scheduling closer to vblank
hl.config({
    render = {
        new_render_scheduling = true,
    },
    decoration = {
        dim_inactive = true,
        dim_strength = 0.08,
    },
})

-- Buttery smooth window, workspace and layer animations
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.5, bezier = "smoothDecel", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "emphasizedAccel", style = "popin 95%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "smoothDecel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.5, bezier = "smoothDecel", style = "slidefade 15%" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4.5, bezier = "smoothDecel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "emphasizedAccel", style = "slide" })

-- Auto-maximize application windows on launch (monocle mode)
hl.window_rule({
    name             = "auto-maximize",
    match            = { float = false },
    fullscreen_state = "1 0",
})
