/*

== Definition: apache::confd

Convenient wrapper around apache::conf definition to put configuration snippets in
${apache::params::conf}/conf.d directory

Parameters:
- *ensure*: present/absent.
- *configuration*: apache configuration(s) to be applied
- *filename*: basename of the file in which the configuration(s) will be put.
  Useful in the case configuration order matters: apache reads the files in conf.d/
  in alphabetical order.

Requires:
- Class["apache"]

Example usage:

  apache::confd { "example 1":
    ensure        => present,
    configuration => "WSGIPythonEggs /var/cache/python-eggs",
  }

*/
define apache::confd($ensure=present, $configuration, $filename="") {
  include apache::params
  apache::conf {$name:
    ensure        => $ensure,
    path          => "${apache::params::conf}/conf.d",
    filename      => $filename,
    configuration => $configuration,
    notify        => Service["apache"],
  }
}
