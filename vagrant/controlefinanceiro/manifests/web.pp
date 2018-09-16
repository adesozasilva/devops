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

exec { "controlefinanceiro":
    command => "mysqladmin -uroot create controle_financeiro",
    unless => "mysql -u root controle_financeiro",
    path => "/usr/bin",
    require => Service["mysql"]
}

exec { "mysql-password" :
    command => "mysql -uroot -e \"GRANT ALL PRIVILEGES ON * TO 'controle_financeiro'@'%' IDENTIFIED BY '123456';\" controlefinanceiro",
    unless  => "mysql -ucontrolefinanceiro -p123456 controlefinanceiro",
    path => "/usr/bin",
    require => Exec["controlefinanceiro"]
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
