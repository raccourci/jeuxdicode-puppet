Exec {
    path => '/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin/',
    timeout => 60,
    tries   => 3
}

notice "------------------------------------"
notice "Installation Puppet"
notice ">> FQDN : $::fqdn"
notice ">> CLUSTER : $::cluster"
notice ">> ROLES : $::roles"
notice ">> ENV : $::env"
notice "------------------------------------"

stage { 'setup_env': }
stage { 'setup_sources': }

Stage['setup_env'] -> Stage['setup_sources'] -> Stage['main']