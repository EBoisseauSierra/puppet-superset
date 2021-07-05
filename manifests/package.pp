# =Class superset::package
class superset::package inherits superset {
  if downcase($::osfamily) == 'RedHat'{
    $deps = [
      'gcc', 'gcc-c++', 'libffi-devel', 'chromium', 'chromedriver', 'git',
      'openssl-devel', 'cyrus-sasl-devel', 'openldap-devel'
    ]
  } elsif downcase($::osfamily) == 'Debian'{
    $deps = [
      'chromium-browser', 'git', 'libssl-dev', 'libsasl2-dev', 'ldap-utils', 'python3-ldap', "python3-pyldap"
    ]
  }

  package { $deps:
    ensure => present
  }

  file { '/usr/bin/google-chrome':
    ensure  => 'link',
    target  => '/usr/bin/chromium-browser',
    require => Package[$deps],
  }

  file { '/etc/conf.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root'
  }
}
