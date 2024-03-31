# Holloway's HiAI
[![hollowayHIAI](src/icons/banner_1200x330.svg)](#holloways-hiai)

A local terminal polygot (POSIX Shell x PowerShell) bridging LLM AI prompt
interaction capabilities directly to your computer!

Turn every computer's terminal into an interactive AI prompt.

[![hollowayHIAI-demo-debian](src/screenshots/hiAI-demo-debian.gif)](#holloways-hiai)




## Why It Matters

Some good business reasons why using AutomataCI:

1. **Use AI prompt straight from the terminal** - No need to visit here and
   there just to use AI prompt.
2. **Simple and straight forward** - Frankly, it's created to resolve some AI
    prompt's buggy UI.
3. **Steadily improvable** - Will continue to improve over time.
4. **Programmable** - I'm so done with copy-pasting prompt constructors.




## Supported AI Vendors

1. [Google AI](https://ai.google.dev/docs/gemini_api_overview) - [Get API Token](https://gemini.google.com/app)




## To Install

The software is packaged based on available OSes.



### Debian-based OS (`linux`, `hurd`, etc)

1. Download the latest `.deb` package from the [release section](https://github.com/ChewKeanHo/APP_hiAI/releases)
2. perform `$ dpkg -i <package>.deb`.

Don't worry, the package will setup the upstream apt repository list source
alongside the required GPG key for future `apt update`.



### Red-Hat Linux (`redhat`, `fedora`, etc)

1. Download the latest `.rpm` package from the [release section](https://github.com/ChewKeanHo/APP_hiAI/releases)
2. perform `$ rpm -i <package>.rpm`.

Don't worry, the package will setup the upstream apt repository list source
alongside the required GPG key for future `apt update`.



### Flatpak

*Coming Soon*

Note that the command to use is: `flatpak run [TBD] ...` due to how Flatpak
works.



### Docker / Podman

Please refer to [GitHub Packages Section](https://github.com/ChewKeanHo/APP_hiAI/pkgs/container/hollowayhiai).



### Plain Script / Windows

Use the `tar.gz` package or `zip` package on Windows OS.

Note that the command to use is: `hollowayhiai_[OS]-[ARCH].sh.ps1` instead of
the `hollowayHIAI` sine you're executing directly from the script.



### Homebrew

*Coming Soon*



### Chocolatey (Windows)

*Coming Soon*




## How-tos, Documentations & Specifications

To use HiAI, you need to first setup 1-time `CONFIG.toml` file:

```
# UNIX (Linux & MacOS) - POSIX Shell
$ hollowayHIAI --create-config path/to/file.toml

# WINDOWS - PowerShell
$ powershell.exe -noprofile `
	-executionpolicy bypass `
	-Command "& .\hollowayhiai_windows-[ARCH].sh.ps1 --create-config 'path\to\file.toml'"


# update the path/to/file.toml especially with the API token.
```

Once done, you may proceed to execute it:

```
# UNIX (Linux & MacOS) - POSIX Shell
$ hollowayHIAI --config path/to/file.toml --text2text "...your prompt..."


# WINDOWS - PowerShell
$ powershell.exe -noprofile `
	-executionpolicy bypass `
	-Command "& .\hollowayhiai_windows-[ARCH].sh.ps1 --config path\to\file.toml --text2text `"...your prompt...`""
```

In any cases, if you need an on-screen assistances:
```
# UNIX (Linux & MacOS) - POSIX Shell
$ hollowayHIAI --help


# WINDOWS - PowerShell
$ powershell.exe -noprofile `
	-executionpolicy bypass `
	-Command "& .\hollowayhiai_windows-[ARCH].sh.ps1 --help"
```




## To Contribute

Holloway's HiAI! cannot be made successfully without contributions from
(Holloway) Chew, Kean Ho, his teams, and supports from external folks. If you
had been using it and wish to contribute back, there are 2 ways to do so:



### Financial

To financially support the project, please head over to Holloway's sponorship
store here:

[![Sponsor](.github/images/sponsor_en_210x50.svg)](https://github.com/sponsors/hollowaykeanho)

A small token purchase would helps a lot.



### Craftmanship

If you wish to bring in codes contribution, bug report, and ideas, please feel
free to refer the PDF Handbook and execute accordingly.



### Special Thanks

Special thanks to:

1. [Google](https://gemini.google.com/) for sponsoring its
[Google Gemini Advanced Ultra](https://ai.google.dev/pricing) services
for making this app possible.




## License
Holloway's HiAI! is licensed under OSI compatible
[Apache 2.0 License](LICENSE.txt).
