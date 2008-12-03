class apache::webdav {
  package { 'tmpreaper':
    ensure => latest,
  }
  apache::module { ["dav","dav_fs"]:
    ensure => present,
  }
}
