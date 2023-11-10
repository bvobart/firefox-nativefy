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
./firefox-nativefy.sh web.whatsapp.com --name "Custom Name"
```

or:

```sh
# Supply a custom icon after the name
./firefox-nativefy.sh web.whatsapp.com --name "Custom Name" --icon "custom-icon"
```

or 

```sh
# Display the full help text
./firefox-nativefy.sh --help
```

Now you can launch your nativefied application as you would with any other installed application.

> NOTE: the extension to launch external links in the default browser won't be active yet the first time you launch your newly nativefied application (unless you have already nativefied it previously).
> This is a minor annoyance and might in fact be useful for SSO logins.

### Updating

If `firefox-nativefy.sh` has updated since you've nativefied your application, simply run the same nativefication command as you originally did.
Running `firefox-nativefy.sh` a second time for the same URL and application name will only overwrite the application shortcut and update what is necessary in the Firefox profile.

Your nativefied application will update itself automatically as it is still basically just a website running in a browser.

## How it works

`firefox-nativefy.sh` works by creating a custom Firefox profile for the application that you want to nativefy,
and applies some customisations to the profile to hide Firefox' usual UI.
It also installs an extension in the custom profile so that all external links are opened in your default web browser.

Then it creates an application shortcut (`.desktop` file) in your user's applications folder to launch a new instance of Firefox with that custom profile.

That's it. It's that simple.

## How to remove a nativefied app?

```sh
# Remove the application shortcut.
rm ~/.local/share/applications/$NAME_UNSPACED.desktop

# Remove the Firefox profile
firefox -P # opens Firefox' profile manager
# Select the profile with the unspaced name of the app, then click 'Delete Profile ...' and click 'Delete Files'
```

`$NAME_UNSPACED` is the name of the application, with all spaced removed. E.g. let's say we nativefied `web.whatsapp.com` as `WhatsApp Desktop`.
Then the unspaced name is `WhatsAppDesktop`.

## Credits

Thanks to:
- Reddit user LasterCow and his [Firetron](https://pastebin.com/nKsqbysD) script for the inspiration for the basics of this script.
- Firefox Extension [Open With](https://github.com/darktrojan/openwith/) for some inspiration on how to write a Firefox extension that will open links in a different browser.

## TODO:

- maybe allow multiple tabs? tab bar should become visible when >= 2 tabs open
