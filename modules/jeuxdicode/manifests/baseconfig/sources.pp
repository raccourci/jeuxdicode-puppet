class jeuxdicode::baseconfig::sources {

    class { 'apt':
        always_apt_update => true,
        purge_sources_list   => true,
        purge_sources_list_d => true,
        purge_preferences_d  => true,
        fancy_progress => true
    }

    # Custom by cluster
    each(split($::roles, ',')) |$role| {
        hiera_include("${role}_sources", '')
    }

    # Puppet
    apt::source { 'puppetlabs-main':
        location => 'http://apt.puppetlabs.com',
        repos => 'main',
        key => '4BD6EC30',
        key_server => 'pgp.mit.edu',
        include_src => false,
        pin => 1000
    }

    apt::source { 'puppetlabs-dependencies':
        location => 'http://apt.puppetlabs.com',
        repos => 'dependencies',
        key => '4BD6EC30',
        key_server => 'pgp.mit.edu',
        include_src => false,
        pin => 1000
    }

    # Debian
    apt::source { 'debian':
        location => "http://ftp.fr.debian.org/debian",
        release => "wheezy",
        repos => "main contrib non-free",
        include_src => false
    }

    apt::source { 'debian_security':
        location => "http://security.debian.org/",
        release => "wheezy/updates",
        repos => "main contrib non-free",
        include_src => false
    }

    apt::source { 'debian_update':
        location => "http://ftp.fr.debian.org/debian",
        release => "wheezy-updates",
        repos => "main contrib non-free",
        include_src => false
    }

    apt::pin { 'stable':
        priority => 900,
        release => 'stable',
    }

}
