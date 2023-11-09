// Listen for commands from the content script.
browser.runtime.onMessage.addListener(message => {
  if (message.type === 'open-in-default-browser') {
    browser.runtime.sendNativeMessage("open_default_browser", message.url).then(
      result => { if (result != "OK") console.error("Error opening in default browser: " + result) },
      error => { console.error('error opening in default browser', error); },
    )
  }
});
