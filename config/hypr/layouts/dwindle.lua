-- User copy of HyDE's layouts/dwindle.lua (Aug 2026).
-- Difference vs upstream: the 3-finger focus gestures are REMOVED so the
-- user's own 3-finger workspace swipe (hyprland.lua) can register instead.
-- Upstream lives in ~/.local/share/hypr/lua/layouts/ and gets overwritten on
-- every HyDE update; this copy does not.
local layout = {
    name = "Dwindle",
    icon = "",
    description = "Dwindle layout // Best for maximizing space"
}
if not hl then
    return layout
end

hl.config(
    {
        general = {
            layout = "dwindle"
        },
        dwindle = {
            force_split = 2
        }
    }
)

hl.bind("ALT + J", hl.dsp.layout("togglesplit"), {description = "[Dwindle] toggle split"})
hl.bind("ALT + K", hl.dsp.layout("swapsplit"), {description = "[Dwindle] swap split halves"})
hl.bind("ALT + H", hl.dsp.layout("splitratio -0.1"), {description = "[Dwindle] decrease split ratio"})
hl.bind("ALT + L", hl.dsp.layout("splitratio +0.1"), {description = "[Dwindle] increase split ratio"})
hl.bind("ALT + U", hl.dsp.layout("movetoroot"), {description = "[Dwindle] move focused window to root subtree"})
hl.bind("ALT + Y", hl.dsp.layout("preselect l"), {description = "[Dwindle] preselect left/top split"})
hl.bind("ALT + I", hl.dsp.layout("preselect r"), {description = "[Dwindle] preselect right/bottom split"})

hl.gesture(
    {
        fingers = 4,
        direction = "horizontal",
        action = "workspace"
    }
)

hl.gesture(
    {
        fingers = 4,
        direction = "vertical",
        action = "workspace"
    }
)
