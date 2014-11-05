class jeuxdicode::users::admin {

    # Création du user 'admin' et de son homedir
    user {
      'admin':
        ensure => present,
        gid => 'www-data',
        groups => ['admin', 'www-data'],
        membership => minimum,
        shell => '/bin/bash',
        home => '/home/admin',
        password => '',
        require => [
            Group['admin'],
            Group['www-data']
        ]
    }

    group {
      'www-data':
        ensure => present,
        gid => '33';
    }

    group {
      'admin':
        ensure => present,
    }

    # Donner les droits sudo à "admin"
    sudoers{ 'admin':
        type => 'user_spec',
        users => 'admin',
        commands => 'NOPASSWD: ALL',
        hosts => 'ALL',
        require => User['admin']
    }

    # Mise en place des répertoires 'www', '.ssh' et 'logs'
    file {

        # Create /home/admin directory
        '/home/admin':
            ensure => 'directory',
            owner => 'admin',
            group => 'www-data',
            mode  => '0750',
            require => Sudoers['admin'];

        '/home/admin/www':
            ensure => 'directory',
            owner  => 'admin',
            group  => 'www-data',
            mode  => '0750',
            require => File['/home/admin'];

        '/home/admin/.bashrc':
            owner => 'admin',
            group => 'www-data',
            mode  => '0600',
            source => 'puppet:///modules/jeuxdicode/users/bashrc_admin',
            require => File['/home/admin'];

        '/home/admin/.bash_aliases':
            owner => 'admin',
            group => 'www-data',
            mode  => '0600',
            source => 'puppet:///modules/jeuxdicode/users/bash_aliases',
            require => File['/home/admin'];

        '/home/admin/.profile':
            owner => 'admin',
            group => 'www-data',
            mode  => '0600',
            source => 'puppet:///modules/jeuxdicode/users/profile',
            require => File['/home/admin'];

        # Create logs directory
        '/home/admin/logs':
            ensure => 'directory',
            owner  => 'admin',
            group  => 'www-data',
            mode  => '0700',
            require => File['/home/admin'];

        # Create .ssh directory
        '/home/admin/.ssh':
            ensure => 'directory',
            owner  => 'admin',
            group  => 'www-data',
            mode  => '0700',
            require => File['/home/admin'];

        '/home/admin/.ssh/authorized_keys':
            owner => 'admin',
            group => 'www-data',
            mode  => '0600',
            source => "puppet:///modules/jeuxdicode/users/ssh/authorized_keys/${::env}",
            require => File['/home/admin/.ssh'];
    }

    # Ajouter les clés dans known_hosts
    $hosts = [
        'github.com',
        'bitbucket.org'
    ]

    each($hosts) |$host| {
        exec {
            "admin_knownhosts_${host}" :
                command => "ssh-keyscan -H ${host} >> /home/admin/.ssh/known_hosts && echo ${host} >> /home/admin/.ssh/known_hosts.md",
                user => 'admin',
                require => File['/home/admin/.ssh'],
                unless => "grep -Fxq '${host}' /home/admin/.ssh/known_hosts.md"
        }
    }
}
