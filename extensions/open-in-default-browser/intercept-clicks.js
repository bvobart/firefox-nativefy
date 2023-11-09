function openInDefaultBrowser(url) {
  console.log("Opening in default browser: " + url);
  browser.runtime.sendMessage({ type: 'open-in-default-browser', url: url });
}

// Whenever an external link is clicked, open it in the default browser.
// An external link is a link that points to a different domain than the current hostname.
function onClick(event) {
  // find nearest <a href="..."> element
  let target = event.target;
  while ((target.tagName != "A" || !target.href) && target.parentNode) {
    target = target.parentNode;
  }
  // if there's none, then no link was clicked
  if (target.tagName !== "A") return;

  // internal links will be opened normally
  const targetDomain = new URL(target.href).hostname;
  if (targetDomain === window.location.hostname) return;

  // otherwise, open in default browser
  const url = target.href;
  event.preventDefault();
  openInDefaultBrowser(url);
}

window.addEventListener("click", onClick);
