class worldcompagny::packages::mod_varnish {

    # Enabled logs Varnish
    file {
        '/etc/default/varnishncsa':
            owner => 'root',
            group => 'root',
            mode  => '0644',
            source => 'puppet:///modules/worldcompagny/packages/varnish/varnishncsa',
            require => Class['varnish'],
            notify => Service['varnishncsa']
    }

    service { 'varnishncsa':
        ensure => 'running',
        name   => 'varnishncsa',
        enable => true,
        require => Class['varnish'];
    }

    # Logrotate
    logrotate::rule { "logrotate_varnishncsa" :
        path          => "/var/log/varnish/varnishncsa.log",
        rotate        => 5,
        rotate_every  => 'day',
        compress      => true,
        delaycompress => true,
        missingok     => true,
        sharedscripts => true,
        postrotate    => 'service varnishncsa reload',
    }
}
