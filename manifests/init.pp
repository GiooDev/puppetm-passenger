# == Class: passenger
#
# Full description of class passenger here.
#
# Official documentation about passenger is available here:
#  - https://docs.puppetlabs.com/guides/passenger.html
#  - https://www.phusionpassenger.com/library/install/apache/install/oss/el7/
#  - https://www.phusionpassenger.com/library/install/apache/install/oss/jessie/
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#    class { 'puppet':
#        repository  => false,
#
#        #Default values...
#        #ssldir     => '/var/lib/puppet/ssl',
#        #repository => true,
#    } ->
#    class { 'puppet::server':
#        passenger       => true,
#        dns_alt_names   => "puppet,puppet.${::domain}",
#
#        #Default values...
#        #environmentpath => '$confdir/environments',
#        #external_nodes  => '/usr/local/bin/puppet_node_classifier',
#        #passenger       => false,
#        #certname        => $::fqdn,
#        #dns_alt_names   => undef,
#        #ca_master       => true,
#    }->
#    class { 'passenger':
#        rack_path           => '/var/www/html/puppet/rack/puppetmasterd',
#        repository          => false,
#
#        #Default values...
#        #rack_path          => '/usr/share/puppet/rack/puppetmasterd',
#        #ssldir             => '/var/lib/puppet/ssl',
#        #max_pool_size      => 12,
#        #pool_idle_time     => 600,
#        #stat_throttle_rate => 120,
#        #max_requests       => undef,
#        #ca_master          => true,
#        #repository         => true,
#    }
#
# === Authors
#
# Julien Georges <GiooDev@users.noreply.github.com>
#
# === Copyright
#
# Copyright 2015 Julien Georges
#
class passenger (
    $rack_path          = '/usr/share/puppet/rack/puppetmasterd',
    $ssldir             = '/var/lib/puppet/ssl',
    #apache::mod::passenger configurations
    $max_pool_size      = 12,
    $pool_idle_time     = 600,
    $stat_throttle_rate = 120,
    $max_requests       = undef,
    $ca_master          = true, 

    $repository         = true,
) inherits passenger::params {

    # Allow selection of repository configuration
    if $repository {
        require passenger::repository
    }

    include passenger::install
    include passenger::config
    Class['passenger::install'] ->
    Class['passenger::config']

}
