# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
#
#
# You can execute this manifest as follows in your vagrant box:
#
#      sudo puppet apply -t /vagrant/tests/init.pp
#
node default {

    # Multipath part
    class { 'multipath':
        ensure               => 'present',
        access_timeout       => '150',
        polling_interval     => '10',
        selector             => 'round-robin 0',
        path_grouping_policy => 'group_by_prio',
        #getuid_callout       => '/lib/udev/scsi_id --whitelisted --device=/dev/%n',
        #getuid_callout       => '/sbin/scsi_id -g -u -s /block/%n',
        #prio_callout         => '/sbin/mpath_prio_alua /dev/%n',
        prio                 => 'alua /dev/%n',
        path_checker         => 'emc_clariion',
        failback             => 'immediate',
        rr_min_io            => '100',
        rr_weight            => 'uniform',
        no_path_retry        => '12',
        user_friendly_names  => 'yes'
    }

    multipath::device { 'SAN':
        ensure               => 'present',
        vendor               => 'DGC.*',  # As reported by
        product              => 'RAID.*', # /proc/scsi/scsi
        hardware_handler     => '0',
        path_grouping_policy => 'group_by_prio',
        features             => '1 queue_if_no_path',
        path_checker         => 'emc_clariion',
        path_selector        => 'round-robin 0',
        rr_weight            => 'priorities',
        no_path_retry        => '5',
        rr_min_io            => '16',
        failback             => '300'
    }

    multipath::blacklist { 'Storage server internals':
        ensure  => 'present',
        devnode => [
                    '^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*',
                    '^hd[a-z][[0-9]*]',
                    '^cciss\!c[0-9]d[0-9]*',
                    #           '^(sda|sdb|sde|sdh)'
                    '^sda'
                    ],
    }

    multipath::path {
        [
        '3600601606a47130037abf2635bb1e111',
        '3600601606a4713005d362f7b5bb1e111'
        ]:
            ensure               => 'present',
            path_grouping_policy => 'group_by_prio',
            path_selector        => 'round-robin 0',
            failback             => '300',
            rr_weight            => 'priorities',
            no_path_retry        => '5',
            rr_min_io            => '16',
    }

}
