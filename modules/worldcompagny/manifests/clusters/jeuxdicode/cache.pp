class worldcompagny::clusters::jeuxdicode::cache {

    $varnish_port = "80"
    $varnish_jeuxdicode_vcl = '/etc/varnish/jeuxdicode.vcl'

    # Main probe settings
	$settings = {
		url => "/probe/heartbeat",
        timeout => '1s',
        interval => '10s',
        window => 5,
        threshold => 2,
        first_byte_timeout => '300s',
        connect_timeout => '5s',
        between_bytes_timeout => '2s',
	}

    # Backends (according to the env)
    case $::env {
        'dev': {
            $timeout = "120s"
            $listen_address = '192.168.50.20'
            $storage_size = "256M"
            $purge_acl = "\"127.0.0.1\";\"${listen_address}\";"
            $backends_public = [
                {
                    host => "localhost",
                    port => "8080",
                    weight => "1",
                    name => "jeuxdicode"
                }
            ]
			$backends_admin = []
        }

        'integ': {
            $timeout = "60s"
            $listen_address = $::ipaddress
            $storage_size = "512M"
            $purge_acl = "\"127.0.0.1\";\"${::ipaddress}\";"
            $backends_public = [
                {
                    host => "localhost",
                    port => "8080",
                    weight => "1",
                    name => "jeuxdicode"
                }
            ]
            $backends_admin = []
        }

        'preprod': {
            $timeout = "60s"
            $listen_address = $::ipaddress
            $storage_size = "512M"
            $purge_acl = "\"127.0.0.1\";\"${::ipaddress}\";"
            $backends_public = [
                {
                    host => "localhost",
                    port => "8080",
                    weight => "1",
                    name => "jeuxdicode"
                }
            ]
            $backends_admin = []
        }

         'prod': {
             $timeout = "60s";
             $listen_address = "x.x.x.x"
             $storage_size = "512M"
             $purge_acl = '"x.x.x.x"/24;'
             $backends_public = [
                 {
                     host => "jeuxdicodef1.prod" ,
                     port => "80",
                     weight => "1",
                     name => "jeuxdicodef1"
                 },
                 {
                     host => "jeuxdicodef2.prod",
                     port => "80",
                     weight => "1",
                     name => "jeuxdicodef2"
                 }
             ]
             $backends_admin = [
                 {
                     host => "jeuxdicodea1.prod",
                     port => "80",
                     weight => "1",
                     name => "jeuxdicodea1"
                 }
             ]
         }
    }

    class { 'varnish':
        varnish_vcl_conf => $varnish_jeuxdicode_vcl,
        version => "4.0.2-1~wheezy",
        varnish_listen_port => $varnish_port,
        varnish_listen_address => $listen_address,
        varnish_ttl => "60",
        storage_type => "malloc",
        varnish_storage_size => $storage_size,
        add_repo => false,
        shmlog_tempfs => false # Disable fucking logs mount
    } -> file {
        $varnish_jeuxdicode_vcl:
            owner => 'root',
            group => 'root',
            content => template('worldcompagny/jeuxdicode/vcl.erb'),
            notify => Service['varnish']
    }
}