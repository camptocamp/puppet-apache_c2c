define apache::webdav::instance ($ensure=present, $vhost, $purge='5', $directory=false) {

  if $directory {
    $davdir = "${directory}${name}"
  } else {
    $davdir = "/var/www/${vhost}/private${name}" 
  }

  $clean_name = generate("/bin/bash","-c","/bin/echo -n ${name} | sed 's#/#-#g'")
  notice "$name ->> $clean_name"

  case $ensure {
    'present' :{
      exec {"Creating dav basedir for ${name}":
        command => "mkdir -p $davdir",
        unless => "test -d $davdir",
        require => File["/var/www/${vhost}/conf/webdav${clean_name}.conf"],
      }
    }
    'absent' :{
      exec {"Removing dav basedir for ${name}":
        command => "rm -rf $davdir",
        onlyif => "test -d $davdir",
        require => File["/var/www/${vhost}/conf/webdav${clean_name}.conf"],
      }
    }
  }

  # configuration
  file {"/var/www/${vhost}/conf/webdav${clean_name}.conf" :
    ensure => $ensure,
    content => template("apache/webdav-config.erb"),
  }

  # do we want to hold files for a very long time?
  case $purge {
    '0' :{ 
       cron {"Clean old files from DAV $davdir":
          command => "/usr/sbin/tmpreaper --ctime --all ${purge}d ${davdir}",
          user    => "root",
          ensure  => absent,
        }
    }
    default : {
       cron {"Clean old files from DAV $davdir":
          command => "/usr/sbin/tmpreaper --ctime --all ${purge}d ${davdir}",
          user    => "root",
          minute  => 0,
          hour    => 1,
          ensure  => present,
        }
    }
  }

}
