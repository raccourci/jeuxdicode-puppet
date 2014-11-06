class worldcompagny::users::root {

    # Mise en place des répertoires 'www', '.ssh' et 'logs'
    file {
        '/root/.bashrc':
            owner => 'root',
            group => 'root',
            mode  => '0640',
            source => 'puppet:///modules/worldcompagny/users/bashrc_root';

        '/root/.bash_aliases':
            owner => 'root',
            group => 'root',
            mode  => '0640',
            source => 'puppet:///modules/worldcompagny/users/bash_aliases';

        '/root/.profile':
            owner => 'root',
            group => 'root',
            mode  => '0640',
            source => 'puppet:///modules/worldcompagny/users/profile';
    }
}
