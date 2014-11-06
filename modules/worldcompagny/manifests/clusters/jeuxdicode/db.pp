class worldcompagny::clusters::jeuxdicode::db(
  $mysql_db       = $worldcompagny::clusters::jeuxdicode::params::mysql_db,
  $mysql_user     = $worldcompagny::clusters::jeuxdicode::params::mysql_user,
  $mysql_password = $worldcompagny::clusters::jeuxdicode::params::mysql_password,
  $mysql_host     = $worldcompagny::clusters::jeuxdicode::params::mysql_host
) inherits worldcompagny::clusters::jeuxdicode::params {

    File['mysql.conf'] -> mysql::augeas {
        'mysqld/bind-address': value  => $mysql_host;
    }

    # Installation BDD MySQL
    mysql::grant {
        "helloworld_local" :
            mysql_privileges     => 'ALL',
            mysql_db             => $mysql_db,
            mysql_user           => $mysql_user,
            mysql_password       => $mysql_password,
            mysql_host           => $mysql_host;

        "helloworld_all" :
            mysql_privileges     => 'ALL',
            mysql_db             => $mysql_db,
            mysql_user           => $mysql_user,
            mysql_password       => $mysql_password,
            mysql_host           => '%',
            mysql_create_db      => false;
    }

}