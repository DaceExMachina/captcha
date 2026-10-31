# Captcha costume

A fake reCAPTCHA that gets weirder every round, for wearing on a Raspberry Pi screen. It's a plain web page (`index.html` plus the photos in `img/`), so all the Pi has to do is show it full screen in Chromium.

## Run it on the Pi

You need Raspberry Pi OS **with desktop** (the Lite version has no browser) and a touchscreen.

1. **Copy the folder over** from the Mac (swap in your Pi's username and hostname), or use a USB stick:

   ```bash
   scp -r ~/projects/captcha-costume pi@raspberrypi.local:~/
   ```

2. **Install the emoji font** on the Pi. The humans round and the final verdicts use emoji:

   ```bash
   sudo apt install fonts-noto-color-emoji
   ```

3. **Try it** in full-screen kiosk mode. On the newest Raspberry Pi OS the command is `chromium` instead of `chromium-browser`:

   ```bash
   chromium-browser --kiosk --noerrdialogs --disable-infobars file:///home/pi/captcha-costume/index.html
   ```

   Press Alt+F4 to get out of kiosk mode.

4. **Start it at boot** so you just plug in the battery and go. Create `~/.config/autostart/captcha.desktop`:

   ```ini
   [Desktop Entry]
   Type=Application
   Name=Captcha
   Exec=chromium-browser --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble file:///home/pi/captcha-costume/index.html
   ```

5. **Stop the screen from going dark:** `sudo raspi-config`, then Display Options, then Screen Blanking, and turn it off.

6. **Portrait screen?** Rotate it in the Screen Configuration app (Preferences menu). The page scales itself to whatever shape the screen is.

Power it from a USB power bank in a pocket. The page goes back to the checkbox after 45 seconds untouched, so it resets itself between people.

## Run it on an old iPad (iOS 10)

The page works in iOS 10 Safari, and `captcha.appcache` makes Safari keep an offline copy, so after one load at home you don't need Wi-Fi.

1. **Serve the folder from the Mac** (the cache file needs its own content type):

   ```bash
   cd ~/projects/captcha-costume
   python3 -c "import http.server as h; h.SimpleHTTPRequestHandler.extensions_map['.appcache']='text/cache-manifest'; h.test(h.SimpleHTTPRequestHandler, port=8000, bind='0.0.0.0')"
   ```

2. **Open it on the iPad** at `http://<your-mac-name>.local:8000` (the Mac's name is in System Settings, General, Sharing). Wait about 10 seconds so every photo downloads.
3. **Add it to the home screen:** Share button, then Add to Home Screen. Opened from there, it runs full screen with no Safari bars.
4. **Test it offline:** turn on airplane mode and open it from the home screen.
5. **Stop the screen sleeping:** Settings, Display & Brightness, Auto-Lock, Never.
6. **Lock the iPad to the captcha:** turn on Settings, General, Accessibility, Guided Access. Then open the captcha and triple-click the home button. People can tap all they like, but they can't leave the app.

If you change any file, bump the version line in `captcha.appcache`, or the iPad keeps showing the old copy. The app checks for a new version each time it opens and reloads itself when it finds one, so open it once with the Mac's server running. If you add a file, list it in `captcha.appcache` too.

## Testing

Add `#debug` to the end of the address (for example `http://<your-mac>:8000/#debug`) and reload. A bar appears at the top with buttons that jump straight to each round or each verdict.

The headphones button plays `scream.mp3`, the Wilhelm scream with reverb added.

## Swap in your own photos

Tiles are plain square JPEGs in `img/`. Replace any of them with your own (same name, roughly 240x240).

To replace the cyclist with yourself, take a side-on photo of you riding, then on a Mac:

```bash
swift tools/cutout.swift my-ride.jpg img/cyclist.png
```

The page mirrors the cutout so it rides to the right. If yours already faces right, remove `transform:scaleX(-1)` from `.bike img` in `index.html`.

Photo credits are in `CREDITS.md`.
