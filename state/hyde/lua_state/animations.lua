local _dir = "/home/tamara/.local/share/hypr/lua/animations"
local _p   = "/home/tamara/.local/share/hypr/lua/animations/classic.lua"
local _mod = _p:match("^.*/(.-)%.lua$")
if not package.path:find(_dir .. "/?.lua", 1, true) then
    package.path = _dir .. "/?.lua;" .. package.path
end
local _ok, _t = pcall(require, _mod)
if not (_ok and type(_t) == 'table') then _t = {} end
_t.path = _p
_t.key  = _t.key or "classic"
return _t
