class jeuxdicode::packages::standalone {

    # Package indispensables
    ensure_packages([
        'git',
        'curl',
        'wget',
        'tar',
        'unzip',
        'acl',
        'htop',
        'iotop',
        'iperf',
        'sysstat',
        'ccze',
        'nano',
        'vim',
        'screen',
        'makepasswd',
        'tree',
        'telnet',
        'locales-all',
        'dnsutils',
        'build-essential',
        'apt-transport-https',
        'libsasl2-modules', # Pour Postfix with MandrillApp
        'perl', # Pour les sondes ES
        'libjson-perl', # Pour les sondes ES
        'libxml-perl', # Pour les sondes Varnish
    ])

}