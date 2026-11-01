#!/bin/sh
# Reinstall SWI-Prolog from the .deb set saved under
# ~/workspace/.tools/debs/swi/ plus the gettext-base .deb that the
# PAKCS build needs (envsubst). Run after a VM replacement, when the
# system packages under /usr are gone but ~/workspace persists.
# Must be run as root (or with sudo) from any directory.
set -e

TOOLS="$HOME/workspace/.tools"

dpkg -i \
  "$TOOLS/debs/swi/libossp-uuid16_1.6.2-1.3ubuntu1_amd64.deb" \
  "$TOOLS/debs/swi/swi-prolog-core_9.0.4+dfsg-3.1ubuntu4_amd64.deb" \
  "$TOOLS/debs/swi/swi-prolog-core-packages_9.0.4+dfsg-3.1ubuntu4_amd64.deb" \
  "$TOOLS/debs/swi/swi-prolog-nox_9.0.4+dfsg-3.1ubuntu4_amd64.deb" \
  "$TOOLS/debs/gettext/gettext-base_0.21-14ubuntu2_amd64.deb"

swipl --version

# PAKCS itself lives unpacked and built in place at
# $TOOLS/pakcs-3.9.0 and does not need reinstalling after a VM
# replacement, except that its saved Prolog state was built against
# the system SWI-Prolog above. If bin/pakcs fails after a restore,
# rebuild it in place with:
#   cd "$TOOLS/pakcs-3.9.0" && LC_ALL=C.UTF-8 make SWIPROLOG=/usr/bin/swipl
echo "SWI-Prolog restored. PAKCS home: $TOOLS/pakcs-3.9.0 (bin/pakcs)"
