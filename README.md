# Volt Launcher

A third-party launcher for RVGL, made in [Flutter](https://flutter.dev).

Designed to be a prettier and more user-friendly, even if heavier, alternative to [RVGL Launcher](https://gitlab.com/re-volt/rvgl-launcher). 

Note: Despite some similarities, this launcher stores data in a file structure different from RVGL Launcher's. You'll have to manually copy saves/settings/local content over if you're migrating from it. Since this is pre-release software, migration to this launcher is not recommended.

## Features

 * Download and update both RVGL and dozens of extra content packs. You can easily install
 all the content you need to play online on the [Re-Volt I/O](https://re-volt.io) community
 or just the original game.
 * Find out about upcoming events in your community without leaving the application.
 Volt Launcher warns you when an event uses content that you don't have or have an
 outdated version of.
 * See the latest news of your community.
 * Add your own sources of packs, events and news, integrating your
 community's content into the launcher.
 * Create multiple launcher profiles or multiple game installs, allowing
 you to separate your configurations for different uses.

## Re-Volt I/O

For convenience, Volt Launcher comes with presets and sources related to [Re-Volt I/O](https://re-volt.io).
This project is not directly related to Re-Volt I/O, it just includes built-in references to it for it's users' convenience, since it's probably the closest to an "official" RVGL community.
Please use the launcher responsibly when interacting with community servers.

## Pre-release Software Warning

This is software still in the alpha stage of development. This means that some instability inherent to software in this stage should be expected. Use at your own risk.

For a more stable RVGL launcher, check out [RVGL Launcher](https://gitlab.com/re-volt/rvgl-launcher).

## Download & Install

In order to keep the bug reports focused on a single OS, at the 
moment only Windows is supported, however Linux support is being worked on.

Since there aren't yet any macOS rvgl packages on the official repository,
macOS support is not being worked on at the moment but planned for the future.

### Windows

 * Download the [latest release](https://github.com/trigonated/voltlauncher/releases/tag/v0.1.0).
 * Extract anywhere you want and run `voltlauncher.exe`.

## Uninstall

### Windows
 * Remove the `%LOCALAPPDATA%\VoltLauncher` directory.
 * Delete the directory containing `voltlauncher.exe`.

---

## Development

This is a [Flutter](https://flutter.dev) desktop project written in Dart. Visit the [Desktop support for Flutter](https://flutter.dev/desktop) 
page for information on requirements and how to build this project.

### Planned Features

 * Linux support
 * macOS support
 * Localization support
 * Intro page
 * Support for content sources based on a new Volt Launcher format, allowing for
 extra features. (Currently, only sources based on the Re-Volt I/O APIs can be used)
 * Support for optional extra Volt Launcher data on Re-Volt I/O API content
 * Better support for news, current support is very limited
 * Changing the location of the game installs, allowing sharing an install
 between operating systems
 * Easy-to-use installers
 * Portable version of the launcher (e.g. to store in an usb-stick)
 * Notifications
 * Manage RVGL content of a connected Android device (might not be currently possible)

 Note: Not all of these features are planned to be implemented for the "final" release, 
 some are planned for later versions.

### Project structure

General structure of the project. Not everything is represented here.

 * `/graphics`: Graphical assets used by the app.
    * `/events`: Event thumbnails.
    * `/news`: News thumbnails.
    * `/presets`: Presets thumbnails.
 * `/lib`: Source-code of the app.
    * `/misc`: Miscellaneous stuff.
    * `/model`: Contains APIs, repositories, etc.
        * `/apis`: different APIs supported by the app (as sources).
        * `/misc`: Miscellaneous stuff.
        * `/objects`: Data objects.
        * `/repositories`: Repositories, organized by "type".
    * `/ui`: UI-related code.
        * `/misc`: Miscellaneous UI stuff.
        * `/newprofile`: The "Create new profile" page.
        * `/profile`: The main page of the app, with it's tabs.
        * `/settings`: The settings page.
 * `/window_control`: Windows-only plugin that allows building a custom window frame using Win32 APIs.

The entry point of the app is located in `/lib/main.dart`, but the initial page is created
in `/lib/ui/voltlauncherapp.dart`.