class jeuxdicode::packages::mod_apache {

    # Installation Apache
    class { 'apache':
        serveradmin      => 'admin@jeuxdicode.fr',
        mpm_module       => 'worker',
        default_vhost    => false,
        default_mods     => true,
        timeout          => 120,
        manage_group     => false,
        server_signature => 'Off',
        server_tokens    => 'Prod',
        trace_enable     => 'Off'
    }

    # Force Varnish to be install before Apache
    if defined( Class['varnish']) {
        Class['varnish'] -> Class['apache']
    }

    # Mods
    include apache::mod::info
    include apache::mod::status
    include apache::mod::actions
    include apache::mod::headers
    include apache::mod::rewrite
    include apache::mod::expires
    include apache::mod::include
    include apache::mod::proxy
    include apache::mod::proxy_http
    include apache::mod::fastcgi
    include apache::mod::fcgid


    case $::env {
        'dev': {
            class { 'apache::mod::rpaf':
                sethostname => true,
                proxy_ips   => [ '127.0.0.1'],
            }
        }
        'integ': {
            class { 'apache::mod::rpaf':
                sethostname => true,
                proxy_ips   => [ '127.0.0.1'],
            }
        }
        'preprod': {
            class { 'apache::mod::rpaf':
                sethostname => true,
                proxy_ips   => [ '127.0.0.1', '172.31.0.1' ],
            }
        }
        'prod': {
            class { 'apache::mod::rpaf':
                sethostname => true,
                proxy_ips   => [ '127.0.0.1', '172.31.0.1' ],
            }
        }
    }

    apache::mod { 'unique_id': }

    # Enable mod PHP-FPM
    file { 'php5-fpm.conf' :
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        path    => "${::apache::confd_dir}/php5-fpm.conf",
        source  => 'puppet:///modules/jeuxdicode/packages/apache/php5-fpm.conf',
        require => [
            Class['apache'],
            Apache::Mod['fastcgi']
        ],
        notify  => Service['httpd'],
    }

    # Vhost default
    file {
        '/var/www/index.html' :
            ensure => file,
            owner => 'root',
            group => 'www-data',
            mode  => '0644',
            content => '<html><body style="background: url(bg.jpg) repeat;"></body></html>',
            require => Class['apache'];

        '/var/www/bg.jpg' :
            ensure => file,
            owner => 'root',
            group => 'www-data',
            mode  => '0644',
            source  => 'puppet:///modules/jeuxdicode/packages/apache/bg.jpg',
            require => File['/var/www/index.html'];

        '/var/www/probe':
            ensure => 'directory',
            owner => 'root',
            group => 'www-data',
            mode => '0755';

        '/var/www/probe/heartbeat':
            owner => 'root',
            group => 'www-data',
            require => File['/var/www/probe'],
            content => 'OK',
            mode => '0644';
    }

    # Installation Apache
    if 'cache' in $::roles {
        $port = '8080'
    } else {
        $port = '80'
    }

    apache::vhost {
        "vhost_default" :
            default_vhost   => true,
            add_listen      => true,
            ip              => '*',
            port            => $port,
            docroot         => "/var/www",
            docroot_owner   => 'root',
            docroot_group   => 'www-data',
            options         => ['-Indexes','FollowSymLinks','MultiViews'],
            override        => ['All'],
            directoryindex  => 'index.html index.php'
    }

}
