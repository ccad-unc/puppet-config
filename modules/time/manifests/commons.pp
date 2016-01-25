class time::commons {

  ### Variables used in this class ###
  $pkgs      = hiera('time_commons_packages')
  $srv       = hiera('time_commons_service')
  $cfgfile   = hiera('time_commons_maincfg') 
  $cfgfile_t = hiera('time_commons_maincfg_template')
 
  # Packages
  package { $pkgs :
    ensure     => 'installed',
  }
 
  # Service
  service { $srv :
    ensure     => 'running',
    require    => Package[$pkgs],
    subscribe  => File[$cfgfile],
  }

  # Main config file
  file { $cfgfile :
    content    => template($cfgfile_t),
    require    => Package[$pkgs],
  }


#  tools::print_config {  :
#    style   => 'keyval',
#    params  => ,
#    require => Package[]
#  }

}

