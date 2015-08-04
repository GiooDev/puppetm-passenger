# == Class: passenger::repository
#
# This subclass manages the installation of the official repository for Passenger
#
# === Authors:
#
# Julien Georges
#
class passenger::repository {

    yumrepo { 'passenger':
        name          => 'passenger',
        baseurl       => 'https://oss-binaries.phusionpassenger.com/yum/passenger/el/7/x86_64',
        repo_gpgcheck => 1,
        gpgcheck      => 0,
        enabled       => 1,
        gpgkey        => 'https://packagecloud.io/gpg.key',
        sslverify     => 1,
        sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
    }

}
