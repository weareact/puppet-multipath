name       'multipath'
version    '0.1.0'
source     'git-admin.uni.lu:puppet-repo.git'
author     'Sebastien Varrette (Sebastien.Varrette@uni.lu)'
license    'GPL v3'
summary    'Configure multipath to detect multiple paths to devices for fail-over or performance reasons and coalesces them'
description 'Configure multipath to detect multiple paths to devices for fail-over or performance reasons and coalesces them'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes    'multipath::params, multipath, multipath::common, multipath::debian, multipath::redhat'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'concat'
defines    '["multipath::blacklist", "multipath::device", "multipath::path"]'
