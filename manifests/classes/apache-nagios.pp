class apache::nagios {

  nagios::service::distributed {"check_apachestatus!localhost!80":
    service_description => "check apache2 status",
  }

}
