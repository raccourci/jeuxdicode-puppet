class jeuxdicode::users::root {

    # Mise en place des répertoires 'www', '.ssh' et 'logs'
    file {
        '/root/.bashrc':
            owner => 'root',
            group => 'root',
            mode  => '0640',
            source => 'puppet:///modules/jeuxdicode/users/bashrc_root';

        '/root/.bash_aliases':
            owner => 'root',
            group => 'root',
            mode  => '0640',
            source => 'puppet:///modules/jeuxdicode/users/bash_aliases';

        '/root/.profile':
            owner => 'root',
            group => 'root',
            mode  => '0640',
            source => 'puppet:///modules/jeuxdicode/users/profile';
    }
}
