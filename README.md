# Sarasa Term and Term Slab Nerd Fonts (auto-built tap)

Nerd Fonts–patched **Sarasa Term** and **Sarasa Term Slab** families that keep Sarasa's strict **2:1 CJK-to-Latin width**
and use an **enlarged icon size** (`--cell 0:540`). Auto-rebuilt whenever
[be5invis/Sarasa-Gothic](https://github.com/be5invis/Sarasa-Gothic) ships a release.

## Install

Term SC:

```bash
brew tap wangkezun/sarasa-nerd
brew trust --cask wangkezun/sarasa-nerd/font-sarasa-term-sc-nerd
brew install --cask font-sarasa-term-sc-nerd
```

Traditional Chinese (TC):

```bash
brew trust --cask wangkezun/sarasa-nerd/font-sarasa-term-tc-nerd
brew install --cask font-sarasa-term-tc-nerd
```

Japanese (J):

```bash
brew trust --cask wangkezun/sarasa-nerd/font-sarasa-term-j-nerd
brew install --cask font-sarasa-term-j-nerd
```

Korean (K):

```bash
brew trust --cask wangkezun/sarasa-nerd/font-sarasa-term-k-nerd
brew install --cask font-sarasa-term-k-nerd
```

Hong Kong regional orthography (HC):

```bash
brew trust --cask wangkezun/sarasa-nerd/font-sarasa-term-hc-nerd
brew install --cask font-sarasa-term-hc-nerd
```

Classical orthography (CL):

```bash
brew trust --cask wangkezun/sarasa-nerd/font-sarasa-term-cl-nerd
brew install --cask font-sarasa-term-cl-nerd
```

Term Slab SC:

```bash
brew trust --cask wangkezun/sarasa-nerd/font-sarasa-term-slab-sc-nerd
brew install --cask font-sarasa-term-slab-sc-nerd
```

Term Slab TC:

```bash
brew trust --cask wangkezun/sarasa-nerd/font-sarasa-term-slab-tc-nerd
brew install --cask font-sarasa-term-slab-tc-nerd
```

Then set your terminal font to **`SarasaTermSC Nerd Font Mono`** or
the corresponding Term/Term Slab family. Updates arrive via `brew upgrade`.

## What's inside

- Families: `SarasaTermSC Nerd Font Mono`, `SarasaTermTC Nerd Font Mono`,
  `SarasaTermJ Nerd Font Mono`, `SarasaTermK Nerd Font Mono`,
  `SarasaTermHC Nerd Font Mono`, `SarasaTermCL Nerd Font Mono`,
  `SarasaTermSlabSC Nerd Font Mono`, and `SarasaTermSlabTC Nerd Font Mono`. Each has five
  weights from ExtraLight through Bold in upright and italic styles (10 faces per TTC).
- Patched with nerd-fonts font-patcher: `--single-width-glyphs --makegroups 1 --cell 0:540:-285:965`
  plus all icon sets, including a **trimmed Material Design** subset. The full ~6880-glyph Material
  Design set would push the CJK base over the 65535 sfnt limit, so it's trimmed to about 3500–4900
  glyphs depending on the locale's remaining capacity, dropping outline-duplicate/vehicle/game/zodiac
  buckets while force-keeping every icon eza and
  lsd reference. See `scripts/make-md-subset.py`.

## How it updates

A daily GitHub Actions workflow checks the upstream latest release, then builds and verifies every
variant in parallel (CJK width, glyph count, family name, icons). A single publish job uploads all
families to one GitHub Release and rewrites their casks, so `brew update && brew upgrade` tracks
upstream automatically.

## Licensing

Sarasa Gothic: SIL OFL 1.1 (`LICENSE-OFL.txt`). Nerd Fonts: MIT (`LICENSE-NERDFONTS.txt`).
Patched fonts are renamed ("… Nerd Font Mono") per OFL.
