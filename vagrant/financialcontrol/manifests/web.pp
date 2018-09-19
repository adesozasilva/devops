exec { "apt-update":
  command => "/usr/bin/apt-get update"
}
package { ["openjdk-7-jre", "tomcat7", "mysql-server"]:
    ensure => installed,
    require => Exec["apt-update"]
}
package { "unzip":
  ensure => installed,
  require => Exec["apt-update"]
}
service { "tomcat7":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Package["tomcat7"]    
}

service { "mysql":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Package["mysql-server"]
}

exec { "confinan":
    command => "mysqladmin -uroot create confinan",
    unless => "mysql -u root confinan",
    path => "/usr/bin",
    require => Service["mysql"]
}

exec { "mysql-password" :
    command => "mysql -uroot -e \"GRANT ALL PRIVILEGES ON * TO 'confinan'@'%' IDENTIFIED BY '123456';\" confinan",
    unless  => "mysql -uconfinan -p123456 confinan",
    path => "/usr/bin",
    require => Exec["confinan"]
}

file { "/var/lib/tomcat7/webapps/controle-financeiro.war":
    source => "/vagrant/manifests/controle-financeiro.war",
    owner => "tomcat7",
    group => "tomcat7",
    mode => 0644,
    require => Package["tomcat7"],
    notify => Service["tomcat7"]
}

define file_line($file, $line) {
    exec { "/bin/echo '${line}' >> '${file}'":
        unless => "/bin/grep -qFx '${line}' '${file}'"
    }
}

file_line { "production":
    file => "/etc/default/tomcat",
    line => "JAVA_OPTS=\"\$JAVA_OPTS -Dspring.profiles.active=prod\"",
    require => Package["tomcat7"],
    notify => Service["tomcat7"]
}
