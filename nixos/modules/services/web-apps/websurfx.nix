{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.websurfx;
  settingsFormat = pkgs.formats.lua { asBindings = true; };
  settingsFile = settingsFormat.generate "config.lua" cfg.settings;
in
{
  options = {
    services.websurfx = {
      enable = lib.mkEnableOption "Websurfx, a metasearch engine";
      package = lib.mkPackageOption pkgs "websurfx" { };
      openFirewall = lib.mkEnableOption "Whether to open the used port in the firewall";
      redis.createLocally = lib.mkEnableOption "Configure local redis server for websurfx" // {
        default = true;
      };
      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;

          options.binding_ip = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = ''
              ip address on the which server should be launched
            '';
          };
          options.port = lib.mkOption {
            type = lib.types.port;
            default = 4567;
            description = ''
              port on which server should be launched
            '';
          };
        };
        default = { };
        description = ''
          Configuration options for Websurfx, see
          [websurfx/config.lua](https://github.com/neon-mmd/websurfx/blob/rolling/websurfx/config.lua)
          for supported values.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.websurfx.settings = {
      logging = lib.mkDefault true;
      debug = lib.mkDefault false;
      threads = lib.mkDefault 10;

      production_use = lib.mkDefault false;

      request_timeout = lib.mkDefault 30;
      tcp_connection_keep_alive = lib.mkDefault 30;
      pool_idle_connection_timeout = lib.mkDefault 30;
      rate_limiter = {
        number_of_requests = lib.mkDefault 20;
        time_limit = lib.mkDefault 3;
      };
      https_adaptive_window_size = lib.mkDefault true;
      operating_system_tls_certificates = lib.mkDefault true;
      number_of_https_connections = lib.mkDefault 10;
      client_connection_keep_alive = lib.mkDefault 120;
      safe_search = lib.mkDefault 2;

      colorscheme = lib.mkDefault "catppuccin-mocha";
      theme = lib.mkDefault "simple";
      animation = lib.mkDefault "simple-frosted-glow";

      redis_url = lib.mkIf cfg.redis.createLocally "redis://${config.services.redis.servers.websurfx.unixSocket}";
      cache_expiry_time = lib.mkDefault 600;

      upstream_search_engines = {
        DuckDuckGo = lib.mkDefault true;
        Searx = lib.mkDefault false;
        Brave = lib.mkDefault false;
        Startpage = lib.mkDefault false;
        LibreX = lib.mkDefault false;
        Mojeek = lib.mkDefault false;
        Bing = lib.mkDefault false;
        Wikipedia = lib.mkDefault true;
        Yahoo = lib.mkDefault false;
      };

      proxy = lib.mkDefault null;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.port ];

    services.redis.servers = lib.mkIf cfg.redis.createLocally {
      websurfx.enable = true;
    };

    systemd.services.websurfx = {
      description = "Websurfx, a metasearch engine";

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        DynamicUser = true;
        SupplementaryGroups = lib.mkIf cfg.redis.createLocally [
          config.services.redis.servers.websurfx.group
        ];
        RuntimeDirectory = "websurfx";
        Environment = [ "HOME=%t/websurfx" ];
        BindReadOnlyPaths = [
          "${settingsFile}:%t/websurfx/.config/websurfx/config.lua"
        ];
      };

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.SchweGELBin ];
}
