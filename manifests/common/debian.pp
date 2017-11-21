# File::      <tt>common/debian.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: multipath::common::debian
#
# Specialization class for Debian systems
class multipath::common::debian inherits multipath::common {

    # Extra package to provide useful tools to manipulate SCSI
    package { 'sg3-utils':
        ensure => $multipath::ensure,
    }

    # update::rc_local { 'FIX bad discovery of multipath':
    #     ensure => "${multipath::ensure}",
    #     source => "puppet:///modules/multipath/rc.local.debian.fix_bad_multipath_discovery",
    #     order  => 60
    # }

}
