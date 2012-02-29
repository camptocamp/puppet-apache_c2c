class apache::selinux {

  case $operatingsystem {

    RedHat,CentOS: {
      case $lsbmajdistrelease {

        "4","5": { }

        default: {

          # Basic SELinux rules to:
          # -read vhost configuration files
          # -logrotate
          selinux::module { "httpdbase":
            source => "puppet:///apache/selinux/httpdbase.te",
            notify => Selmodule[ "httpdbase" ],
          }

          selmodule { "httpdbase":
            ensure      => present,
            syncversion => true,
            require     => Exec[ "build selinux policy package httpdbase" ],
          }

        }
      }
    }

    default: { }

  }

}
