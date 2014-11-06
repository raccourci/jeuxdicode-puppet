class worldcompagny::baseconfig::sources::mongodb inherits worldcompagny::baseconfig::sources {

    apt::source { 'downloads-distro.mongodb.org':
        location    => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
        release     => 'dist',
        repos       => '10gen',
        key         => '7F0CEB10',
        key_server  => 'keyserver.ubuntu.com',
        include_src => false,
        pin => 1000
    }

}
