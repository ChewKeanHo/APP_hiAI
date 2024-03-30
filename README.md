# Holloway's HiAI
[![hiAI](src/icons/banner_1200x330.svg)](#holloways-hiai)

A local terminal polygot (POSIX Shell x PowerShell) bridging LLM AI prompt
interaction capabilities.

Turn every computer's terminal into an interactive AI prompt.

[![hiAi-demo-debian](src/screenshots/hiAI-demo-debian.gif)](#holloways-hiai)




## Why It Matters

Some good business reasons why using AutomataCI:

1. **Use AI prompt straight from the terminal** - No need to visit here and
   there just to use AI prompt.
2. **Simple and straight forward** - Frankly, it's created to resolve some AI
    prompt's buggy UI.
3. **Steadily improvable** - Will continue to improve over time.
4. **Programmable** - I'm so done with copy-pasting prompt constructors.




## How-tos, Documentations & Specifications

To use HiAI, you need to first setup 1-time `CONFIG.toml` file:

```
# UNIX (Linux & MacOS) - POSIX Shell
$ ./hiAI.sh.ps1 --create-config path/to/file.toml

# WINDOWS - PowerShell
$ powershell.exe -noprofile `
	-executionpolicy bypass `
	-Command "& .\hiAI.sh.ps1 --create-config 'path\to\file.toml'"


# update the path/to/file.toml especially with the API token.
```

Once done, you may proceed to execute it:

```
# UNIX (Linux & MacOS) - POSIX Shell
$ hiAI.sh.ps1 --config path/to/file.toml --text2text "...your prompt..."


# WINDOWS - PowerShell
$ powershell.exe -noprofile `
	-executionpolicy bypass `
	-Command "& .\hiAI.sh.ps1 --config path\to\file.toml --text2text `"...your prompt...`""
```

In any cases, if you need an on-screen assistances:
```
# UNIX (Linux & MacOS) - POSIX Shell
$ hiAI.sh.ps1 --help


# WINDOWS - PowerShell
$ powershell.exe -noprofile `
	-executionpolicy bypass `
	-Command "& .\hiAI.sh.ps1 --help"
```




## To Contribute

AutomataCI cannot be made successfully without contributions from (Holloway)
Chew, Kean Ho, his teams, and supports from external folks. If you had been
using AutomataCI and wish to contribute back, there are 2 ways to do so:



### Financial

To financially support the project, please head over to Holloway's sponorship
store here:

[![Sponsor](.github/images/sponsor_en_210x50.svg)](https://github.com/sponsors/hollowaykeanho)

A small token purchase would helps a lot.



### Craftmanship

If you wish to bring in codes contribution, bug report, and ideas, please feel
free to refer the PDF Handbook and execute accordingly.




## License
AutomataCI is licensed under OSI compatible [Apache 2.0 License](LICENSE.txt).
