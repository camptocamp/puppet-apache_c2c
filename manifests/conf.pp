/*

== Definition: apache::conf

Convenient wrapper around File[] resources to add random configuration
snippets to apache. Shouldn't be called directly - please see apache::confd and apache::directive

Parameters:
- *ensure*:        present/absent.
- *configuration*: apache configuration(s) to be applied
- *filename*:      basename of the file in which the configuration(s) will be put.
                   Useful in the case configuration order matters: apache reads the files in conf.d/
                   in alphabetical order.
- *prefix*:        filename prefix
- *path*:          directory for the file

Requires:
- Class["apache"]

Example usage:

  apache::conf { "example 1":
    ensure        => present,
    path          => /var/www/foo/conf
    configuration => "WSGIPythonEggs /var/cache/python-eggs",
  }

*/
define apache::conf($ensure=present, $filename="", $prefix="configuration", $configuration, $path) {
  $fname = regsubst($name, '\s', '_', 'G')

  if ($path == '') {
    fail('empty "path" parameter')
  }

  if ($configuration == '' and $ensure == 'present') {
    fail('empty "configuration" parameter')
  }

  file{ "${name} configuration in ${path}":
    ensure  => $ensure,
    content => "# file managed by puppet\n${configuration}\n",
    seltype => $::operatingsystem ? {
      'RedHat' => 'httpd_config_t',
      'CentOS' => 'httpd_config_t',
      default  => undef,
    },
    path    => $filename ? {
      ''      => "${path}/${prefix}-${fname}.conf",
      default => "${path}/${filename}",
    },
    notify  => Exec['apache-graceful'],
  }

}
