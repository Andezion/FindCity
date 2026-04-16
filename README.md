# FindCity (City Compass)

## Table of Contents
- [General Info](#general-info)
- [Demonstration](#demonstration)
- [Technologies](#technologies)
- [Future Plans](#future-plans)
- [Setup](#setup)

## General Info
FindCity - кроссплатформенное Flutter-приложение, где игрок по компасу и расстоянию должен угадать расположение города. Проект структурирован по экранам и сервисам: логика границ игры в `models/` и `services/`, UI — в `screens/` и `widgets/`.

## Demonstration
- Запуск игры: экран настроек → начать сессию.
- Во время игры используются датчики устройства (компас) и геолокация для расчёта направления и дистанции до целевого города.
- В UI есть виджеты: компас (live/manual), таймер и отображение результата.

## Technologies
- **Framework:** Flutter (Dart)
- **Key packages:** `flutter_compass`, `geolocator`, `permission_handler`, `provider`, `http`, `cupertino_icons`
- **Project layout:**
	- `lib/main.dart` — точка входа
	- `lib/screens/` — экраны приложения (game, setup, score, home)
	- `lib/services/` — сервисы работы с локацией, сенсорами и удалёнными запросами
	- `lib/models/` — модели данных (город, сессия, настройки)
	- `lib/widgets/` — переиспользуемые виджеты (компас, таймер и т.д.)

## Future Plans
- Добавить поддержку офлайн-кэша городов и улучшенные подсказки.
- Добавить аналитику и экспорт результатов.
- Локализация интерфейса.

## Setup
Требования: Flutter SDK (рекомендуется последняя стабильная версия), подключённые платформенные SDK (Android SDK / Xcode для iOS).

1) Установить зависимости:

```bash
flutter pub get
```

2) Запуск в отладке (например, Android):

```bash
flutter run
```

3) Сборка релиз-версии

- Android (APK):

```bash
flutter build apk --release
```

Результат: `build/app/outputs/flutter-apk/app-release.apk`

- Android (App Bundle):

```bash
flutter build appbundle --release
```

Результат: `build/app/outputs/bundle/release/app-release.aab`

- iOS (IPA):

```bash
flutter build ipa --release
```

Результат (по умолчанию): `build/ios/ipa/Runner.ipa` — либо используйте Xcode Organizer для экспорта из архива.

- Web:

```bash
flutter build web --release
```

Результат: `build/web/` (статические файлы: `index.html`, `main.dart.js` и т.д.)

- Windows (Desktop):

```bash
flutter build windows --release
```

Результат: `build/windows/runner/Release/` (исполняемый файл и зависимости)

-- Примечания по путям: окончательное расположение файлов зависит от версии Flutter и платформенной конфигурации; указанные пути соответствуют стандартной структуре вывода при сборке через `flutter build`.

Если нужно, добавлю CI-скрипт для автоматической сборки и архивации артефактов.
