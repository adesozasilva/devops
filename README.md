# Devops

Criando um ambiente virtual para aplicações Java com Tomcat e MySQL utilizando o Vagrant em menos de 15 mintutos

Requisitos

Faça o download das seguintes ferramentas:

- Vagrant - https://www.vagrantup.com/downloads.html

- Virtural Box - https://www.virtualbox.org/wiki/Downloads


Crie uma pasta com o nome do projeto, no meu caso será financialcontrol, depois dentro desse diretório será necessário criar um arquivo chamado Vagrantfile, com as seguintes configurações:


```
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.define :web do |web_config|
    end     
end
```

Note que neste arquivo estamos configurando a box `ubuntu/trusty64` que representa o Ubuntu 64 bit e estamos dando o nome de `web` para a máquina. 

Depois de criado este arquivo abra no terminal, entre na pasta do nosso projeto e rode o seguinte comando `vagrant up`, isso fará com que o vagrant crie a nossa máquina virtual com o Ubuntu.

Com o comando finalizado, você pode se conectar à maquina utilizando o protocolo SSH, com comando `vagrant ssh`. Então podemos verificar que agora estamos dentro de um ambiente linux.

![alt text](https://github.com/andersonszisk/devops/blob/master/vagrant/images/vagrant_ssh.jpg)


Agora precisamos instalar o Tomcat e Mysql, mas antes disso iremos configurar um ip para facilitar o nosso acesso à maquina, então adicionaremos o seguinte trecho no arquivo VagrantFile

```
   ...
    config.vm.define :web do |web_config|
      web_config.vm.network "private_network", ip: "192.168.56.10"
    end 
   ...
```
Será necessário exceutar o comando `vagrant reload`, para adicionar a configuração do IP e assim temos a máquina com o nosso IP fixo funcionando e agora vamos para as instalações do Tomcat e Mysql.

Para executarmos os comandos de instalações no linux, precisamos de uma ferramenta de provisionamento, aqui usaremos o Puppet, então precisamos adicioná-lo nas nossas configurações:

```
Vagrant.configure("2") do |config|
    
    config.vm.box = "ubuntu/trusty64"
    
    config.vm.define :web do |web_config|
        web_config.vm.network "private_network", ip: "192.168.56.10"
        
            web_config.vm.provision "puppet" do |puppet|
                puppet.manifest_file = "web.pp"
            end 
        end
end

```

Note que a configuração do puppet aponta para um arquivo web.pp, portanto precisamos criar um diretório chamado manifests e dentro dele o arquivo chamado web.pp, neste arquivo configuraremos todos os comandos de provisionamento para o ambiente.

Depois de criado o nosso arquivo, vamos adicionar os comandos para instalar a Open Jdk 7 e o Tomcat 7:

```
# apt-get update
exec { "apt-update":
  command => "/usr/bin/apt-get update"
}

# apt-get install openjdk-7-jre tomcat7
package { ["openjdk-7-jre", "tomcat7"]:
    ensure => installed,
    require => Exec["apt-update"]
}
```


No terminal dentro da pasta do projeto, rode novamente o comando `vagrant reload` para adicionar as novas instalações, e agora temos o tomcat instalado


![alt text](https://github.com/andersonszisk/devops/blob/master/vagrant/images/tomcat.jpg)


O nosso próximo passo será a instalação do mysql, para isso adicione o pacote do mysql para também ser instalado.

```
# apt-get install mysql-server
package { ["openjdk-7-jre", "tomcat7", "mysql-server"]:
    ensure => installed,
    require => Exec["apt-update"]
}
```

Agora com o mysql instalado é preciso criar o banco de dados que a nossa aplicação irá usar, portando adicione as seguintes configurações no arquivo web.pp:

```
exec { "financial":
    command => "mysqladmin -uroot create financial",
    unless => "mysql -u root financial",
    path => "/usr/bin",
    require => Service["mysql"]
}

exec { "mysql-password" :
    command => "mysql -uroot -e \"GRANT ALL PRIVILEGES ON * TO 'financial'@'%' IDENTIFIED BY '123456';\" financial",
    unless  => "mysql -ufinancial -p123456 financial",
    path => "/usr/bin",
    require => Exec["financial"]
}
```

E podemos verificar se o mysql e o nosso banco de dados foi criado corretamente:

![alt text](https://github.com/andersonszisk/devops/blob/master/vagrant/images/mysql.jpg)

Com o nosso ambiente montado podemos automatizar o deploy da nossa aplicação, para isso é necessário garantir que os serviços do tomcat e mysql estejam funcionando:


```
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
```

Por último vamos adicionar a task para enviarmos o nosso arquivo war para o tomcat, lembre-se que precisamos colocar o nosso arquivo .war dentro da pasta manifests

```
file { "/var/lib/tomcat7/webapps/financial.war":
    source => "/vagrant/manifests/financial.war",
    owner => "tomcat7",
    group => "tomcat7",
    mode => 0644,
    require => Package["tomcat7"],
    notify => Service["tomcat7"]
}
```

Finalmente rodando os comandos `vagrant destroy` para apagar a nossa máquina e `vagrant up` para subir o ambiente com as novas configurações, temos o nosso ambiente montado com Ubuntu, Tomcat, Mysql e a nossa aplicação Java em menos de 15 minutos.

![alt text](https://github.com/andersonszisk/devops/blob/master/vagrant/images/application.jpg)



