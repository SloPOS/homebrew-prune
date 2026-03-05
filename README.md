# homebrew-prune

Homebrew tap for [Prune](https://github.com/SloPOS/Prune).

## Install

```bash
brew tap SloPOS/prune
brew install prune
```

## Run

```bash
prune
```

Then open <http://localhost:4173>.

## Optional: run as a background service

```bash
brew services start prune
```

## Notes

- This tap is additive and does **not** replace Docker or curl installs.
- Existing install methods remain supported in the main Prune repo.
