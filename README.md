# Devops

Criar ambiente virtual com Tomcat e  MySQL utilizando o Vagrant

Requisitos:

- Baixar o vagrant no site: https://www.vagrantup.com/downloads.html

- Será necessário também baixar o Virtural Box(https://www.virtualbox.org/wiki/Downloads)


Criar a pasta do projeto, no meu caso a pasta vai ser chamar musicjungle, depois dentro do diretório, será necessário criar o arquivo Vagrant


```
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.define :web do |web_config|
    end     
end

```

Depois de criado o arquivo entre no terminal e rode o seguinte comando `vagrant up`, isso fará com que o vagrant criei a máquina virtual e instale o ubuntu.

Com a máquina instalada, você pode se conectar utilizando o protocolo SSH, com comando `vagrant ssh`. Então podemos verificar que estamos dentro de um ambiente linux.

Agora precisamos instalar o Tomcat e mysql, mas antes disso iremos configuar um ip para depois termos acesso a máquina, então adicionaremos o seguinte trecho no arquivo Vagrant

```
   ...
    config.vm.define :web do |web_config|
      web_config.vm.network "private_network", ip: "192.168.56.10"
    end 
   ...
  
```
Agora será necessário exceutar o comando `vagrant reload`, para adicionarmos a configuração do IP e então temos a máquina instalado e funcionando, e então podemos partir para a instalação do Tomcat e Mysql.

Começaremos pelo Tomcat, para isso iremos criar um diretório chamado manifests e dentro dele o arquivo chamado web.pp, neste arquivo configuraremos os comandos como se estivessemos dentro no terminal linux, então precisamos configurar os comandos de instalação:

`
exec { "apt-update":
  command => "/usr/bin/apt-get update"
}

package { ["openjdk-7-jre", "tomcat7"]:
    ensure => installed,
    require => Exec["apt-update"]
}

`

Note que para a instalação do tomcat, também foi necessário a instalação da jdk7, no caso estamos usando a Open JDK.


Agora iremos instalar o mysql, e configuraremos do mesmo jeito que fizemos com o tomcat


`
package { ["openjdk-7-jre", "tomcat7", "mysql-server"]:
    ensure => installed,
    require => Exec["apt-update"]
}

`






































