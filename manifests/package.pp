# =Class superset::package
class superset::package inherits superset {

  if downcase($::osfamily) == 'redhat'{
    $pre_deps = [
      'dnf-plugins-core',
      'fedora-workstation-repositories'
    ]
    package { $pre_deps:
      ensure => present
    }

    exec { 'enable chrome':
      command => 'dnf config-manager --set-enabled google-chrome',
      user        => 'root',
      group       => 'root',
      path        => '/usr/sbin:/usr/bin:/sbin:/bin',
      require => Package[$pre_deps],
    }

    $deps = [
      'google-chrome-stable',
      'cyrus-sasl-devel',
      'gcc-c++',
      'gcc',
      'libffi-devel',
      'openldap-devel',
      'openssl-devel',
      'gawk',
      'curl',
    ]

    package { $deps:
      ensure  => present,
      require => Exec['enable chrome'],
    }
    
  } elsif downcase($::osfamily) == 'debian'{
    $deps = [
      'google-chrome-stable', # requires an entry under apt::sources in hiera
      'ldap-utils',
      'libsasl2-dev',
      'libssl-dev',
      'policycoreutils',
      'python3-ldap',
      'libldap2-dev',
      'gawk',
      'curl',
    ]

    package { $deps:
      ensure => present
    }
  }

  file { '/usr/bin/google-chrome':
    ensure  => 'link',
    target  => '/usr/bin/google-chrome-stable',
    require => Package[$deps],
  }

  exec { 'install chromedriver':
    command => join([
      "wget",
      "https://chromedriver.storage.googleapis.com/$(curl",
      "\"https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$(google-chrome --version | gawk 'match(\$0, /\s([0-9]*)\./, g) {print g[1]}')\")/chromedriver_linux64.zip",
      "&& unzip chromedriver_linux64.zip",
      "&& rm chromedriver_linux64.zip",
      "&& mv chromedriver /usr/local/bin",
    ], ' '),
    user        => 'root',
    group       => 'root',
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => File['/usr/bin/google-chrome']
  }

  file { '/etc/conf.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root'
  }
}
