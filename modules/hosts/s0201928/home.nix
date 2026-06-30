{ self, inputs, ... }: {
  # this is the standalone config for non-NixOS systems
  flake.homeConfigurations."jonas.weissensel" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; };
    modules = [
      self.homeModules.joweisseModule
      {
        home.username = "jonas.weissensel";
        home.homeDirectory = "/home/jonas.weissensel";
      }
    ];
  };
  flake.homeConfigurations.joweisse = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    modules = [
      self.homeModules.joweisseModule
      {
        home.username = "joweisse";
        home.homeDirectory = "/home/joweisse";
      }
    ];
  };

  # this is your home.nix
  flake.homeModules.joweisseModule =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        self.homeModules.noctalia
      ];
      programs = {
        bat.enable = true;
        dircolors.enable = true;
        direnv = {
          enable = true;
          stdlib = ''
              # source: https://github.com/direnv/direnv/wiki/Customizing-cache-location#human-readable-directories
            	: ''${XDG_CACHE_HOME:=$HOME/.cache}
            	declare -A direnv_layout_dirs
            	direnv_layout_dir() {
            		echo "''${direnv_layout_dirs[$PWD]:=$(
            			local hash="$(shasum -a 1 - <<<"''${PWD}" | cut -c-7)"
            			local path="''${PWD//[^a-zA-Z0-9]/-}"
            			echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
            		)}"
            	}
            	layout_uv() {
            	  local python_version=$1
            	  if [[ -z $python_version ]]; then
            	      log_error "Missing pinned python_version. Expected to find something like 'layout_uv 3.12'."
            	      exit 2
            	  fi
            	  [[ $# -gt 0 ]] && shift
            	  unset PYTHONHOME
            	  local pinned_python_version=$(uv python pin --resolved)
            	  if [[ -z $pinned_python_version ]]; then
            	      uv python pin $python_version
            	  fi
            	  export VIRTUAL_ENV=$PWD/.venv
            	  if [[ ! -d "$VIRTUAL_ENV" ]]; then
            	    uv venv "$VIRTUAL_ENV"
            	  fi
            	  PATH_add "$VIRTUAL_ENV/bin"
            	}
            	encrypted_ssm_cached() {
                	local env_var_name="$1"
                	local parameter_name="$2"
                	local default_value="''${3:-}"
                	local cache_file=".envrc.local"
                	local timestamp_marker="# SSM_TIMESTAMP_''${env_var_name}="
                	local max_age_seconds=$((8 * 60 * 60)) # 8 hours in seconds

                	# Create cache file if it doesn't exist
                	touch "$cache_file"

                	# Check if we have a cached timestamp
                	local timestamp_line=$(grep "^''${timestamp_marker}" "$cache_file" 2>/dev/null || echo "''${timestamp_marker}0")
                	local timestamp=''${timestamp_line#"$timestamp_marker"}

                	# Calculate age of cached value
                	local current_time=$(date +%s)
                	local age=$((current_time - timestamp))

                	# Check if we need to fetch a new value
                	if [ "$age" -gt "$max_age_seconds" ] || ! grep -q "^export ''${env_var_name}=" "$cache_file" 2>/dev/null; then
                		echo "Fetching $parameter_name from AWS SSM..."

                		# Cache is too old or doesn't exist, fetch new value from SSM
                		local parameter_value
                		parameter_value=$(aws ssm get-parameter --name "$parameter_name" --with-decryption --query "Parameter.Value" --output text 2>/dev/null)
                		local ssm_status=$?
                		echo "Status of awscli: ''${ssm_status}"

                		# Check if SSM call was successful
                		if [ $ssm_status -ne 0 ]; then
                			# If SSM call fails, use default value if provided
                			if [ -n "$default_value" ]; then
                				parameter_value="$default_value"
                				echo "Using default value for $parameter_name"
                			else
                				echo "Error: Failed to retrieve parameter '$parameter_name' from SSM and no default value provided."
                				return 1
                			fi
                		fi

                		# Update cache file
                		local temp_file="''${cache_file}.tmp"

                		# Create a new file with updated values
                		touch "$temp_file"
                		if [ -f "$cache_file" ]; then
                			# Copy existing content except for this variable and its timestamp
                			grep -v "^export ''${env_var_name}=" "$cache_file" | grep -v "^''${timestamp_marker}" >"$temp_file" || true
                		fi

                		# Add the updated timestamp and export lines
                		echo "''${timestamp_marker}''${current_time}" >>"$temp_file"
                		echo "export ''${env_var_name}=\"''${parameter_value}\"" >>"$temp_file"

                		# Replace cache file with updated version
                		mv "$temp_file" "$cache_file"
                	else
                		echo "Using cached value for $parameter_name (expires in $((max_age_seconds - age)) seconds)"
                	fi
                }
          '';
          nix-direnv.enable = true;
        };
        firefox = {
          enable = true;
          package = pkgs.firefox-devedition;
        };
        fish = {
          enable = true;
          interactiveShellInit = ''
            bind alt-w 'git_switch_branch'
          '';
          shellInitLast = "";
          shellAbbrs = {
            e = "nvim";
            l = "ls -F";
            g = "git status";
            gb = "gh browse";
            gha = "xdg-open (gh browse -n)'/actions'";
          };
          plugins = [
            {
              name = "hydro";
              src = pkgs.fetchFromGitHub {
                owner = "jorgebucaran";
                repo = "hydro";
                rev = "f130b55ee3eaf099eccf588e2a62e5447068d120";
                sha256 = "sha256-8ixve1ws80q5jNdKoooL25Lk7qopVitCMVTucW490fU=";
              };
            }
            {
              name = "bass";
              src = pkgs.fetchFromGitHub {
                owner = "edc";
                repo = "bass";
                rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
                sha256 = "3d/qL+hovNA4VMWZ0n1L+dSM1lcz7P5CQJyy+/8exTc=";
              };
            }
            {
              name = "spark";
              src = pkgs.fetchFromGitHub {
                owner = "jorgebucaran";
                repo = "spark.fish";
                rev = "1.2.0";
                sha256 = "AIFj7lz+QnqXGMBCfLucVwoBR3dcT0sLNPrQxA5qTuU=";
              };
            }
            {
              name = "projectdo";
              src = pkgs.fetchFromGitHub {
                owner = "paldepind";
                repo = "projectdo";
                rev = "v1.0.0";
                sha256 = "sha256-bdSwpfHipL1fuXjvVifaKNV477JENYu7SxKMpk3ZP6o=";
              };
            }
            {
              name = "gitnow";
              src = pkgs.fetchFromGitHub {
                owner = "joseluisq";
                repo = "gitnow";
                rev = "2.13.0";
                sha256 = "sha256-F0dTu/4XNvmDfxLRJ+dbkmhB3a8aLmbHuI3Yq2XmxoI=";
              };
            }
            # {
            #   name = "paws";
            #   src =
            #     let
            #       paws = pkgs.stdenv.mkDerivation {
            #         pname = "paws";
            #         version = "1";
            #         src = fetchGit {
            #           url = "ssh://git@github.com/otto-ec/seo_paws.git";
            #           ref = "main";
            #           rev = "829b4fdb74d3613c5c2af4f718243fc399074306";
            #         };
            #         nativeBuildInputs = [ pkgs.jq ];
            #         dontUnpack = true;
            #         dontConfigure = true;
            #         dontBuild = true;
            #         installPhase = ''
            #           mkdir -p $out/{completions,functions}
            #           mkdir -p $out/opt
            #           install -m 755 $src/paws/paws.sh $out/opt/paws.sh
            #           install -m 755 $src/paws-fish/functions/paws.fish $out/functions/paws.fish
            #           install -m 755 $src/paws-fish/completions/paws.fish $out/completions/paws.fish

            #           patchShebangs --host $out/opt/paws.sh
            #           substituteInPlace $out/functions/paws.fish --replace /opt $out/opt
            #         '';
            #       };
            #     in
            #     "${paws}";
            # }
          ];
          functions = {
            github_copilot_remaining_token_quota = {
              description = "Use the gh cli to fetch the quota of remaining tokens";
              body = ''
                gh api copilot_internal/user | jq '.quota_snapshots.premium_interactions|.remaining/.entitlement'
              '';
            };
            git_switch_branch = {
              description = "Use fzf to switch git branch";
              body = ''
                set -l target_branch (git branch --all --list | \
                  fzf --prompt "Choose branch: " |\
                  string replace "remotes/origin/" "" |\
                  string trim)
                if test "$target_branch"
                  git switch $target_branch
                  commandline -f repaint
                end
              '';
            };
            login-to-ecr = {
              description = "Login to AWS ECR";
              body = ''
                fish --private --command "aws ecr get-login-password --profile $AWS_PROFILE --region eu-central-1 | docker login --username AWS --password-stdin $ACCOUNT_INFRASTRUCTURE.dkr.ecr.eu-central-1.amazonaws.com"
              '';
            };
            # fancy_clear = {
            #   description = "A fancy terminal clearing";
            #   body = ''
            #     command clear
            #     seq 1 (tput cols) | sort --random-sort | spark | ${pkgs.lolcrab}/bin/lolcrab
            #     commandline -f repaint
            #   '';
            # };
            make_dict = {
              argumentNames = [ "dict_name" ];
              body = ''
                set -l keys_var "$dict_name"_keys
                if set -q $keys_var
                    for key in $$keys_var
                        set -e "$dict_name"_$key
                    end
                end
                set -e $keys_var

                while read -l line
                    if not string length -q -- (string trim $line)
                        continue
                    end
                    set -l parts (string match -r "^(\S+)\s+(.*)\$" $line)
                    if test (count $parts) -eq 3
                        set -l key $parts[2]
                        set -l value $parts[3]
                        set -g $keys_var $$keys_var $key
                        set -g "$dict_name"_$key $value
                    end
                end
              '';
            };
            get_active_coauthors = {
              body = ''
                set -l keys_var "team_dict_keys"
                if not set -q $keys_var
                    git mob team-member --list | make_dict team_dict
                end

                set -l active_coauthors
                for coauthor in (git mob -l)
                    for key in $$keys_var
                        set -l val_var "team_dict_$key"
                        if test "$$val_var" = "$coauthor"
                            set -a active_coauthors $key
                            break
                        end
                    end
                end

                if test (count $active_coauthors) -gt 0
                    string join ", " $active_coauthors
                end
              '';
            };
            fish_right_prompt = {
              body = ''
                # set -l coauthors (get_active_coauthors)
                # if test -n "$coauthors"
                  # set_color yellow
                  # echo -n "<mob: $coauthors>"
                  # set_color normal
                # end

                set -l local_aws_profile (
                  if test -n "$AWS_PROFILE"
                    echo -n "[$AWS_PROFILE]"
                  end
                )

                set -q VIRTUAL_ENV_DISABLE_PROMPT
                or set -g VIRTUAL_ENV_DISABLE_PROMPT true
                set -q VIRTUAL_ENV
                and set -l venv "py:"(string replace -r '.*/' "" -- "$VIRTUAL_ENV")

                set_color reset
                string join " " -- $venv (set_color bryellow) $local_aws_profile (set_color normal)
              '';
            };
            fish_greeting = "";
          };
        };
        fd.enable = true;
        fzf.enable = true;
        difftastic.enable = true;
        difftastic.git.enable = true;
        ghostty = {
          enable = true;
          settings = {
            font-family = "Terminess Nerd Font Mono";
            font-size = 14;
            window-decoration = "none";
            theme = "Smyck";
          };
        };
        git = {
          signing = {
            key = "~/.ssh/id_ed25519";
            signByDefault = builtins.stringLength "~/.ssh/id_ed25519" > 0;
          };
          enable = true;
          settings = {
            user.name = "Jonas Weissensel";
            user.email = "Jonas.Weissensel@otto.de";
            init.defaultBranch = "main";
            gpg.format = "ssh";
            gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
            pull.rebase = true;
            rebase.autoStash = true;
            core.attributesfile = "~/.gitattributes";
            core.hooksPath = "~/.config/git/hooks";
            # coauthors = {
            #   tb = "Tobias Adams <tobias.adams@otto.de>";
            #   sd = "Simon Dose <simon.dose@otto.de";
            #   sve = "Svante von Erichsen <svante.vonerichsen@otto.de>";
            #   lv = "Luis Vidal <luis.vidal@otto.de>";
            #   jd = "Jim Duden <jim.duden@otto.de>";
            #   jh = "Joscha Harpeng <joscha.harpeng@otto.de>";
            # };
          };
          ignores = [
            ".direnv"
            ".helix"
            ".vscode"
            ".dist"
            ".build"
            "dist"
            "build"
            "result"
            "target"
            ".clj-kondo/.cache"
            ".clj-kondo/imports"
            ".DS_Store"
            ".envrc"
            ".env.*"
          ];
        };
        gpg = {
          enable = true;
          scdaemonSettings.disable-ccid = true;
          settings = {
            default-cache-ttl = "3600";
            default-cache-ttl-ssh = "3600";
            max-cache-ttl = "7200";
            max-cache-ttl-ssh = "7200";
          };
        };
        helix = {
          enable = true;
          extraPackages = [
            # pkgs.basedpyright
            pkgs.ty
            pkgs.clj-kondo
            pkgs.lazygit
            # pkgs.marksman # for markdown
            pkgs.nixfmt
            # pkgs.nodePackages.bash-language-server
            pkgs.ruff
            pkgs.shfmt
            pkgs.taplo # for toml
            pkgs.terraform-ls
            pkgs.zk
            (pkgs.python3.withPackages (ps: [
              ps.rope
            ]))
          ];

          languages = {
            language-server = {
              zk = {
                command = "zk";
                args = [ "lsp" ];
              };
              ruff = {
                command = "ruff";
                args = [
                  "server"
                  "--preview"
                ];
              };
            };
            language = [
              {
                name = "fish";
                formatter = {
                  command = "fish_indent";
                };
                auto-format = true;
              }
              {
                name = "nix";
                auto-format = true;
                formatter = {
                  command = "nixfmt";
                };
              }
              {
                name = "markdown";
                file-types = [
                  "md"
                  "markdown"
                ];
                injection-regex = "md|markdown";
                # roots = [".zk"];
                language-servers = [
                  # {name = "zk";}
                  { name = "marksman"; }
                ];
              }
              {
                name = "bash";
                auto-format = true;
                indent = {
                  tab-width = 2;
                  unit = "  ";
                };
                formatter = {
                  command = "${pkgs.shfmt}/bin/shfmt";
                  args = [
                    "-i"
                    "2"
                  ];
                };
              }
              {
                name = "python";
                auto-format = true;
                language-servers = [
                  { name = "basedpyright"; }
                  { name = "ruff"; }
                ];
              }
            ];
          };
          settings = {
            theme = "everforest_dark";
            editor = {
              bufferline = "multiple";
              idle-timeout = 0;
              file-picker.hidden = false; # ignore hidden files: false
              lsp.display-messages = true;
              lsp.display-inlay-hints = true;
              statusline = {
                left = [
                  "mode"
                  "spinner"
                ];
                center = [ "file-name" ];
                right = [
                  "diagnostics"
                  "selections"
                  "position"
                  "version-control"
                  "file-encoding"
                  "file-line-ending"
                  "file-type"
                ];
              };
            };
            keys.normal = {
              space.space = ":reload-all";
              ";".";" = "command_mode";
              ";".w = ":w";
              ";".W = ":wa";
              ";".q = ":q";
              ";".Q = ":qa";
              ";".x = ":wq";
              ";".X = ":wq";
              g.q = ":reflow";
              # "C-g" = '':sh tmux popup -d "#{pane_current_path}" -xC -yC -w80% -h80% -E lazygit'';
            };
          };
        };
        jq.enable = true;
        kitty = {
          enable = true;
          autoThemeFiles = {
            dark = "Alabaster_Dark";
            light = "Alabaster_Dark";
            noPreference = "Alabaster_Dark";
          };
          font = {
            name = "Terminess Nerd Font Mono";
            size = 14;
          };
          settings = {
            scrollback_lines = 100000;
          };
        };
        lazygit = {
          enable = true;
          settings = {
            git.overrideGpg = true;
            gui.theme = {
              activeBorderColor = [
                "#89b4fa"
                "bold"
              ];
              inactiveBorderColor = [ "#a6adc8" ];
              optionsTextColor = [ "#89b4fa" ];
              # selectedLineBgColor = [ "#313244" ];
              selectedLineBgColor = [ "#1e1e2e" ];
              cherryPickedCommitBgColor = [ "#45475a" ];
              cherryPickedCommitFgColor = [ "#89b4fa" ];
              unstagedChangesColor = [ "#f38ba8" ];
              defaultFgColor = [ "#cdd6f4" ];
              searchingActiveBorderColor = [ "#f9e2af" ];
            };
          };
        };
        eza = {
          enable = true;
          git = true;
          icons = "auto";
        };
        mcp = {
          enable = true;
          servers = {
            # code-review-graph = {
            #   command = "code-review-graph";
            #   args = [ "serve" ];
            # }
          };
        };
        mergiraf = {
          enable = true;
          enableGitIntegration = true;
        };
        neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          extraLuaPackages = luaPkgs: [ luaPkgs.fennel ];
          extraPython3Packages =
            pythonPkgs: with pythonPkgs; [
              rope
              mccabe
              pynvim
              ty
            ];
          extraPackages = [ ];
        };
        opencode = {
          enable = true;
          settings = {
            default_agent = "plan";
            enabled_providers = [ "github-copilot" ];
            share = "disabled";
            instructions =
              let
                caveman = pkgs.writeText "caveman-rule.md" ''
                  Respond terse like smart caveman. All technical substance stay. Only fluff die.

                  Rules:
                  - Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
                  - Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
                  - Pattern: [thing] [action] [reason]. [next step].
                  - Not: "Sure! I'd be happy to help you with that."
                  - Yes: "Bug in auth middleware. Fix:"

                  Switch level: /caveman lite|full|ultra|wenyan
                  Stop: "stop caveman" or "normal mode"

                  Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

                  Boundaries: code/commits/PRs written normal.
                '';
              in
              [ "${caveman}" ];
            # command = { };
            permission = {
              doom_loop = "deny";
              external_directory = {
                "*" = "deny";
                "~/Code/*" = "ask";
                "~/Documents/*" = "deny";
              };
              read = {
                "*" = "allow";
                "*.env" = "deny";
                "*.env*" = "deny";
                "*.envrc*" = "deny";
                "*.env.json" = "deny";
                "~/.ssh/*" = "deny";
              };
              bash = {
                "*" = "ask";
                "brew *" = "deny";
                "git *" = "allow";
                "git push *" = "deny";
                "git rm *" = "deny";
                "npm *" = "deny";
                "npx *" = "deny";
                "find * --exec *" = "deny";
              };
            };
          };
          enableMcpIntegration = true;
        };
        ruff.enable = true;
        tmux = {
          enable = true;
          clock24 = true;
          historyLimit = 100000;
          mouse = true;
          terminal = "tmux-256color";
          plugins = with pkgs.tmuxPlugins; [
            better-mouse-mode
            extrakto
            catppuccin
            tmux-fzf
          ];
          escapeTime = 15;
          extraConfig = ''
            bind r 'source-file $HOME/.config/tmux/tmux.conf; display "Reloaded tmux.conf"'
            set -g @catppuccin_date_time "%Y-%m-%d %H:%M"
          '';
        };
        yazi.enable = true;
        zoxide.enable = true;
      };

      home = {
        stateVersion = "26.05";
        sessionVariables = {
          AWS_REGION = "eu-central-1";
          BAT_THEME = "1337";
          # DOCKER_HOST = "unix://\${HOME}/.config/colima/docker.sock";
          EDITOR = "nvim";
          # GODEBUG = "asyncpreemptoff=1";
          # PAWS_MFA_AWS_USER = "joweisse";
          # PAWS_SSO_SESSION_NAME = "otto-sso";
          SHELL = "${lib.getExe config.programs.fish.package}";
          TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock";
          ZK_NOTEBOOK_DIR = "\${HOME}/Documents/zk";
        };
        sessionPath = [ "$HOME/.local/bin" ];
        file = {
          ".m2/settings.xml" = {
            enable = true;
            text = ''
              <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                                    http://maven.apache.org/xsd/settings-1.0.0.xsd">
                <servers>
                  <server>
                    <id>github</id>
                    <username>must-not-be-empty</username>
                    <password>''${env.GITHUB_TOKEN}</password>
                  </server>
                </servers>
              </settings>
            '';
          };
        };

        packages = with pkgs; [
          #genAI
          rtk

          # tools
          localsend

          # fonts
          nerd-fonts.blex-mono
          nerd-fonts.terminess-ttf
          atkinson-monolegible
          atkinson-hyperlegible
          font-awesome
          fixedsys-excelsior

          # cli
          acli
          age-plugin-yubikey
          amazon-ecr-credential-helper
          awscli2
          bash-language-server
          babashka
          chromedriver
          clj-kondo
          cljfmt
          clojure
          clojure-lsp
          docker-credential-helpers
          eslint
          fennel-ls
          fnlfmt
          git-extras
          github-cli
          jdk
          jless
          just
          leiningen
          lua51Packages.fennel
          lua51Packages.luarocks
          nh
          nil
          nix-prefetch-git
          nixd
          nixfmt
          nodejs
          pnpm
          polylith
          pre-commit
          ripgrep
          shellcheck
          shfmt
          ssm-session-manager-plugin
          terraform
          terraform-docs
          tflint
          uv
          wireguard-tools
          yubikey-manager
          cljfmt
          clojure-lsp
          dhall-lsp-server
          editorconfig-checker
          fennel-ls
          gopls
          lua-language-server
          luajit
          marksman
          nginx-language-server
          nixfmt
          nls
          ruff
          shellcheck
          shfmt
          sleek
          svelte-language-server
          terraform-ls
          yaml-language-server
          zprint
          self.packages.${pkgs.stdenv.hostPlatform.system}.git-mob
        ];

      };

    };
}
