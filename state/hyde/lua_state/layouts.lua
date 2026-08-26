local _dir = "/home/tamara/.config/hypr/layouts"
local _p   = "/home/tamara/.config/hypr/layouts/dwindle.lua"
local _mod = _p:match("^.*/(.-)%.lua$")
if not package.path:find(_dir .. "/?.lua", 1, true) then
    package.path = _dir .. "/?.lua;" .. package.path
end
package.loaded[_mod] = nil -- force re-exec on every reload (module cache busting)
local _ok, _t = pcall(require, _mod)
if not (_ok and type(_t) == 'table') then _t = {} end
_t.path = _p
_t.key  = _t.key or "dwindle"
return _t
