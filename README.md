# Description du projet

C’est un dépôt NixOS en flake pour un parc de machines personnelles. Il décrit des postes (ex5, fw12, lx600, yoga…), un NAS/serveur (n2) et une ISO.

- roles/*.nix : un fichier par machine. Chaque rôle active des modules avec mle.<catégorie>.<nom>.enable = true. flake.nix génère automatiquement une nixosConfiguration par fichier.
- modules/ : environ 105 options mle.*, rangées par catégorie : apps, bundles (groupes de paquets), containers (nspawn et podman), desktop (GNOME, KDE, i3, Hyprland, XFCE), hardware, misc, services. Chaque module suit le même modèle : une option enable puis un mkIf.
- base.nix : socle commun, avec des mkDefault que les rôles peuvent surcharger.
- secrets/ : en réalité un gabarit avec des valeurs factices (UUID aaa/bbb, mot de passe masqué). Les vraies données sont dans un dossier privé qui n’est pas sur GitHub.

Déploiement : le dépôt public est cloné dans /etc/nixos/github, puis github-autosync.sh le copie par rsync vers /etc/nixos/build, qui contient aussi les secrets privés. mlemodules.sh y génère les default.nix d’imports, et hardware-configuration.sh génère la config matérielle de chaque machine. mleupdater déclenche ces scripts à l’activation du système.
