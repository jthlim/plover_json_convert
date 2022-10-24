#! /bin/bash

# Top priority dictionaries are listed at the top.

dart run bin/main.dart \
  ~/Library/Application\ Support/plover/plover-retro-quotes.json \
  ~/Library/Application\ Support/plover/plover-retro-text-transform.json \
  /Applications/Plover.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/plover/assets/commands.json \
  /Applications/Plover.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/plover/assets/main.json \
  > main_dictionary.cc
