class worldcompagny::baseconfig::sources::varnish4 inherits worldcompagny::baseconfig::sources {

    apt::source { 'varnish4':
        location => 'http://repo.varnish-cache.org/debian/',
        release => 'wheezy',
        repos => 'varnish-4.0',
        key => 'C4DEFFEB',
        key_source => 'http://repo.varnish-cache.org/debian/GPG-key.txt',
        include_src => false,
        pin => 1000
    }

}
