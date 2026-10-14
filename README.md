English | [Русский](README.ru.md)

# yamusic-tui.nix

Nix flake that packages [yamusic-tui](https://github.com/DECE2183/yamusic-tui) — an unofficial Yandex Music terminal client.

The package repackages the official prebuilt binary from the [releases page](https://github.com/DECE2183/yamusic-tui/releases). Upstream ships a bare, dynamically linked executable (not an archive), so it is fetched as-is and only its ELF interpreter and `RPATH` are fixed up with `autoPatchelfHook`.

## Supported platforms

| System           | Status |
|------------------|--------|
| `x86_64-linux`   | tested |

Upstream only publishes `linux-amd64` and `windows-amd64` builds — there is no `aarch64-linux` or macOS binary. Requesting the package on a system without a build fails with a clear error.

## Usage

Run without installing:

```sh
nix run github:smykoff/yamusic-tui.nix
```

Install into the user profile:

```sh
nix profile install github:smykoff/yamusic-tui.nix
```

### NixOS (flakes)

```nix
{
  inputs.yamusic-tui.url = "github:smykoff/yamusic-tui.nix";

  outputs = { nixpkgs, yamusic-tui, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            yamusic-tui.packages.${pkgs.system}.default
          ];
        })
      ];
    };
  };
}
```

Or via the overlay:

```nix
nixpkgs.overlays = [ yamusic-tui.overlays.default ];
environment.systemPackages = [ pkgs.yamusic-tui ];
```

## Configuration

On first launch `yamusic-tui` asks for a Yandex Music token and writes a config to
`~/.config/yamusic-tui/config.yaml`; the track cache goes to `~/.cache/yamusic-tui`.
The token can be obtained with a browser extension (see the
[upstream README](https://github.com/DECE2183/yamusic-tui#requirements)).

## Notes

- Audio playback goes through ALSA. nixpkgs' `alsa-lib` uses its own store-backed
  config directory, so it works out of the box on NixOS (PipeWire/PulseAudio provide
  the ALSA plugin) without extra wrapping.
- System media controls use MPRIS, so a D-Bus session and a running MPRIS host are
  required. Upstream also publishes a `-nomedia` build that disables this — this flake
  packages the default (media-enabled) build.
- The upstream release asset is named `yamusic`, while `go install` produces
  `yamusic-tui`; this package installs the command as `yamusic-tui`.

## Updating

Versions and hashes live in `sources.json`. Regenerate it with:

```sh
bash scripts/update.sh
```

A scheduled GitHub Actions workflow (`.github/workflows/update.yml`) runs it daily,
builds the package and commits the result.
