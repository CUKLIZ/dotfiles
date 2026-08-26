# Tamara's Dotfiles — Hyprland + HyDE (Era Lua)

Snapshot konfigurasi per **2026-08-26**, setelah migrasi besar dari HyDE era `.conf`
ke **HyDE berbasis Lua** (Hyprland 0.56.2). Struktur folder meniru `$HOME` agar mudah
di-restore.

## 📁 Struktur

| Folder di repo | Lokasi asli di sistem | Isi |
|---|---|---|
| `config/hypr/hyprland.lua` ★ | `~/.config/hypr/` | Config utama Hyprland+HyDE + section USER OVERRIDES |
| `config/hypr/layouts/dwindle.lua` | `~/.config/hypr/layouts/` | Salinan layout Dwindle (tanpa gesture 3-jari; binds dwindle di ALT+H/I/J/K/L) |
| `config/hypr/*` | `~/.config/hypr/` | hypridle, hyprlock(+tema), pyprland.toml, hyprsunset, themes/, shaders/ |
| `config/waybar/user-style.css` ★ | `~/.config/waybar/` | Floating pill solid radius 16px |
| `config/waybar/*` | `~/.config/waybar/` | config.jsonc, style/theme/includes/menus |
| `config/kitty`, `config/fastfetch`, `config/rofi` | `~/.config/...` | Terminal, fetcher, launcher |
| `config/Code/User/settings.json` | `~/.config/Code/User/` | VSCode |
| `config/hyde/config.toml` | `~/.config/hyde/` | User config HyDE |
| `state/hyde/staterc` ★ | `~/.local/state/hyde/` | State HyDE (tema Catppuccin Mocha, animasi **fast**, layout dwindle, shader disable) |
| `state/hyde/lua_state/animations.lua` ★ | idem | Hand-patch → paket animasi `fast` |
| `state/hyde/lua_state/layouts.lua` ★★ | idem | Hand-patch → layout dari `config/hypr/layouts/` + cache-bust |
| `local/share/hyde/config-registry.toml` | `~/.local/share/hyde/` | Registry HyDE |
| `etc/keyd/default.conf` ★ | `/etc/keyd/` | R_Alt+IJKL = panah teks system-wide |
| `etc/hosts`, `etc/httpd/**` | `/etc/...` | Sistem |
| `_legacy/` | — | Arsip era `.conf` (keybindings/windowrules/userprefs, defaults.conf, php.ini, snapshot lama waybar/kitty/rofi/vscode/hyde) |

★ = dibuat/diubah saat migrasi 2026-08-26. ★★ = patch yang bisa ter-regenerasi HyDE (lihat gotcha).

## 📝 Changelog Migrasi (2026-08-26)

1. **Alt+Tab klasik** kembali: cycle fokus hanya dalam workspace aktif (`hl.dsp.window.cycle_next`) — altab bawaan HyDE (MRU global) ditimpa.
2. **Animasi**: paket `fast` (MD3 decel), via state `HYPR_ANIMATION="fast"` + `lua_state/animations.lua`.
3. **Gap** 3 / 8, **rounding** jendela 16px.
4. **Waybar floating pill** solid tanpa blur/transparan (user-style.css); klik tombol workspace butuh `waybar-git` (bug klik pada 0.15 stabil).
5. **Gesture swipe workspace = 4 jari** — 3 jari bug upstream Hyprland 0.55+ Lua (HyDE#1941), event tak sampai ke binder.
6. **Arrow keys fisik rusak** → digantikan `keyd`: R_Alt+J/I/K/L = panah teks system-wide (hold-to-repeat).
7. Cleanup stub mati: `animations.conf` (artefak, auto-regenerate), `layouts.conf`, `workspaces.conf`.

## ⚠️ Gotcha Penting

- **`lua_state/layouts.lua` bisa ter-regenerasi HyDE** (misal saat `hyde-shell reload theme`) dan kembali menunjuk folder share. Jika binds/layout custom mendadak hilang: patch ulang ke `~/.config/hypr/layouts/` + pastikan baris `package.loaded[_mod] = nil` ada.
- `animations.conf` di `~/.config/hypr/` akan muncul sendiri — biarkan, tidak berpengaruh.
- Bind Lua: jangan pakai `hyprctl dispatch <nama-lama>` (ditolak interpreter Lua); selalu closure `hl.dsp.*`.
- Introspeksi API tanpa docs: `hyprctl eval 'error(table.concat(...))'` trick.

## 🔁 Cara Restore Pasca-Reinstall

1. Install HyDE (branch lua) + `waybar-git` (AUR/chaotic) + `keyd`.
2. Copy `config/` → `~/.config/`, `state/hyde/` → `~/.local/state/hyde/`,
   `etc/keyd/default.conf` → `/etc/keyd/` lalu `sudo systemctl enable --now keyd`.
3. `hyde-shell reload all` → login ulang.
4. Jika tema/gesture aneh: cek dua gotcha di atas.
