# dotfiles

Setup Hyprland + HyDE (lua) di Arch Linux. Snapshot per 26 Agustus 2026.

Struktur mengikuti home asli, jadi tinggal copy balik kalau reinstall.

## Isi

- `config/hypr/hyprland.lua` — config utama. Bagian bawah ada section "USER OVERRIDES"
  (alt+tab klasik, super+d/s/f, animasi fast, gap 3/8, rounding 16px).
- `config/hypr/layouts/dwindle.lua` — salinan layout dwindle, binds di ALT+H/I/J/K/L.
- `config/waybar/` — bar floating pill solid (user-style.css), sisanya bawaan HyDE.
- `state/hyde/` — state HyDE: tema Catppuccin Mocha, animasi fast, layout dwindle.
  File `lua_state/layouts.lua` dan `animations.lua` itu hand-patch.
- `etc/keyd/default.conf` — R_Alt + J/I/K/L buat panah (arrow key laptop rusak).
  Jangan lupa `sudo systemctl enable --now keyd`.
- `_legacy/` — config era .conf yang lama, cuma buat kenang-kenangan.
  Wallpaper kebanyakan udah dibuang, sisa satu doang biar repo gak gemuk.

## Hal yang gampang kelupaan

- `lua_state/layouts.lua` bisa ke-regenerate sendiri sama HyDE (misal habis
  `hyde-shell reload theme`). Kalau layout/binds custom tiba-tiba hilang,
  cek file itu — harus nunjuk ke `~/.config/hypr/layouts/`.
- `animations.conf` di ~/.config/hypr bakal muncul lagi terus, biarin aja.
- Alt+Tab di sini cycle window dalam satu workspace aja, beda dari bawaan HyDE.
- Swipe workspace pakai 4 jari. Yang 3 jari mati karena bug upstream
  (HyDE issue #1941), bukan salah setup.

## Restore

```bash
# clone, lalu:
cp -r config/. ~/.config/
cp -r state/hyde/. ~/.local/state/hyde/
sudo cp etc/keyd/default.conf /etc/keyd/
sudo systemctl enable --now keyd
sudo pacman -S --needed keyd
# waybar: pakai waybar-git, tombol workspace-nya mati di 0.15 stabil
hyde-shell reload all
```

Urutan install HyDE duluan tentunya, ini cuma numpuk config di atasnya.
