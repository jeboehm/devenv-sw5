{ pkgs, config, ... }:

{
  languages.javascript.enable = true;
  languages.php.enable = true;
  languages.php.version = "8.1";

  languages.php.fpm.pools.web = {
    settings = {
      "clear_env" = "no";
      "pm" = "dynamic";
      "pm.max_children" = 10;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 10;
    };
  };

  languages.php.ini = ''
      memory_limit = 1G
      realpath_cache_ttl = 3600
      session.gc_probability = 0
      display_errors = On
      error_reporting = E_ALL
      opcache.memory_consumption = 256M
      opcache.interned_strings_buffer = 20
      zend.assertions = 0
      short_open_tag = 0
      zend.detect_unicode = 0
      realpath_cache_ttl = 3600
      upload_max_filesize = 20M
      max_execution_time = 300
    '';

  services.mysql.enable = true;
  services.mysql.initialDatabases = [
      {
        name = "shopware";
      }
  ];

  process.implementation = "overmind";
  services.redis.enable = true;
  services.mailhog.enable = true;

  services.caddy.enable = true;
  services.caddy.virtualHosts.":8000" = {
    extraConfig = ''
      root * .
      php_fastcgi unix/${config.languages.php.fpm.pools.web.socket} {
          index shopware.php
      }

      file_server
    '';
  };
}
