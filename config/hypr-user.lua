-- Personal overrides, loaded after the Caelestia defaults

-- Windows zoom in from 90% while fading in, and shrink slightly as they close (macOS-like)
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "emphasizedDecel", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "emphasizedAccel", style = "popin 95%" })

-- Short slide plus fade between workspaces, matching the special workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard", style = "slidefade 15%" })

-- Slightly dim unfocused windows so the focused one stands out
hl.config({
    decoration = {
        dim_inactive = true,
        dim_strength = 0.08,
    },
})
