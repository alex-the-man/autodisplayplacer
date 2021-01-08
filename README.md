# autodisplayplacer
A Mac OS X application to call displayplacer automatically when external displays are plugged in or removed.

[displayplacer](https://github.com/jakehilborn/displayplacer) is a macOS command line utility to configure multi-display resolutions and arrangement.

Mac OS's multiple monitors management is flawed. Mac OS doesn't look at the serial numbers of the displays. If multiple identical monitors are connected to the computer with the same connection type (e.g. Thunderbolt), Mac OS cannot distingish them. If the monitors are plugged in at the exact same time (e.g. via a dock), Mac OS might mix up the display identities and hence mess up the display arragement (e.g. left/right flipped).

This application is designed to call `displayplacer` to reset the display arragement when display(s) are plugged in/out.

## Usage
The application listens for changes of display devices when it's running. When display is plugged in/out, it executes a configuable command. 
To configure the command, please open the __Preferences__ window:

![Status Bar](/docs/menu.png)

The application supports arbitrary command. In most cases, it should call displayplacer to set the proper display arragement. After configuring the display arragment using the Display pane of Displays System Preferences, run `displayplacer list` to dump the current arragement:

![Put displayplacer list in Command then hit Execute](/docs/pref-list.png)

Note: The App Bundle comes with a pre-built displayplacer. You don't need to install `displayplacer` separately.

Then paste the command dumped by `displayplacer list` and hit __Save__.

![Hit Save](/docs/pref-save.png)

## Troubleshooting
You could use the Console App to collect the application log for troubleshooting.

## Credits
- [displayplacer](https://github.com/jakehilborn/displayplacer)
- [tabler-icons](https://github.com/tabler/tabler-icons)
