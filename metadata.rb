name 'kafka'
maintainer 'Thirumoorthi R'
maintainer_email 'moorthy978@gmail.com'
license 'All Rights Reserved'
description 'Installs/Configures kafka'
long_description 'Installs/Configures kafka'
version '0.1.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/tramaswami/kafka-sample/issues' 

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/tramaswami/kafka-sample'

depends   'lvm', '~> 4.3.0'
