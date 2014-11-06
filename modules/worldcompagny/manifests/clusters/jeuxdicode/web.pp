class worldcompagny::clusters::jeuxdicode::web(
  $mysql_db       = $worldcompagny::clusters::jeuxdicode::params::mysql_db,
  $mysql_user     = $worldcompagny::clusters::jeuxdicode::params::mysql_user,
  $mysql_password = $worldcompagny::clusters::jeuxdicode::params::mysql_password,
  $mysql_host     = $worldcompagny::clusters::jeuxdicode::params::mysql_host
) inherits worldcompagny::clusters::jeuxdicode::params {

    # Required packages
    ensure_packages([
        'mysql-client' # Connect to MySql from any frontal webserver
    ]);

    file {
        '/home/admin/www/helloworld':
            ensure => 'directory',
            owner  => 'admin',
            group  => 'www-data',
            mode  => '0750',
            require => File['/home/admin/www'];

        '/home/admin/www/helloworld/current' :
            ensure => 'present',
            require => File['/home/admin/www/helloworld'];

        # Répertoire de logs
        '/home/admin/logs/helloworld':
            ensure => 'directory',
            owner  => 'admin',
            group  => 'admin',
            mode  => '0750',
            require => File['/home/admin/logs'];

        # Shared files
        '/home/admin/www/helloworld/shared':
            ensure => 'directory',
            owner  => 'admin',
            group  => 'www-data',
            mode  => '0750',
            require => File['/home/admin/www/helloworld'];

        '/home/admin/www/helloworld/shared/settings.php':
            ensure => 'file',
            owner  => 'admin',
            group  => 'www-data',
            mode  => '0640',
            content => template('worldcompagny/jeuxdicode/settings.php.erb'),
            require => File['/home/admin/www/helloworld'];
    }

    # Apache port
    if "cache" in $::roles {
        $port = '8080'
    } else {
        $port = '80'
    }

    apache::vhost {
        "vhost_helloworld":
            add_listen      => true,
            setenv          => ["ENV_NAME ${::env}", "VHOST helloworld"],
            ip              => '*',
            port            => $port,
            docroot         => "/home/admin/www/helloworld/current/",
            docroot_owner   => 'admin',
            docroot_group   => 'www-data',
            servername      => 'www.helloworld.jeuxdicode.com',
            serveraliases   => 'helloworld.jeuxdicode.com',
            options         => ['-Indexes','FollowSymLinks','MultiViews'],
            override        => ['All'],
            directoryindex  => 'index.php index.html',
            custom_fragment => '',
            aliases         => [{ alias => '/error', path => "/home/admin/www/helloworld/shared/system" }],
            error_documents => [{ error_code => '503', document => '/error/maintenance.html'}],
            rewrites        => [
                {
                comment       => 'To redirect all aliases to servername',
                rewrite_cond  => ["%{HTTP_HOST} !^${servername} [NC]"],
                rewrite_rule  => ["(.*) http://${servername}%{REQUEST_URI} [L,R=301]"],
                },
                {
                comment       => 'Return 503 error if the maintenance page exists.',
                rewrite_cond  => ["/home/admin/www/helloworld/shared/system/maintenance.html -f"],
                rewrite_rule  => ['!^/error/maintenance.html - [L,R=503]'],
                }
            ],
            logroot         => "/home/admin/logs/helloworld",
            log_level       => "warn",
            access_log      => true,
            access_log_file => 'access.log',
            error_log       => true,
            error_log_file  => 'errors.log',
            require         => File['/home/admin/www/helloworld/current']
    }

    # Logrotate
    logrotate::rule { "logrotate_helloworld_errors" :
        path          => "/home/admin/logs/helloworld/errors.log",
        rotate        => 5,
        rotate_every  => 'week',
        compress      => true,
        delaycompress => true,
        missingok     => true,
        sharedscripts => true,
        postrotate    => 'service apache2 reload',
    }

    logrotate::rule { "logrotate_helloworld_access" :
        path          => "/home/admin/logs/helloworld/access.log",
        rotate        => 5,
        rotate_every  => 'day',
        compress      => true,
        delaycompress => true,
        missingok     => true,
        sharedscripts => true,
        postrotate    => 'service apache2 reload',
    }

}