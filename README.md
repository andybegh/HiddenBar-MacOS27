<p align="center">
  <img width="200" height="200" src="img/icon_512%402x.png" alt="Hidden Bar icon">
</p>
<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg" alt="platform">
  <img src="https://img.shields.io/badge/requirements-macOS%20Golden%20Gate-ff69b4.svg" alt="macOS Golden Gate required">
</p>

# Hidden Bar for macOS 27

Hide menu bar items and keep your Mac tidy. This edition is maintained by
[Andrea Beghè](https://github.com/andybegh) for macOS 27 Golden Gate.

<p align="center">
  <img width="400" src="img/screen1.png" alt="Hidden Bar screenshot">
  <img width="400" src="img/screen2.png" alt="Hidden Bar preferences">
</p>

## Download

[Download HiddenBar-MacOS27.zip](https://github.com/andybegh/HiddenBar-MacOS27/releases/latest/download/HiddenBar-MacOS27.zip)

The app is distributed without Apple notarization. macOS may request confirmation
the first time it is opened.

## Usage

- Hold `⌘` and drag to arrange menu bar items.
- Click the arrow to hide or reveal them.

## Build from source

Open `Hidden Bar.xcodeproj` in Xcode, select your development team, then build
the `Hidden Bar` scheme.

## Compatibility

Requires macOS 27 Golden Gate. Mixed-width multi-display setups are disabled by
default because macOS assigns the same status-item width to every mirrored menu
bar. To enable the narrowest-display workaround:

```shell
defaults write com.andybegh.HiddenBar hideWithMixedDisplays -bool true
```

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before contributing.

## License

MIT © 2026 Andrea Beghè. See [LICENSE](LICENSE) for the full license and required
notices from earlier versions. Third-party notices are in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
