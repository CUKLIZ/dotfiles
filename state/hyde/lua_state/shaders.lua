local shader = ""
if rawget(_G, "hl") then hl.config({ decoration = { screen_shader = shader } }) end

return {
  path = "/home/tamara/.config/hypr/shaders/disable.frag",
  key = "disable",
  name = "disable",
  description = "Shader: disable",
  icon = "",
}
