#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

node2nix \
  --nodejs-10 \
  --input deps.json \
  --composition node.nix \
  --no-copy-node-env
