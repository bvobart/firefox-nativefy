#!/usr/bin/env -S python3 -u
# Native messaging host for Firefox/Thunderbird extension "Open in Default Browser"

# Note that running python with the `-u` flag is required on Windows,
# in order to ensure that stdin and stdout are opened in binary, rather
# than text, mode.

import os
import sys
import json
import struct
import subprocess

# Read a Firefox extension message from stdin and decode it.
def getMessage():
  try:
    rawLength = sys.stdin.buffer.read(4)
    if len(rawLength) == 0:
      sys.exit(0)

    messageLength = struct.unpack('@I', rawLength)[0]
    message = sys.stdin.buffer.read(messageLength).decode('utf-8')
    return json.loads(message)
  except AttributeError:
    print('Python 3.2 or newer is required.')
    sys.exit(-1)

# Send an encoded message to stdout (where Firefox will read it).
def sendMessage(messageContent):
  # https://docs.python.org/3/library/json.html#basic-usage
  # To get the most compact JSON representation, you should specify
  # (',', ':') to eliminate whitespace.
  # We want the most compact representation because the browser rejects # messages that exceed 1 MB.
  encodedContent = json.dumps(messageContent, separators=(',', ':')).encode('utf-8')
  encodedLength = struct.pack('@I', len(encodedContent))
  sys.stdout.buffer.write(encodedLength)
  sys.stdout.buffer.write(encodedContent)
  sys.stdout.buffer.flush()


# Open the URL in the default browser.
def openInDefaultBrowser(url):
  if sys.platform.startswith('linux'):
    subprocess.Popen(["xdg-open", url])
  elif sys.platform.startswith('win32'):
    subprocess.Popen(["start", url])
  elif sys.platform.startswith('darwin'):
    subprocess.Popen(["open", url])
  else:
    print("Unsupported platform:", sys.platform)

#--------------------------------------------------------------------------------------------------

def install():
  home_path = os.getenv('HOME')

  manifest = {
    'name': 'open_default_browser',
    'description': 'Open a link in the default browser',
    'path': os.path.realpath(__file__),
    'type': 'stdio',
    'allowed_extensions': ['open-in-default-browser@example.org']
  }
  locations = {
    # TODO: make this work cross-platform: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_manifests#manifest_location
    'firefox': os.path.join(home_path, '.mozilla', 'native-messaging-hosts'),
    'thunderbird': os.path.join(home_path, '.thunderbird', 'native-messaging-hosts'),
  }
  filename = 'open_default_browser.json'

  for browser, location in locations.items():
    if not os.path.exists(os.path.dirname(location)):
      continue

    if not os.path.exists(location):
      os.mkdir(location)
    
    with open(os.path.join(location, filename), 'w') as file:
      file.write(
        json.dumps(manifest, indent=2, separators=(',', ': '), sort_keys=True).replace('  ', '\t') + '\n'
      )

#--------------------------------------------------------------------------------------------------

if __name__ == '__main__':
  if len(sys.argv) == 2:
    if sys.argv[1] == 'install':
      install()
      sys.exit(0)

  receivedMessage = getMessage()
  openInDefaultBrowser(receivedMessage)
  sendMessage("OK")
