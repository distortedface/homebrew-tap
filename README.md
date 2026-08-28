# SpinningCube Homebrew Tap

Public, source-free distribution for the
[SpinningCube.run](https://spinningcube.run) Local Agent.

The Local Agent keeps repository source and computation on the user's machine.
This repository contains only generated Homebrew metadata, release archives,
checksums, and public installation documentation. It does not mirror the
private SpinningCube.run product source repository.

## Install

After the first CLI release is published:

```sh
brew install distortedface/tap/spinningcube
spinningcube setup
spinningcube pair /path/to/repository
```

The Formula selects the native macOS archive or the supported Linux archive and
verifies its exact SHA-256 checksum. Host compilers are deliberately ignored;
verification runs with digest-pinned Docker authorities.

## Other installation methods

```sh
curl -fsSL https://spinningcube.run/install.sh | sh
```

Direct archives and their `.sha256` files are available from this repository's
[Releases](https://github.com/distortedface/homebrew-tap/releases).

## Support

Questions about installation or release artifacts: contact@spinningcube.run

