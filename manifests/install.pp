# == Class: passenger::install
#
# This subclass manages the installation of Passenger packages
#
# === Authors:
#
# Julien Georges
#
class passenger::install {

    package { $passenger::params::passenger_pkg:
        ensure  => present,
    }

}
