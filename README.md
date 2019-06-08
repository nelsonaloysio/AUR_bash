AUR_bash
---

A simple script in bash to interact with the Arch User Repository (AUR).

Arguments follow default conventions

```
usage: aur {option} [package] [arg]

options:
  -S, --sync           install selected package from AUR
  -Su, --update        update installed packages from AUR
  -Sy, --refresh       check for new package versions in AUR
  -Sw, --download      clone repository files from AUR only
  -Ss, --search        search for packages matching name
  -Sc, -Scc, --clean   remove uninstalled packages
  -R, --remove         remove a package and delete files
  -Q, --query          check local installed packages
  -F, --find           find and list packages in AUR
```

Package dependencies are installed from ```pacman``` and then uninstalled.

### Requirements

Requires "package-query" from AUR:
> https://aur.archlinux.org/packages/package-query/

To install it, run:
> $ ./aur.sh package-query

### Current limitations

* Only installs missing packages from Arch repos due to ```makepkg```.

* Only accepts a single ```package``` for now due to lazy arg parsing. ^^"