# == Class: passenger::config
#
# This subclass manages all the configuration required for Passenger
#
# === Authors:
#
# Julien Georges
#
class passenger::config inherits passenger {

    class { 'puppet':
        repository => $passenger::repository,
        ssldir     => "${passenger::ssldir}",
    } ->
    class { 'puppet::server':
        enable    => false,
        ensure    => 'stopped',
        passenger => true,
        ca_master => $passenger::ca_master,
    }

    if $ca_master { # If this server is the CA Master
        $ca_crt = 'ca/ca_crt.pem'
        $ca_crl = 'ca/ca_crl.pem'
    } else {
        $ca_crt = 'certs/ca.pem'
        $ca_crl = 'crl.pem'
    }

    include ::apache
    # Creating configuration directories before starting apache
    exec { "/bin/mkdir -p ${rack_path}":
        unless => "/bin/ls ${rack_path}";
    } ->
    file {
        "${rack_path}/config.ru":
            owner  => 'puppet',
            group  => 'puppet',
            # Getting from /usr/share/puppet/ext/rack/config.ru
            source => "puppet:///modules/passenger/config.ru";
        "${rack_path}/public":
            ensure => directory;
        "${rack_path}/tmp":
            ensure => directory;
    } ->
    # passenger settings
    class { '::apache::mod::passenger':
        passenger_high_performance   => 'On',
        # PassengerMaxPoolSize control number of application instances,
        # typically 1.5x the number of processor cores.
        passenger_max_pool_size      => $max_pool_size,
        # Shutdown idle Passenger instances after 10 min.
        passenger_pool_idle_time     => $pool_idle_time,
        passenger_stat_throttle_rate => $stat_throttle_rate,
        # Restart ruby process after handling specific number of request to resolve MRI memory leak.
        passenger_max_requests       => $max_requests,
    } ->
    apache::vhost { 'puppetmaster':
        port              => 8140,
        ssl               => true,
        ssl_protocol      => '-ALL +TLSv1',
        ssl_cipher        => 'ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP',
        ssl_cert          => "${ssldir}/certs/${puppet::server::certname}.pem",
        ssl_key           => "${ssldir}/private_keys/${puppet::server::certname}.pem",
        ssl_chain         => "${ssldir}/${ca_crt}",
        ssl_ca            => "${ssldir}/${ca_crt}",
        # If Apache complains about invalid signatures on the CRL, you can try disabling
        # CRL checking by commenting the next line, but this is not recommended.
        ssl_crl           => "${ssldir}/${ca_crl}",
        ssl_verify_client => 'optional',
        ssl_verify_depth  => 1,
        ssl_options       => [ '+StdEnvVars', '+ExportCertData' ],
        # These request headers are used to pass the client certificate
        # authentication information on to the puppet master process
        request_headers   => [
                               'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
                               'set X-Client-DN %{SSL_CLIENT_S_DN}e',
                               'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
                             ],
        docroot           => "${rack_path}/public/",
        rack_base_uris    => ['/'],
        directories       => [
                               {
                                    'path'          => "${rack_path}",
                                    'Options'       => 'None',
                                    'AllowOverride' => 'None',
                                    'Require'       => 'all granted',
                               },
                             ],
        require           => Class['puppet::server'],
    }

}
