# Backwords

A word puzzle game combining Wordle-style deduction with Scrabble scoring.

[![Gameplay Video](https://img.youtube.com/vi/-ihoI_oQVUs/maxresdefault.jpg)](https://www.youtube.com/watch?v=-ihoI_oQVUs)

[▶ Watch gameplay video](https://www.youtube.com/watch?v=-ihoI_oQVUs)

## Features

- **Daily Challenges**: New puzzle every day
- **Medal System**: Earn bronze, silver, and gold based on your performance
- **Statistics Tracking**: Track your wins, streaks, and scores

## Requirements

- Godot 3.x

## How to Run

1. Open `project.godot` in the Godot Editor
2. Hit Play (F5)

## How to Build

Export presets are already configured for:
- Windows
- macOS
- Web

Use `Project > Export` in Godot to build for your target platform.

## Custom Definitions

The game supports an optional definitions file. To add word definitions:

1. Create `Puzzles/definitions.txt`
2. Format: one word per line, tab-separated: `word<TAB>definition`

Example:
```
aback	toward the back
abate	to reduce in intensity
```

## Attribution

**Word List**: [ENABLE](https://everything2.com/title/ENABLE+word+list) (Enhanced North American Benchmark Lexicon) - Public Domain

## Fonts

The game requires the following fonts (not included due to licensing):

| File | Font |
|------|------|
| `Graphics/Fonts/Salis MVB Medium.otf` | [MVB Salis Medium](https://www.mvbfonts.com/mvb_salis/) |
| `Graphics/Fonts/Timonium Medium Italic.otf` | [Timonium Medium Italic](https://typesupply.com/fonts/timonium) |
| `Graphics/Fonts/Tinonium Black.otf` | [Timonium Black](https://typesupply.com/fonts/timonium) |

Both are available via Adobe Fonts subscription or direct purchase. You can substitute with similar fonts by placing them in `Graphics/Fonts/` with the expected filenames.

## License

MIT License - see [LICENSE](LICENSE) for details.
