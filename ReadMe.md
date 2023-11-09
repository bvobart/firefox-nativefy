# `firefox-nativefy.sh`

Want have a website as a desktop application? But is there no official application available (for Linux)? And do you want to avoid Chrome / Electron?

Here's `firefox-nativefy.sh`: a simple Bash script to help you nativefy websites with Firefox, i.e. turn a website into a "native" application by launching a customized instance of Firefox.

## Usage

First, ensure that Firefox is installed on your system. This is already the default for most Linux distributions.

Then:

```sh
# WhatsApp, Telegram and Notion are automatically detected to have correct names
./firefox-nativefy.sh web.whatsapp.com
```

or:

```sh
# Supply a custom name for the to-be-nativefied application
./firefox-nativefy.sh web.whatsapp.com "Custom Name"
```

or:

```sh
# Supply a custom icon after the name
./firefox-nativefy.sh web.whatsapp.com "Custom Name" --icon "custom-icon"
```

or 

```sh
# Display the full help text
./firefox-nativefy.sh --help
```

## How it works

`firefox-nativefy.sh` works by creating a custom Firefox profile for the application that you want to nativefy,
and applies some customisations to the profile to hide Firefox' usual UI.
Then it creates a `.desktop` file in your user's applications folder to launch a new instance of Firefox with that profile
(plus some additional tweaks to get the application icon and taskbar grouping showing correctly).

That's it. It's that simple.

## How to remove a nativefied app?

```sh
# Remove the application shortcut.
rm ~/.local/share/applications/NAME_UNSPACED.desktop

# Remove the Firefox profile
firefox -P # opens Firefox' profile manager
# Select the profile with the unspaced name of the app, then click 'Delete Profile ...' and click 'Delete Files'
```

`NAME_UNSPACED` is the name of the application, with all spaced removed. E.g. let's say we nativefied `web.whatsapp.com` as `WhatsApp Desktop`.
Then the unspaced name is `WhatsAppDesktop`.

## Credits

Thanks to:
- Reddit user LasterCow and his [Firetron](https://pastebin.com/nKsqbysD) script for the inspiration for the basics of this script.
- Firefox Extension [Open With](https://github.com/darktrojan/openwith/) for some inspiration on how to write a Firefox extension that will open links in a different browser.

## TODO:

- ensure external links get opened in user's default browser (even if this is Firefox with a different profile)
  - TODO: I wrote an extension which opens external links in the default browser. I've tested that it works. Now just need to package & install it during firefox-nativefy installation (including the native component).
  - TODO: if needed, ensure that only external links are opened in the default browser, not internal links (useful for Notion, probably).
- maybe allow multiple tabs? tab bar should become visible when >= 2 tabs open
- remove the -14px margin.
