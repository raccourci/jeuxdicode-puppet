class jeuxdicode::packages::mod_sshd {

    # Config SSH
    augeas { 'sshd_config':
        context => "/files/etc/ssh/sshd_config",
        changes => [
            "set PermitRootLogin no",
            "set PermitEmptyPasswords no",
            "set RSAAuthentication yes",
            "set PubkeyAuthentication yes",
            "set PasswordAuthentication no",
        ],
        notify => Service[sshd]
    }

    service { 'sshd':
        name  => 'ssh',
        pattern => 'sshd',
        ensure => 'running',
        enable => true
    }
}
