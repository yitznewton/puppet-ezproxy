include base

class ezproxy {
  package { 'ia32-libs':
    ensure => present,
  }

  user { 'ezproxy':
    home => '/var/www/ezproxy',
    shell => '/bin/false',
  }

  group { 'ezproxy': }

  file { '/etc/init.d/ezproxy':
    source => 'puppet:///modules/ezproxy/scripts/ezproxy.init',
  }

  file { '/usr/local/sbin/ezpensite':
    source => 'puppet:///modules/ezproxy/scripts/ezpensite',
  }

  file { '/usr/local/sbin/ezpdissite':
    source => 'puppet:///modules/ezproxy/scripts/ezpdissite',
  }

  file { '/var/www/ezproxy':
    ensure => directory,
  }

  file { '/var/www/ezproxy/docs':
    source => 'puppet:///modules/ezproxy/docs',
    recurse => true,
    owner => ezproxy,
  }

  file { '/var/www/ezproxy/configs':
    source => 'puppet:///modules/ezproxy/configs',
    recurse => true,
    owner => ezproxy,
  }

  file { '/var/www/ezproxy/ezproxy.key':
    source => 'puppet:///modules/ezproxy/ezproxy.key',
    owner => ezproxy,
    mode => 600,
  }

  file { '/var/www/ezproxy/sites-available':
    ensure => directory,
  }

  file { '/var/www/ezproxy/sites-enabled':
    ensure => directory,
    owner => ezproxy,
    group => ezproxy,
    mode => 664,
  }

  define instance($ip, $host, $port=80, $databases = [], $maxvhosts=500) {
    file { "/var/www/ezproxy/sites-available/$title":
      ensure => directory,
      owner => ezproxy,
    }

    file { "/var/www/ezproxy/sites-available/$title/docs":
      ensure => link,
      target => '/var/www/ezproxy/docs',
    }

    file { "/var/www/ezproxy/sites-available/$title/ezproxy":
      source => 'puppet:///modules/ezproxy/ezproxy-5.4.1.bin',
      owner => ezproxy,
      group => root,
    }

    file { "/var/www/ezproxy/sites-available/$title/ezproxy.key":
      ensure => link,
      target => '/var/www/ezproxy/ezproxy.key',
    }

    file { "/var/www/ezproxy/sites-available/$title/config.txt":
      content => template("ezproxy/config.txt.erb"),
      owner => ezproxy,
    }

    file { "/var/www/ezproxy/sites-available/$title/user.txt":
      source => 'puppet:///modules/ezproxy/user.txt',
      replace => false,
      owner => ezproxy,
    }

    exec { "/var/www/ezproxy/sites-available/$title/ezproxy -m":
      cwd => "/var/www/ezproxy/sites-available/$title",
      user => ezproxy,
      returns => [0, 1],
      require => [
        Package['ia32-libs'],
        File["/var/www/ezproxy/sites-available/$title/docs"],
        File["/var/www/ezproxy/sites-available/$title/ezproxy"],
        File["/var/www/ezproxy/sites-available/$title/config.txt"],
        File["/var/www/ezproxy/sites-available/$title/user.txt"],
        File['/var/www/ezproxy/configs'],
      ],
    }
  }
}

