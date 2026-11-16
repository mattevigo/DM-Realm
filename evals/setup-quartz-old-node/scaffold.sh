#!/bin/sh
set -e
mkdir -p "$HOME/.dm-realm"
printf '#!/bin/sh\necho v18.19.0\n' > "$HOME/.dm-realm/old-node"
chmod +x "$HOME/.dm-realm/old-node"
