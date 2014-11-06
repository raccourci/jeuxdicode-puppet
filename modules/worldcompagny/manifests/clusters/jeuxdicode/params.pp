class worldcompagny::clusters::jeuxdicode::params {

    # Change bind-address for production cluster
    case $::env {
        'prod': {
            $mysql_host = 'x.x.x.x'
        }
        'dev': {
            $mysql_host = '127.0.0.1'
        }
        default: {
            $mysql_host = $::ipaddress
        }
    }

    $mysql_db        = 'helloworld'
    $mysql_user      = 'helloworld'
    $mysql_password  = '9ccB2FkVYmfTR9Xe49BN'

}