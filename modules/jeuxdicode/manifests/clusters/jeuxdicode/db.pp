class jeuxdicode::clusters::jeuxdicode::db {

    # Change bind-address for production cluster
    case $::env {
        'prod': {
            $bindaddress_mysql = 'x.x.x.x'
        }
        'dev': {
            $bindaddress_mysql = '127.0.0.1'
        }
        default: {
            $bindaddress_mysql = $::ipaddress
        }
    }

    File['mysql.conf'] -> mysql::augeas {
        'mysqld/bind-address': value  => $bindaddress_mysql;
    }

    # Installation BDD MySQL
    mysql::grant {
        "${site}_local":
            mysql_privileges     => 'ALL',
            mysql_db             => 'jeuxdicode_bdd',
            mysql_user           => 'jeuxdicode',
            mysql_password       => '4W9voZhsHyXQ4v2w7Gba',
            mysql_host           => $bindaddress_mysql;

        "${site}_all":
            mysql_privileges     => 'ALL',
            mysql_db             => 'jeuxdicode_bdd',
            mysql_user           => 'jeuxdicode',
            mysql_password       => '4W9voZhsHyXQ4v2w7Gba',
            mysql_host           => '%',
            mysql_create_db      => false;
    }

}