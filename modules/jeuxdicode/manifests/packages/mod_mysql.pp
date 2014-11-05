class jeuxdicode::packages::mod_mysql {

    # Installation MySQL
    class { 'mysql':
        root_password => 'TC88WzBG4FrBHErf64nd',
    }

    # Root GRANT access
    mysql::grant {
        "root_access_localhost" :
            mysql_privileges     => 'ALL',
            mysql_db             => '*',
            mysql_user           => 'root',
            mysql_password       => 'TC88WzBG4FrBHErf64nd',
            mysql_host           => 'localhost',
            mysql_create_db      => false
    }

    mysql::grant {
        "root_access_all" :
            mysql_privileges     => 'ALL',
            mysql_db             => '*',
            mysql_user           => 'root',
            mysql_password       => 'TC88WzBG4FrBHErf64nd',
            mysql_host           => '%',
            mysql_create_db      => false
    }

    # Performance tuning
    File['mysql.conf'] -> mysql::augeas {
        'mysqld/key_buffer':value  => '16M';
        'mysqld/key_buffer_size':value  => '128M';
        'mysqld/table_open_cache':value  => '4096';
        'mysqld/query_cache_type':value  => '1';
        'mysqld/query_cache_limit':value  => '4M';
    }

    case $::env {
        'dev': {
            File['mysql.conf'] -> mysql::augeas {
                'mysqld/query_cache_size':value  => '16M';
                'mysqld/innodb_buffer_pool_size':value  => '16M';
            }
        }
        'integ':{
            File['mysql.conf'] -> mysql::augeas {
                'mysqld/query_cache_size':value  => '32M';
                'mysqld/innodb_buffer_pool_size':value  => '32M';
            }
        }
        default: {
            File['mysql.conf'] -> mysql::augeas {
                'mysqld/query_cache_size':value  => '256M';
                'mysqld/innodb_buffer_pool_size':value  => '1G';
            }
        }

    }

}