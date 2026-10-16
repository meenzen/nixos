{
  nix.settings = {
    substituters = [
      "https://attic.mnzn.dev/main"
      "https://attic.human-dev.io/human"
    ];
    trusted-public-keys = [
      "main:S8Ire6opydyGvlK4PI03t1UIwFsYJqKvn6EJrY4EoNA="
      "human:TFU+2BTCP6U2cZwUJ9iKGCJvsuRwe/alCqrN9TjgN/4="
    ];
  };
}
