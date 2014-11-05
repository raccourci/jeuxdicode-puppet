class jeuxdicode::baseconfig::sources::dotdeb_php54 inherits jeuxdicode::baseconfig::sources {

    apt::source { 'dotdeb':
        location => "http://packages.dotdeb.org",
        release => "wheezy",
        repos => "all",
        key => "89DF5277",
        key_server => "keys.gnupg.net",
        include_src => false,
        pin => 1000
    }

}
