# File::      <tt>multipath.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: multipath
#
# Configure multipath to detect multiple paths to devices for fail-over or
# performance reasons and coalesces them.
# For the moment, it is only used to configure multipathing on a disk
# bay. (tested on an NFS server and Lustre servers (OSS, MDS), each of them
# interfacing a Nexsan Disk enclosure).
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of multipath
# $configfile_source:: *Default*: ''. If set, the source of the multipath.conf file
# $configfile_content:: *Default*: ''. If set, the content of the multipath.conf file
# $FC_access_timeout:: *Default*: 150. Timeout to access a volume by Fiber Channel
# $polling_interval:: *Default*: 5. Interval between two path checks in seconds
# $verbosity:: *Default*: 2.
# $selector:: *Default*: round-robin 0. Default path selector algorithm to use
# $path_grouping_policy:: *Default*: multibus. Default path grouping policy to
#     apply to unspecified multipaths. Possible values include:
#     - failover           = 1 path per priority group
#     - multibus           = all valid paths in 1 priority group
#     - group_by_serial    = 1 priority group per detected serial number
#     - group_by_prio      = 1 priority group per path priority value
#     - group_by_node_name = 1 priority group per target node name
# $getuid_callout::  program and args to callout to obtain a unique path identifier.
# $prio_callout:: Default function to call to obtain a path priority value
# $path_checker:: Default method used to determine the paths' state
# $failback:: *Default*: manual. Tells the daemon to manage path group failback,
#     or not to. Possible values: manual|immediate|n > 0.
#     0 means immediate failback, values >0 means deffered failback expressed in seconds.
# $rr_weight:: *Default*: uniform. Possible values: priorities|uniform. if set
#     to priorities, the multipath configurator will assign path weights as:
#                     "path prio * rr_min_io"
# $rr_min_io:: *Default*: 1000
# $no_path_retry::  Tells the number of retries until disable queueing, or
#     "fail" means immediate failure (no queueing) while "queue" means never stop
#     queueing. Possible values: queue|fail|n (>0)
# $user_friendly_names:: *Default*: no. If set to "yes", using the bindings file
#     /var/lib/multipath/bindings to assign a persistent and unique alias to the
#     multipath, in the form of mpath<n>. If set to "no", use the WWID as the
#     alias. In either case, this be will be overriden by any specific aliases
#     in this file.
# $max_fds:: Sets the maximum number of open file descriptors for the multipathd
#     process. Possible values: max|n > 0
#
# == Actions:
#
# Install and configure multipath
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import multipath
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'multipath':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class multipath(
    $ensure               = $multipath::params::ensure,
    $access_timeout       = $multipath::params::access_timeout,
    $configfile_source    = '',
    $configfile_content   = '',
    $polling_interval     = $multipath::params::polling_interval,
    $selector             = $multipath::params::selector,
    $path_grouping_policy = $multipath::params::path_grouping_policy,
    $getuid_callout       = $multipath::params::getuid_callout,
    $prio_callout         = $multipath::params::prio_callout,
    $prio                 = $multipath::params::prio,
    $path_checker         = $multipath::params::path_checker,
    $failback             = $multipath::params::failback,
    $no_path_retry        = $multipath::params::no_path_retry,
    $rr_weight            = $multipath::params::rr_weight,
    $rr_min_io            = $multipath::params::rr_min_io,
    $user_friendly_names  = $multipath::params::user_friendly_names,
    $max_fds              = $multipath::params::max_fds
)
inherits multipath::params
{
    info ("Configuring multipath (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("Invalid multipath 'ensure' parameter")
    }
    if ! ($path_grouping_policy in [ 'failover', 'multibus', 'group_by_serial', 'group_by_prio', 'group_by_node_name']) {
        fail("Invalid multipath 'path_grouping_policy' parameter")
    }
    if ($selector != "round-robin 0") {
        fail("Invalid multipath 'selector' parameter")
    }
    if ! ($path_checker in [ 'readsector0', 'tur', 'emc_clariion', 'hp_sw', 'directio', 'rdac', 'cciss_tur']) {
        fail("Invalid multipath 'path_checker' parameter")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include multipath::debian }
        #redhat, fedora, centos: { include multipath::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: multipath::common
#
# Base class to be inherited by the other multipath classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class multipath::common {

    # Load the variables used in this module. Check the multipath-params.pp file
    require multipath::params

    package { 'multipath':
        name    => "${multipath::params::packagename}",
        ensure  => "${multipath::ensure}",
    }

    update::rc_local { 'Increase timeout for FC':
        ensure  => "${multipath::ensure}",
        content => template("multipath/rc.local.access_timeout.erb"),
        order   => 20
    }

    # TODO: deal with ensure != 'present'
    include concat::setup
    concat { "${multipath::params::configfile}":
        warn    => false,
        owner   => "${multipath::params::configfile_owner}",
        group   => "${multipath::params::configfile_group}",
        mode    => "${multipath::params::configfile_mode}",
        require => Package['multipath'],
        #notify  => Service['multipath'],
    }

    if ($multipath::configfile_source != '' or $multipath::configfile_content != '') {
        # Use the source or the content as the reference for the /etc/multipath.conf
        concat::fragment { "${multipath::params::configfile}_full":
            target  => "${multipath::params::configfile}",
            ensure  => "${multipath::ensure}",
            order   => 01,
            content => $multipath::configfile_content,
            source  => $multipath::configfile_source,
            #notify  => Service['multipath'],
        }
    }
    else
    {
        # Here, build the /etc/multipath.conf by fragments, starting from the
        # defaults settings (precised with the classe instanciation), the rest
        # beeing set by the following definitions:
        #    - multipath::device    (to define a device)
        #    - multipath::blacklist (to blacklist some device from multipathing)
        #    - multipath::path      (to define a path to a device)
        concat::fragment { "${multipath::params::configfile}_header":
            target  => "${multipath::params::configfile}",
            ensure  => "${multipath::ensure}",
            content => template("multipath/01-multipath.conf_header.erb"),
            order   => '01',
        }

        # 'devices' section
        concat::fragment { "${multipath::params::configfile}_devices_header":
            target  => "${multipath::params::configfile}",
            ensure  => "${multipath::ensure}",
            source  => 'puppet:///modules/multipath/10-multipath-devices_header',
            order   => '10',
        }
        concat::fragment { "${multipath::params::configfile}_devices_footer":
            target  => "${multipath::params::configfile}",
            ensure  => "${multipath::ensure}",
            source  => 'puppet:///modules/multipath/30-multipath-devices_footer',
            order   => '30',
        }

        # 'blacklist' section
        concat::fragment { "${multipath::params::configfile}_blacklist_header":
            target  => "${multipath::params::configfile}",
            ensure  => "${multipath::ensure}",
            source  => 'puppet:///modules/multipath/35-multipath-blacklist_header',
            order   => '35',
        }

        # 'blacklist_exceptions' section
        concat::fragment { "${multipath::params::configfile}_blacklist_exceptions_header":
            target  => "${multipath::params::configfile}",
            ensure  => "${multipath::ensure}",
            source  => 'puppet:///modules/multipath/45-multipath-blacklist_exceptions_header',
            order   => '45',
        }

        # 'multipaths' section
        concat::fragment { "${multipath::params::configfile}_multipaths_header":
            target  => "${multipath::params::configfile}",
            ensure  => "${multipath::ensure}",
            source  => 'puppet:///modules/multipath/55-multipath-multipaths_header',
            order   => '55',
        }
        concat::fragment { "${multipath::params::configfile}_multipaths_footer":
            target  => "${multipath::params::configfile}",
            ensure  => "${multipath::ensure}",
            source  => 'puppet:///modules/multipath/99-multipath-multipaths_footer',
            order   => '99',
        }

    }


    # service { 'multipath':
    #     name       => "${multipath::params::servicename}",
    #     enable     => true,
    #     ensure     => running,
    #     hasrestart => "${multipath::params::hasrestart}",
    #     pattern    => "${multipath::params::processname}",
    #     hasstatus  => "${multipath::params::hasstatus}",
    #     require    => Package['multipath'],
    #     #subscribe  => File['multipath.conf'],
    # }
}


# ------------------------------------------------------------------------------
# = Class: multipath::debian
#
# Specialization class for Debian systems
class multipath::debian inherits multipath::common {

    # Extra package to provide useful tools to manipulate SCSI
    package { 'sg3-utils':
        ensure => "${multipath::ensure}"
    }

    update::rc_local { 'FIX bad discovery of multipath':
        ensure => "${multipath::ensure}",
        source => "puppet:///modules/multipath/rc.local.debian.fix_bad_multipath_discovery",
        order  => 60
    }

}

# ------------------------------------------------------------------------------
# = Class: multipath::redhat
#
# Specialization class for Redhat systems
class multipath::redhat inherits multipath::common { }



