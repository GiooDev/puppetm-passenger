# == Class: passenger::params
#
# This subclass manages all the default parameters for Passenger module
#
# === Authors:
#
# Julien Georges
#
class passenger::params {

    case $::osfamily {
        'RedHat': {
            $passenger_pkg  = 'mod_passenger'
        }
        'Debian': {
            $passenger_pkg  = 'libapache2-mod-passenger'
        }
        default: {
            fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
        }
    }

}
