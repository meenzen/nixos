{pkgs, ...}: {
  services.anubis.package = pkgs.anubis.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      +
      # The Anubis defaults are too lenient, make everything difficulty 5
      # see https://github.com/TecharoHQ/anubis/blob/main/data/botPolicies.yaml
      #
      # Some Chinese scrapers have weight 10 and pass difficulty 5 challenges
      # but at least this way they're wasting ~10 seconds of CPU time per scraped
      # page.
      ''
        substituteInPlace data/botPolicies.yaml \
          --replace-fail 'difficulty: 1' 'difficulty: 5' \
          --replace-fail 'difficulty: 2' 'difficulty: 5' \
          --replace-fail 'difficulty: 4' 'difficulty: 5'
      '';
  });
}
