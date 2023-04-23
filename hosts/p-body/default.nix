{
  config,
  modulesPath,
  pkgs,
  guzzle-api-server,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-image.nix")
  ];

  base = {
    documentation.enable = false;
    defaultPackages.enable = false;
  };

  networking = {
    hostName = "p-body";
    firewall = let
      ports = [80 420];
    in {
      allowedUDPPorts = ports;
      allowedTCPPorts = ports;
    };
  };

  programs = {
    git.enable = true;
    vim.defaultEditor = true;
  };

  security = {
    pam.enableSSHAgentAuth = true;
  };

  services = {
    caddy = {
      enable = true;

      email = "getchoo@tuta.io";

      logFormat = ''
        output stdout
        format json
      '';

      extraConfig = ''
        (strip-www) {
        	redir https://{args.0}{uri}
        }

        (common_domain) {
        	encode gzip

        	handle {
        		try_files {path} {path}/
        	}

        	handle_errors {
        		@404 {
        			expression {http.error.status_code} == 404
        		}
        		rewrite @404 /404.html
        		file_server
        	}
        }

        (no_embeds) {
        	header /{args.0} X-Frame-Options DENY
        }

        (container_proxy) {
        	handle_path /{args.0}/* {
        		reverse_proxy {args.1}
        	}
        }
      '';

      globalConfig = ''
        auto_https off
      '';

      virtualHosts = {
        guzzle = rec {
          hostName = "198.199.68.30";
          serverAliases = [
            "www.${hostName}"
          ];
          extraConfig = ''
            root * /var/www
            import common_domain

            file_server

            import container_proxy api :8000
          '';
        };
      };
    };

    endlessh = {
      enable = true;
      port = 22;
      openFirewall = true;
    };

    guzzle-api = {
      enable = true;
      url = "http://198.199.68.30/api/api";
      port = "8000";
      package = guzzle-api-server;
    };

    hercules-ci-agent.enable = true;

    openssh = {
      enable = true;
      passwordAuthentication = false;
      ports = [420];
    };
  };

  system.stateVersion = "22.11";

  users.users = let
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOeEbjzzzwf9Qyl0JorokhraNYG4M2hovyAAaA6jPpM7 seth@glados"
    ];
  in {
    root = {inherit openssh;};
    p-body = {
      extraGroups = ["wheel"];
      isNormalUser = true;
      shell = pkgs.bash;
      passwordFile = config.age.secrets.pbodyPassword.path;
      inherit openssh;
    };
  };
}
