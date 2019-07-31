{ pkgs, lib, ... }:

let

  inherit (lib) optionalString maybeEnv;
  inherit (pkgs) tmuxPlugins;
  inherit (pkgs.stdenv) isLinux;

  primaryColor = "magenta";
  secondaryColor = "green";

  resurrect = (tmuxPlugins.resurrect.overrideAttrs (oldAttrs: rec {
    src = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-resurrect";
      rev = "e3f05dd34f396a6f81bd9aa02f168e8bbd99e6b2";
      sha256 = "0w7gn6pjcqqhwlv7qa6kkhb011wcrmzv0msh9z7w2y931hla4ppz";
    };

    patches = [
      ../tmux/resurrect-basename-match-strategy.patch
      ../tmux/resurrect-cmdline-save-strategy.patch
    ];
  }));

  continuum = (tmuxPlugins.continuum.overrideAttrs (oldAttrs: rec {
    dependencies = [ resurrect ];
  }));

in

{
  programs.tmux = {
    enable = true;

    extraConfig = /* tmux */ ''
      # enable mouse support
      set -g mouse on

      set -g status-keys vi
      set -g mode-keys   vi

      set -s escape-time 0
      set -g default-terminal "screen-256color"

      # more logical window splits
      unbind-key "%"
      unbind-key "\""
      bind-key "|" split-window -h -c "#{pane_current_path}"
      bind-key "\\" split-window -v -c "#{pane_current_path}"

      unbind-key "n"
      unbind-key "p"
      bind-key "C-l" last-window
      bind-key -r "C-j" next-window
      bind-key -r "C-k" previous-window

      bind-key -r "h" select-pane -L
      bind-key -r "j" select-pane -D
      bind-key -r "k" select-pane -U
      bind-key -r "l" select-pane -R

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      bind-key -r H resize-pane -L 10
      bind-key -r J resize-pane -D 10
      bind-key -r K resize-pane -U 10
      bind-key -r L resize-pane -R 10

      bind-key -r ">" swap-window -t +1
      bind-key -r "<" swap-window -t -1

      # status line
      #set -g status-right " #(echo ''${SSH_CONNECTION%%%% *}) "
      set -g status-right " "
      set -g status-right-length 30

      #set -g status-left "[#{==:#{session_id},#S} #{session_id}] #h "
      set -g status-left "[#S] #h "
      set -g status-left-length 30

      # Pane resize options
      set -g main-pane-width 127
      set -g main-pane-height 45

      set-option -g pane-active-border-fg bright${secondaryColor}
      set-option -g pane-border-fg brightblack
      set-option -g display-panes-colour ${primaryColor}
      set-option -g display-panes-active-colour brightred
      set-option -g clock-mode-colour brightwhite
      set-option -g mode-bg ${secondaryColor}
      set-option -g mode-fg brightwhite
      set-window-option -g window-status-bg black
      set-window-option -g window-status-fg bright${primaryColor}
      set-window-option -g window-status-current-bg black
      set-window-option -g window-status-current-fg brightwhite
      set-window-option -g window-status-bell-bg black
      set-window-option -g window-status-bell-fg brightred
      set-window-option -g window-status-activity-bg black
      set-window-option -g window-status-activity-fg brightred
      set -g status-bg black
      set -g status-fg bright${secondaryColor}
      set -g message-bg ${secondaryColor}
      set -g message-fg brightwhite
    '';

    plugins = [
      {
        plugin = resurrect;
        extraConfig = /* tmux */ ''
          set -g @resurrect-capture-pane-contents "on"
          set -g @resurrect-processes "mosh-client man '~yarn watch'"
          ${optionalString isLinux /* tmux */ ''
          set -g @resurrect-save-command-strategy "cmdline"
          ''}
          set -g @resurrect-process-match-strategy "basename"
          #set -g @resurrect-strategy-nvim "session"
          #set -g @resurrect-save-shell-history "on"
        '';
      }
      {
        plugin = continuum;
        extraConfig = /* tmux */ ''
          set -g @continuum-save-interval "15"
          set -g @continuum-restore "on"
        '';
      }
    ];
  };
}
