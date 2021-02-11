AUR_bash
---

A simple script in Bash to interact with the Arch User Repository (AUR).

Arguments follow default **pacman** conventions:

```
usage: aur {option} [package]

options:
  -S, --sync           install selected package from AUR
  -Su, --update        update installed packages from AUR
  -Sy, --refresh       check for new package versions in AUR
  -Sw, --download      clone repository files from AUR only
  -Ss, --search        search for packages matching name
  -Sc, -Scc, --clean   remove uninstalled packages
  -R, --remove         remove a package and delete files
  -Q, -Qq, --query     check local installed packages
  -F, --find           find and list packages in AUR
  -w, --web            open AUR package page on web browser
```

Build package dependencies are installed from Arch repositories and then uninstalled.

### Requirements

Requires **package-query** from AUR:
> https://aur.archlinux.org/packages/package-query/

In order to install it, execute:
> $ ./aur.sh -S package-query

Also requires **jq** from *community* repositories.

### Current limitations

* Only installs missing packages from Arch repos with **makepkg**.

* Only accepts a single `package` parameter for now due to lazy arg parsing. ^^"

___

If you liked this, also take a look at: [packages](https://gist.github.com/nelsonaloysio/946528358678dc674c5a694b0db18a3c) (gist).
