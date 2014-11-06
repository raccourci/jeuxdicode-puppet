class worldcompagny::packages::mod_php {

    # Installation PHP
    include php
    include php::fpm
    include php::cli
    include php::pear
    include php::extension::apc
    include php::extension::curl
    include php::extension::intl
    include php::extension::gd
    include php::extension::memcache
    include php::extension::mcrypt
    include php::extension::imap
    include php::extension::imagick
    class { "php::extension::mysql": package => 'php5-mysqlnd' }
    package { "php5-dev": require => Class['php::fpm']; }

    # Extenion JSMin for Drupal
    class { "php::extension::jsmin":
            require => [
                Class['php'],
                Class['php::pear'],
                Class['php::fpm'],
                Class['php::cli'],
                Package['php5-dev']
            ];
    } -> exec { 'php5enmod jsmin': user => 'root', creates => "/etc/php5/conf.d/20-jsmin.ini", notify  => Service['php5-fpm'] }

    # Extenion UploadProgress for Drupal
    class { "php::extension::uploadprogress":
            require => [
                Class['php'],
                Class['php::pear'],
                Class['php::fpm'],
                Class['php::cli'],
                Package['php5-dev']
            ];
    } -> exec { 'php5enmod uploadprogress': user => 'root', creates => "/etc/php5/conf.d/20-uploadprogress.ini", notify  => Service['php5-fpm'] }

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Apc file
    file {
        '/var/www/apc':
            ensure => 'directory',
            owner => 'root',
            group => 'www-data',
            mode  => '0755',
            source  => 'puppet:///modules/worldcompagny/packages/php/apc',
            recurse => true,
            require => File['/var/www'];

        '/var/www/fpm':
            ensure => 'directory',
            owner => 'root',
            group => 'www-data',
            mode  => '0755',
            require => File['/var/www'];

        '/var/www/fpm/status.php' :
            ensure => file,
            owner => 'root',
            group => 'www-data',
            mode  => '0644',
            content  => '',
            require => File['/var/www/fpm'];
    }

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Config POOL FPM

    php::fpm::pool { 'www' :
        listen => '/var/run/php5-fpm.sock',
        listen_owner => 'www-data',
        listen_group => 'www-data',
        listen_mode => '660',
        user => 'www-data',
        group => 'www-data',
        pm => 'dynamic',
        pm_max_children => '40',
        pm_start_servers => '4',
        pm_min_spare_servers => '4',
        pm_max_spare_servers => '8',
        pm_max_requests => '500',
        pm_process_idle_timeout => '10s',
        ping_response => 'pong',
        request_terminate_timeout => '0',
        request_slowlog_timeout => '3s',
        pm_status_path => '/fpm/status.php',
        slowlog => "/var/log/php5-fpm-www-slow.log"
    }

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Config common (http://gregrickaby.com/the-perfect-apc-configuration/)

    $config_common = [
        "set PHP/short_open_tag Off",
        "set PHP/log_errors On",
        "set PHP/upload_max_filesize 20M",
        "set PHP/post_max_size 20M",
        "set Date/date.timezone Europe/Paris",
        "set APC/apc.write_lock 1",
        "set APC/apc.max_file_size 2M",
        "set APC/apc.filters \"-/var/www/apc/.*\"",
    ]

    php::fpm::config{ 'common_phpfpm': config => $config_common, require => Class['php::fpm']; }
    php::cli::config{ 'common_phpcli': config => $config_common, require => Class['php::cli']; }

    # Custom case
    php::fpm::config{ 'maxexec_phpfpm': config => ["set PHP/max_execution_time 60"], require => Class['php::fpm']; }
    php::cli::config{ 'maxexec_phpcli': config => ["set PHP/max_execution_time 0"], require => Class['php::cli']; }
    php::fpm::config{ 'memory_limit_phpfpm': config => ["set PHP/memory_limit 512M"], require => Class['php::fpm']; }
    php::cli::config{ 'memory_limit_phpcli': config => ["set PHP/memory_limit 512M"], require => Class['php::cli']; }

    # Config to show all errors (only on DEV and PHP_CLI)
    $config_all = [
        "set PHP/expose_php On",
        "set PHP/track_errors On",
        "set PHP/display_errors On",
        "set PHP/error_reporting E_ALL"
    ]

    # Config for production
    $config_restricted = [
        "set PHP/expose_php Off",
        "set PHP/track_errors Off",
        "set PHP/display_errors Off",
        "set PHP/error_reporting E_ALL & ~E_DEPRECATED & ~E_STRICT"
    ]

    case $::env {
        'prod': {
            php::fpm::config{ "config_${::env}_phpfpm": config => $config_restricted, require => Class['php::fpm']; }
            php::cli::config{ "config_${::env}_phpcli": config => $config_all, require => Class['php::cli']; }
            php::fpm::config{ 'apc_shm_size_phpfpm': config => ["set APC/apc.shm_size 128M"], require => Class['php::fpm']; }
            php::fpm::config{ 'apc_stat_phpfpm': config => ["set APC/apc.stat 0"], require => Class['php::fpm']; }
        }
        'preprod': {
            php::fpm::config{ "config_${::env}_phpfpm": config => $config_restricted, require => Class['php::fpm']; }
            php::cli::config{ "config_${::env}_phpcli": config => $config_all, require => Class['php::cli']; }
            php::fpm::config{ 'apc_shm_size_phpfpm': config => ["set APC/apc.shm_size 128M"], require => Class['php::fpm']; }
            php::fpm::config{ 'apc_stat_phpfpm': config => ["set APC/apc.stat 0"], require => Class['php::fpm']; }
        }
        'integ': {
            php::fpm::config{ "config_${::env}_phpfpm": config => $config_all, require => Class['php::fpm']; }
            php::cli::config{ "config_${::env}_phpcli": config => $config_all, require => Class['php::cli']; }
            php::fpm::config{ 'apc_shm_size_phpfpm': config => ["set APC/apc.shm_size 128M"], require => Class['php::fpm']; }
            php::fpm::config{ 'apc_stat_phpfpm': config => ["set APC/apc.stat 1"], require => Class['php::fpm']; }
        }
        'dev': {
            php::fpm::config{ "config_${::env}_phpfpm": config => $config_all, require => Class['php::fpm']; }
            php::cli::config{ "config_${::env}_phpcli": config => $config_all, require => Class['php::cli']; }
            php::fpm::config{ 'apc_shm_size_phpfpm': config => ["set APC/apc.shm_size 64M"], require => Class['php::fpm']; }
            php::fpm::config{ 'apc_stat_phpfpm': config => ["set APC/apc.stat 1"], require => Class['php::fpm']; }
        }
    }

}
