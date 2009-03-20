class apache::nagios {

  nagios::service::distributed {"check_apachestatus":
    service_description => "check apache2 status",
  }

}
