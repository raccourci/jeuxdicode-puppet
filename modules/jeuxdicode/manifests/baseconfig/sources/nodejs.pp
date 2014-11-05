class jeuxdicode::baseconfig::sources::nodejs inherits jeuxdicode::baseconfig::sources {

    apt::source { 'nodejs':
        location => 'https://deb.nodesource.com/node',
        release => 'wheezy',
        repos => 'main',
        key => '68576280',
        key_source => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
        include_src => false,
        pin => 1000
    }

}
