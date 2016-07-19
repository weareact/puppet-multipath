# File::      <tt>common.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: multipath::common
#
# Base class to be inherited by the other multipath classes, containing the common code.
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
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
        ensure => $multipath::ensure,
        name   => $multipath::params::packagename,
    }

    update::rc_local { 'Increase timeout for FC':
        ensure  => $multipath::ensure,
        content => template('multipath/rc.local.access_timeout.erb'),
        order   => 20
    }

    # TODO: deal with ensure != 'present'
    include concat::setup
    concat { $multipath::params::configfile:
        warn    => false,
        owner   => $multipath::params::configfile_owner,
        group   => $multipath::params::configfile_group,
        mode    => $multipath::params::configfile_mode,
        require => Package['multipath'],
        #notify  => Service['multipath'],
    }

    if ($multipath::configfile_source != '' or $multipath::configfile_content != '') {
        # Use the source or the content as the reference for the /etc/multipath.conf
        concat::fragment { "${multipath::params::configfile}_full":
            ensure  => $multipath::ensure,
            target  => $multipath::params::configfile,
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
            ensure  => $multipath::ensure,
            target  => $multipath::params::configfile,
            content => template('multipath/01-multipath.conf_header.erb'),
            order   => '01',
        }

        # 'devices' section
        concat::fragment { "${multipath::params::configfile}_devices_header":
            ensure => $multipath::ensure,
            target => $multipath::params::configfile,
            source => 'puppet:///modules/multipath/10-multipath-devices_header',
            order  => '10',
        }
        concat::fragment { "${multipath::params::configfile}_devices_footer":
            ensure => $multipath::ensure,
            target => $multipath::params::configfile,
            source => 'puppet:///modules/multipath/30-multipath-devices_footer',
            order  => '30',
        }

        # 'blacklist' section
        concat::fragment { "${multipath::params::configfile}_blacklist_header":
            ensure => $multipath::ensure,
            target => $multipath::params::configfile,
            source => 'puppet:///modules/multipath/35-multipath-blacklist_header',
            order  => '35',
        }

        # 'blacklist_exceptions' section
        concat::fragment { "${multipath::params::configfile}_blacklist_exceptions_header":
            ensure => $multipath::ensure,
            target => $multipath::params::configfile,
            source => 'puppet:///modules/multipath/45-multipath-blacklist_exceptions_header',
            order  => '45',
        }

        # 'multipaths' section
        concat::fragment { "${multipath::params::configfile}_multipaths_header":
            ensure => $multipath::ensure,
            target => $multipath::params::configfile,
            source => 'puppet:///modules/multipath/55-multipath-multipaths_header',
            order  => '55',
        }
        concat::fragment { "${multipath::params::configfile}_multipaths_footer":
            ensure => $multipath::ensure,
            target => $multipath::params::configfile,
            source => 'puppet:///modules/multipath/99-multipath-multipaths_footer',
            order  => '99',
        }

    }


    # service { 'multipath':
    #     ensure     => running,
    #     name       => "${multipath::params::servicename}",
    #     enable     => true,
    #     hasrestart => "${multipath::params::hasrestart}",
    #     pattern    => "${multipath::params::processname}",
    #     hasstatus  => "${multipath::params::hasstatus}",
    #     require    => Package['multipath'],
    #     #subscribe  => File['multipath.conf'],
    # }
}

