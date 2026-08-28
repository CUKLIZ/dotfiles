-- Hyprland loads this file when it is started without a config, and it prefers
-- it over hyprland.conf. HyDE loads it too, last, as the override layer below.
-- The block keeps the two apart: hyde.lua sets `hyde` on its first line, so it
-- runs only when this file is the entry point and HyDE has not been loaded.
-- Removing it leaves a session with a cursor and nothing else.
if not hyde then
	local share = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
	local entry = share .. "/hypr/hyde.lua"
	local handle = io.open(entry, "r")
	if not handle then
		error("HyDE is not installed at " .. entry .. ". Run install.sh -r, or point Hyprland at your own config.")
	end
	handle:close()
	dofile(entry)
end

-- Your Hyprland configuration. HyDE never overwrites this file.
--
-- It loads after HyDE's own binds, so settings here take precedence. Replacing
-- a bind needs more than that: see below. HyDE's defaults live in
-- ~/.local/share/hypr/lua/ and are overwritten on every update, so edits there
-- do not survive.
--
-- Adding a keybind:
--
--     hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(hyde.sh.gamelauncher()), {
--         description = "[Utilities] game launcher",
--     })
--
-- Replacing one of HyDE's: bind the same combination again and yours takes
-- over, but copy its flags across as well. A bind counts as the same one only
-- when its flags match, and `description` is not a flag — miss one and both
-- binds stay live on that combination. Copy the whole options table from
-- ~/.local/share/hypr/lua/key_binds.lua and change only what you need:
--
--     hl.bind("F9", hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "m")), {
--         locked = true,
--         description = "[Hardware Controls|Audio] un/mute output",
--     })
--
-- Press SUPER + / to see what is actually loaded, your own binds included.
-- The full reference is KEYBINDINGS.md in the HyDE repository.
--
-- Other Lua files next to this one can be pulled in with require("name").

-- =============================================================================
-- USER OVERRIDES — ported from ~/dotfiles (Aug 2026)
-- This file is loaded last by HyDE (require("hyprland")), so everything below
-- takes precedence over HyDE's defaults.
-- =============================================================================

-- Guard against double execution (direct entry vs require("hyprland"))
if not _G.__user_overrides_loaded then
	_G.__user_overrides_loaded = true

	local _F

	-- * Layout & dekorasi ------------------------------------------------------
	-- gaps lama 5 / 20 terasa besar; pojok kotak → rounded 16px.
	hl.config({
		general = {
			gaps_in = "3",
			gaps_out = "8",
		},
		decoration = {
			rounding = 16,
		},
		input = {
			touchpad = {
				natural_scroll = true, -- dua jari = gaya macOS; roda mouse tetap normal
			},
			-- lv3:ralt_switch dicabut: bind Mod5 tidak pernah terpicu di build ini
		},
	})

	-- * Keybinds restored from dotfiles --------------------------------------
	_F = {description = "[Launcher|Apps] terminal emulator (enter)"}
	hl.bind("SUPER + RETURN", hl.dsp.exec_cmd((hyde.config.app and hyde.config.app.terminal) or "kitty"), _F)

	_F = {description = "[Launcher|Apps] dropdown terminal"}
	hl.bind("SUPER + ALT + RETURN", hl.dsp.exec_cmd("hyde-shell pypr toggle console"), _F)

	_F = {description = "[Custom|Shortcut] discord"}
	hl.bind("SUPER + D", hl.dsp.exec_cmd("discord"), _F)

	-- Replaces HyDE's scratchpad toggle on the same combo (flags match -> dedup)
	_F = {description = "[Custom|Shortcut] spotify"}
	hl.bind("SUPER + S", hl.dsp.exec_cmd("spotify"), _F)

	-- SUPER + F: maximize toggle, like old `fullscreen, 1`
	local user_toggle_maximize = function()
		local win = assert(hl.get_active_window(), "No active window to maximize")
		local current = tonumber(win.fullscreen) or 0
		local target = (current == 1) and 0 or 1
		hl.dispatch(hl.dsp.window.fullscreen_state({internal = target, client = target, window = win}))
	end
	_F = {description = "[Window Management] maximize window"}
	hl.bind("SUPER + F", user_toggle_maximize, _F)

	-- * Alt+Tab klasik: cycle window DI WORKSPACE AKTIF ----------------------
	-- Menimpa "altab" bawaan HyDE (MRU global lintas workspace). Flag
	-- transparent dicocokkan agar dedup menimpa bind lama dengan bersih.
	-- CATATAN: pakai closure hl.dsp.native — `hyprctl dispatch cyclenext`
	-- gaya lama DITOLAK interpreter Lua di build ini.
	hl.bind("ALT + TAB", function()
		hl.dispatch(hl.dsp.window.cycle_next())
	end, {
		description = "[Window Management|Change focus] cycle focus (workspace aktif)",
		transparent = true,
	})
	hl.bind("ALT + SHIFT + TAB", function()
		hl.dispatch(hl.dsp.window.cycle_next("prev"))
	end, {
		description = "[Window Management|Change focus] cycle focus mundur",
		transparent = true,
	})

	-- Netralkan bind "--apply" milik altab (tidak berguna tanpa altab aktif)
	local user_noop = function() end
	hl.bind("ALT + ALT_R", user_noop, {release = true, transparent = true})
	hl.bind("ALT + ALT_L", user_noop, {release = true, transparent = true})

	-- * Arrow keys fisik rusak → digantikan KEYD system-wide ------------------
	-- R_Alt + J/I/K/L menghasilkan panah ASLI untuk kursor teks di semua app.
	-- Konfigurasinya ada di /etc/keyd/default.conf (bukan di sini).
	-- Bind manajemen jendela gaya IJKL sudah dicabut; Dwindle kembali ke
	-- ALT+H/I/J/K/L via ~/.config/hypr/layouts/dwindle.lua.


	-- * Gestures ---------------------------------------------------------------
	-- Swipe workspace: 4 JARI horizontal/vertical — didaftarkan oleh
	-- ~/.config/hypr/layouts/dwindle.lua.
	-- CATATAN: 3 jari TIDAK dipakai — di Hyprland 0.55+ Lua, event swipe
	-- 3-jari tidak sampai ke binder gesture (bug upstream, lihat HyDE#1941);
	-- pad ALPS DualPoint ini ikut terdampak. Revisit saat upgrade Hyprland.

	-- Threshold longgar untuk touchpad kecil (default distance 300)
	hl.config({
		gestures = {
			workspace_swipe_distance = 100,
			workspace_swipe_cancel_ratio = 0.3,
		},
	})
	hl.gesture({
		fingers = 3,
		direction = "pinchin",
		action = function()
			hl.dispatch(hl.dsp.window.float({action = "toggle"}))
		end,
	})
	hl.gesture({
		fingers = 3,
		direction = "pinchout",
		action = user_toggle_maximize,
	})

	-- * Window rules ported from dotfiles ------------------------------------
	-- idle inhibit while media plays fullscreen
	hl.window_rule({
		name = "user_idle_inhibit_media",
		idle_inhibit = "fullscreen",
		match = {class = "^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$|^(.*[Ss]potify.*)$"},
	})
	hl.window_rule({
		name = "user_idle_inhibit_browser",
		idle_inhibit = "fullscreen",
		match = {
			class =
			"^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$",
		},
	})

	-- Picture-in-Picture
	hl.window_rule({
		name = "user_pip",
		float = true,
		pin = true,
		keep_aspect_ratio = true,
		move = "73% 72%",
		size = "25% 25%",
		match = {title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"},
	})

	-- Opacity groups
	hl.window_rule({
		name = "user_opacity_80",
		opacity = "0.80 0.80 1",
		match = {
			class = [[^(org.kde.dolphin)$|^(org.kde.ark)$|^(nwg-look)$|^(qt5ct)$|^(qt6ct)$|^(kvantummanager)$]]
				.. [[|^(com.github.tchx84.Flatseal)$|^(hu.kramo.Cartridges)$|^(com.obsproject.Studio)$]]
				.. [[|^(gnome-boxes)$|^(vesktop)$|^(WebCord)$|^(ArmCord)$|^(app.drey.Warp)$]]
				.. [[|^(net.davidotek.pupgui2)$|^(yad)$|^(Signal)$|^(io.github.alainm23.planify)$]]
				.. [[|^(io.gitlab.theevilskeleton.Upscaler)$|^(com.github.unrud.VideoDownloader)$]]
				.. [[|^(io.gitlab.adhami3310.Impression)$|^(io.missioncenter.MissionCenter)$|^(io.github.flattool.Warehouse)$]],
		},
	})
	hl.window_rule({
		name = "user_opacity_80_70",
		opacity = "0.80 0.70 1",
		match = {
			class = [[^(org.pulseaudio.pavucontrol)$|^(blueman-manager)$|^(nm-applet)$|^(nm-connection-editor)$]]
				.. [[|^(org.kde.polkit-kde-authentication-agent-1)$|^(polkit-gnome-authentication-agent-1)$]]
				.. [[|^(org.freedesktop.impl.portal.desktop.gtk)$|^(org.freedesktop.impl.portal.desktop.hyprland)$]],
		},
	})
	hl.window_rule({
		name = "user_opacity_90_clapper",
		opacity = "0.90 0.90 1",
		match = {class = "^(com.github.rafostar.Clapper)$"},
	})

	-- Float rules
	hl.window_rule({
		name = "user_float",
		float = true,
		match = {
			class = [[^(Signal)$|^(com.github.rafostar.Clapper)$|^(app.drey.Warp)$|^(net.davidotek.pupgui2)$]]
				.. [[|^(yad)$|^(eog)$|^(io.github.alainm23.planify)$|^(io.gitlab.theevilskeleton.Upscaler)$]]
				.. [[|^(com.github.unrud.VideoDownloader)$|^(io.gitlab.adhami3310.Impression)$|^(io.missioncenter.MissionCenter)$]],
		},
	})

	-- Media apps open fullscreen
	hl.window_rule({
		name = "user_fullscreen_media",
		fullscreen = true,
		match = {class = "^(Spotify|discord)$"},
	})

	-- Dolphin/Ark (file managers): HyDE's hyde_floating_class lists dolphin as floating,
	-- conflicting with filemanagers-fullscreen. Loaded last so this wins: stay tiled + maximized.
	hl.window_rule({
		name = "user_filemanager_tiled",
		float = false,
		maximize = true,
		match = {class = "^(org\\.kde\\.dolphin)$|^(org\\.kde\\.ark)$"},
	})
	-- Re-float Dolphin dialog windows (Properties, Create Folder, Copying, dll)
	hl.window_rule({
		name = "user_dolphin_dialog_float",
		float = true,
		maximize = false,
		match = {
			class = "^(org\\.kde\\.dolphin)$",
			title = ".*(Dialog|Properties|Copying|Choose|Save As|Confirm|Progress|Authentication|Upload|Folder|Rename|Delete|Already Exists|New).*",
		},
	})

	-- Workaround: JetBrains IDE popups flicker on focus
	hl.window_rule({
		name = "user_jetbrains_popups",
		no_initial_focus = true,
		match = {class = "^(.*jetbrains.*)$", title = "^(win[0-9]+)$"},
	})
end
