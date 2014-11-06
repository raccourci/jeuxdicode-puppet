class worldcompagny::baseconfig::env {

    # Installation des locales
    class { 'locales':
        default_locale  => 'fr_FR.UTF-8',
        locales => [
            'fr_FR ISO-8859-1',
            'fr_FR.UTF-8 UTF-8',
            'fr_FR.UTF-8@euro UTF-8',
            'fr_FR@euro ISO-8859-15'
        ],
    }

    # Installation du hostname
    class { 'hostname':
        hostname => "${::fqdn}",
    }

    # Installation du timezone
    class { 'timezone':
        timezone => 'Europe/Paris',
    }

    # Mise à jour de l'heure via ntp
    class { '::ntp':
        servers => [
            '0.fr.pool.ntp.org',
            '1.fr.pool.ntp.org',
            '2.fr.pool.ntp.org',
            '3.fr.pool.ntp.org'
        ],
    }

    # Mise en place motd
    class { 'motd':
        template => 'worldcompagny/motd.erb',
    }

}
