class jeuxdicode::clusters::jeuxdicode::web {

    # Required packages
    ensure_packages([
        'mysql-client' # Connect to MySql from any frontal webserver
    ]);

    file {
        '/home/admin/www/jeuxdicode':
            ensure => 'directory',
            owner  => 'admin',
            group  => 'www-data',
            mode  => '0750',
            require => File['/home/admin/www'];

        '/home/admin/www/jeuxdicode/current' :
            ensure => 'present',
            require => File['/home/admin/www/jeuxdicode'];

        # Répertoire de logs
        '/home/admin/logs/jeuxdicode':
            ensure => 'directory',
            owner  => 'admin',
            group  => 'admin',
            mode  => '0750',
            require => File['/home/admin/logs'];
    }

    # Apache port
    if "cache" in $::roles {
        $port = '8080'
    } else {
        $port = '80'
    }

    apache::vhost {
        "vhost_jeuxdicode":
            add_listen      => true,
            setenv          => ["ENV_NAME ${::env}", "VHOST jeuxdicode"],
            ip              => '*',
            port            => $port,
            docroot         => "/home/admin/www/jeuxdicode/current/",
            docroot_owner   => 'admin',
            docroot_group   => 'www-data',
            servername      => 'www.jeuxdicode.com',
            serveraliases   => 'jeuxdicode.com',
            options         => ['-Indexes','FollowSymLinks','MultiViews'],
            override        => ['All'],
            directoryindex  => 'index.php index.html',
            custom_fragment => '',
            aliases         => [{ alias => '/error', path => "/home/admin/www/jeuxdicode/shared/system" }],
            error_documents => [{ error_code => '503', document => '/error/maintenance.html'}],
            rewrites        => [
                {
                comment       => 'To redirect all aliases to servername',
                rewrite_cond  => ["%{HTTP_HOST} !^${servername} [NC]"],
                rewrite_rule  => ["(.*) http://${servername}%{REQUEST_URI} [L,R=301]"],
                },
                {
                comment       => 'Return 503 error if the maintenance page exists.',
                rewrite_cond  => ["/home/admin/www/jeuxdicode/shared/system/maintenance.html -f"],
                rewrite_rule  => ['!^/error/maintenance.html - [L,R=503]'],
                }
            ],
            logroot         => "/home/admin/logs/jeuxdicode",
            log_level       => "warn",
            access_log      => true,
            access_log_file => 'access.log',
            error_log       => true,
            error_log_file  => 'errors.log',
            require         => File['/home/admin/www/jeuxdicode/current']
    }

    # Logrotate
    logrotate::rule { "logrotate_jeuxdicode_errors" :
        path          => "/home/admin/logs/jeuxdicode/errors.log",
        rotate        => 5,
        rotate_every  => 'week',
        compress      => true,
        delaycompress => true,
        missingok     => true,
        sharedscripts => true,
        postrotate    => 'service apache2 reload',
    }

    logrotate::rule { "logrotate_jeuxdicode_access" :
        path          => "/home/admin/logs/jeuxdicode/access.log",
        rotate        => 5,
        rotate_every  => 'day',
        compress      => true,
        delaycompress => true,
        missingok     => true,
        sharedscripts => true,
        postrotate    => 'service apache2 reload',
    }

}