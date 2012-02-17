class apache::params {

  $mpm_type = $::apache_mpm_type ? {
    '' => 'worker',
    default => $::apache_mpm_type
  }

### Apache global section 1 config
#Format:
#  # Variable: apache2.conf =>
#  $ = $::apache_ ? {
#    '' => ,
#    default => $::apache_
#  }


  # Variable: apache2.conf => KeepAliveTimeout
  $keep_alive_timeout = $::apache_keep_alive_timeout ? {
    '' => 5,
    default => $::apache_keep_alive_timeout
  }

  # Variable: apache2.conf => Timeout
  $timeout = $::apache_timeout ? {
    '' => 300,
    default => $::apache_timeout
  }

  # Variable: apache2.conf => MaxKeepAliveRequests
  $max_keep_alive_req = $::apache_max_keep_alive_req ? {
    '' => 100,
    default => $::apache_max_keep_alive_req
  }

  # Variable: apache2.conf => KeepAlive
  $keep_alive = $::apache_keep_alive ? {
    '' => on,
    default => $::apache_keep_alive
  }

### prefork MPM

# StartServers: number of server processes to start
#    StartServers          5
  $prefork_start_servers = $::apache_prefork_start_servers ? {
    '' => 5,
    default => $::apache_prefork_start_servers
  }

# MinSpareServers: minimum number of server processes which are kept spare
#    MinSpareServers       5
  $prefork_min_spare_servers = $::apache_prefork_min_spare_servers ? {
    '' => 5,
    default => $::apache_prefork_min_spare_servers
  }

# MaxSpareServers: maximum number of server processes which are kept spare
#    MaxSpareServers      10
  $prefork_max_spare_servers = $::apache_prefork_max_spare_servers ? {
    '' => 10,
    default => $::apache_prefork_max_spare_servers
  }

# MaxClients: maximum number of server processes allowed to start
#    MaxClients          150
  $prefork_max_clients = $::apache_prefork_max_clients ? {
    '' => 150,
    default => $::apache_prefork_max_clients
  }

# MaxRequestsPerChild: maximum number of requests a server process serves
#    MaxRequestsPerChild   0
  $prefork_max_req_per_child = $::apache_prefork_max_req_per_child ? {
    '' => 0,
    default => $::apache_prefork_max_req_per_child
  }

### worker MPM

# StartServers: initial number of server processes to start
#    StartServers          2
  $worker_start_servers = $::apache_worker_start_servers ? {
    '' => 2,
    default => $::apache_worker_start_servers
  }

# MinSpareThreads: minimum number of worker threads which are kept spare
#    MinSpareThreads      25
  $worker_min_spare_threads = $::apache_worker_min_spare_threads ? {
    '' => 25,
    default => $::apache_worker_min_spare_threads
  }

# MaxSpareThreads: maximum number of worker threads which are kept spare
#    MaxSpareThreads      75
  $worker_max_spare_threads = $::apache_worker_max_spare_threads ? {
    '' => 75,
    default => $::apache_worker_max_spare_threads
  }

# ThreadLimit: ThreadsPerChild can be changed to this maximum value during a
#              graceful restart. ThreadLimit can only be changed by stopping
#              and starting Apache.
#    ThreadLimit          64
  $worker_thread_limit = $::apache_worker_thread_limit ? {
    '' => 64,
    default => $::apache_worker_thread_limit
  }

# ThreadsPerChild: constant number of worker threads in each server process
#    ThreadsPerChild      25
  $worker_threads_per_child = $::apache_worker_threads_per_child ? {
    '' => 25,
    default => $::apache_worker_threads_per_child
  }

# MaxClients: maximum number of simultaneous client connections
#    MaxClients          150
  $worker_max_clients = $::apache_worker_max_clients ? {
    '' => 150,
    default => $::apache_worker_max_clients
  }

# MaxRequestsPerChild: maximum number of requests a server process serves
#    MaxRequestsPerChild   0
  $worker_max_req_per_child = $::apache_worker_max_req_per_child ? {
    '' => 0,
    default => $::apache_worker_max_req_per_child
  }

### event MPM

# StartServers: initial number of server processes to start
#    StartServers          2
  $event_start_servers = $::apache_event_start_servers ? {
    '' => 2,
    default => $::apache_event_start_servers
  }

# MaxClients: maximum number of simultaneous client connections
#    MaxClients          150
  $event_max_clients = $::apache_event_max_clients ? {
    '' => 150,
    default => $::apache_event_max_clients
  }

# MinSpareThreads: minimum number of worker threads which are kept spare
#    MinSpareThreads      25
  $event_min_spare_threads = $::apache_event_min_spare_threads ? {
    '' => 25,
    default => $::apache_event_min_spare_threads
  }

# MaxSpareThreads: maximum number of worker threads which are kept spare
#    MaxSpareThreads      75
  $event_max_spare_threads = $::apache_event_max_spare_threads ? {
    '' => 75,
    default => $::apache_event_max_spare_threads
  }

#    ThreadLimit          64
  $event_thread_limit = $::apache_event_thread_limit ? {
    '' => 64,
    default => $::apache_event_thread_limit
  }

# ThreadsPerChild: constant number of worker threads in each server process
#    ThreadsPerChild      25
  $event_threads_per_child = $::apache_event_threads_per_child ? {
    '' => 25,
    default => $::apache_event_threads_per_child
  }

# MaxRequestsPerChild: maximum number of requests a server process serves
#    MaxRequestsPerChild   0
  $event_max_req_per_child = $::apache_event_max_req_per_child ? {
    '' => 0,
    default => $::apache_event_max_req_per_child
  }

###

  $pkg = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
    default         => undef
  }

  $root = $::apache_root ? {
    "" => $::operatingsystem ? {
      /RedHat|CentOS/ => '/var/www/vhosts',
      /Debian|Ubuntu/ => '/var/www',
      default         => undef
    },
    default => $::apache_root
  }

  $user = $::operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
    default         => undef
  }

  $conf = $::operatingsystem ? {
    /RedHat|CentOS/ => '/etc/httpd',
    /Debian|Ubuntu/ => '/etc/apache2',
    default         => undef
  }

  $log = $::operatingsystem ? {
    /RedHat|CentOS/ => '/var/log/httpd',
    /Debian|Ubuntu/ => '/var/log/apache2',
    default         => undef
  }

  $access_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/access_log",
    /Debian|Ubuntu/ => "${log}/access.log",
    default         => undef
  }

  $error_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/error_log",
    /Debian|Ubuntu/ => "${log}/error.log",
    default         => undef
  }

}
