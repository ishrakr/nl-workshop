# Doom WebAssembly Runtime

`websockets-doom.js` and `websockets-doom.wasm` were built from
`zackarychapple/doom-wasm` commit
`8df07c0cccf7fac8ff5f847c14608d5ed93d7709`, the source used by
Cloudflare Doom WASM pull request 14.

The build used `emscripten/emsdk:3.1.71` and the upstream `scripts/build.sh`.
The legacy `--closure 1` link flag was disabled because Closure fails on the
generated SDL JavaScript with this toolchain. The checked-in output hashes are
verified by `install-doom.sh` before installation.

Source: https://github.com/cloudflare/doom-wasm/pull/14
