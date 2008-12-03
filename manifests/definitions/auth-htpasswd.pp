define apache::auth::htpasswd ($ensure=present, $file, $username, $password) {
  exec {"! test -f $file && OPT='-c'; htpasswd -b \$OPT $file $username $password":
    unless  => "grep -q $username $file",
  }
}
