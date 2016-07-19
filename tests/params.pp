# File::      <tt>params.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'multipath::params'

$names = ["ensure", "access_timeout", "polling_interval", "selector", "path_grouping_policy", "getuid_callout", "prio_callout", "prio", "path_checker", "failback", "no_path_retry", "rr_min_io", "rr_weight", "user_friendly_names", "max_fds", "packagename", "servicename", "processname", "hasstatus", "hasrestart", "configfile", "configfile_mode", "configfile_owner", "configfile_group"]

notice("multipath::params::ensure = ${multipath::params::ensure}")
notice("multipath::params::access_timeout = ${multipath::params::access_timeout}")
notice("multipath::params::polling_interval = ${multipath::params::polling_interval}")
notice("multipath::params::selector = ${multipath::params::selector}")
notice("multipath::params::path_grouping_policy = ${multipath::params::path_grouping_policy}")
notice("multipath::params::getuid_callout = ${multipath::params::getuid_callout}")
notice("multipath::params::prio_callout = ${multipath::params::prio_callout}")
notice("multipath::params::prio = ${multipath::params::prio}")
notice("multipath::params::path_checker = ${multipath::params::path_checker}")
notice("multipath::params::failback = ${multipath::params::failback}")
notice("multipath::params::no_path_retry = ${multipath::params::no_path_retry}")
notice("multipath::params::rr_min_io = ${multipath::params::rr_min_io}")
notice("multipath::params::rr_weight = ${multipath::params::rr_weight}")
notice("multipath::params::user_friendly_names = ${multipath::params::user_friendly_names}")
notice("multipath::params::max_fds = ${multipath::params::max_fds}")
notice("multipath::params::packagename = ${multipath::params::packagename}")
notice("multipath::params::servicename = ${multipath::params::servicename}")
notice("multipath::params::processname = ${multipath::params::processname}")
notice("multipath::params::hasstatus = ${multipath::params::hasstatus}")
notice("multipath::params::hasrestart = ${multipath::params::hasrestart}")
notice("multipath::params::configfile = ${multipath::params::configfile}")
notice("multipath::params::configfile_mode = ${multipath::params::configfile_mode}")
notice("multipath::params::configfile_owner = ${multipath::params::configfile_owner}")
notice("multipath::params::configfile_group = ${multipath::params::configfile_group}")

#each($names) |$v| {
#    $var = "multipath::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
