function openInDefaultBrowser(url) {
  console.log("Opening in default browser: " + url);
  browser.runtime.sendMessage({ type: 'open-in-default-browser', url: url });
}

// whenever a link is clicked, open it in the default browser.
function onClick(event) {
  // find nearest <a href="..."> element
  let target = event.target;
  while ((target.tagName != "A" || !target.href) && target.parentNode) {
    target = target.parentNode;
  }
  // if there's none, then no link was clicked
  if (target.tagName !== "A") return;

  const url = target.href;
  event.preventDefault();
  openInDefaultBrowser(url);
}

window.addEventListener("click", onClick);
