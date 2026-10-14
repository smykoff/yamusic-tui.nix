[English](README.md) | Русский

# yamusic-tui.nix

Nix flake с пакетом [yamusic-tui](https://github.com/DECE2183/yamusic-tui) — неофициальный терминальный клиент Яндекс Музыки.

Пакет перепаковывает официальный готовый бинарник со [страницы релизов](https://github.com/DECE2183/yamusic-tui/releases). Upstream публикует «голый» динамически слинкованный исполняемый файл (не архив), поэтому он скачивается как есть, а исправляются только ELF-интерпретатор и `RPATH` через `autoPatchelfHook`.

## Поддерживаемые платформы

| Система          | Статус    |
|------------------|-----------|
| `x86_64-linux`   | проверено |

Upstream собирает только `linux-amd64` и `windows-amd64` — сборок под `aarch64-linux` и macOS нет. Запрос пакета на системе без сборки падает с внятной ошибкой.

## Использование

Запуск без установки:

```sh
nix run github:smykoff/yamusic-tui
```

Установка в профиль пользователя:

```sh
nix profile install github:smykoff/yamusic-tui
```

### NixOS (flakes)

```nix
{
  inputs.yamusic-tui.url = "github:smykoff/yamusic-tui";

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

Или через оверлей:

```nix
nixpkgs.overlays = [ yamusic-tui.overlays.default ];
environment.systemPackages = [ pkgs.yamusic-tui ];
```

## Настройка

При первом запуске `yamusic-tui` попросит токен Яндекс Музыки и создаст конфиг в
`~/.config/yamusic-tui/config.yaml`; кэш треков — в `~/.cache/yamusic-tui`.
Токен можно получить с помощью браузерного расширения (см.
[README upstream](https://github.com/DECE2183/yamusic-tui#requirements)).

## Примечания

- Воспроизведение звука идёт через ALSA. В nixpkgs `alsa-lib` использует собственный
  каталог конфигурации в store, поэтому на NixOS всё работает из коробки (плагин ALSA
  предоставляют PipeWire/PulseAudio) без дополнительной обёртки.
- Системные медиа-клавиши используют MPRIS, поэтому нужен сеанс D-Bus и запущенный
  MPRIS-хост. Upstream также публикует сборку `-nomedia`, отключающую эту функцию, —
  здесь упакована сборка по умолчанию (с медиа).
- Релизный файл называется `yamusic`, тогда как `go install` создаёт `yamusic-tui`;
  этот пакет устанавливает команду как `yamusic-tui`.

## Обновление

Версии и хеши хранятся в `sources.json`. Перегенерировать его можно так:

```sh
bash scripts/update.sh
```

Workflow GitHub Actions (`.github/workflows/update.yml`) запускает его раз в сутки,
собирает пакет и коммитит результат.
