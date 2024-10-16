{pkgs, ...}: {
  home.packages = with pkgs; [
    discord
    teamspeak_client
    mumble
    prismlauncher
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      #obs-vkcapture
      obs-pipewire-audio-capture
      input-overlay
    ];
  };
}
