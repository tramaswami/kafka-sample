#
# Cookbook:: kafka
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

##STEP 1
hostname 'kafka-machine'
##STEP 2
ENV['http_proxy'] = ''

packs = ['lvm2','nc','sysstat','lsof']
packs.each do |pack|
    package "#{pack}" do
      action :upgrade
    end
  end
##STEP 3 
lines = ['connect soft nofile 99000','connect hard nofile 99000','connect soft nproc 99000','connect hard nproc 99000']

lines.each do |line| 

    file = Chef::Util::FileEdit.new('/etc/security/limits.conf')
    file.insert_line_if_no_match(/#{line}/, line)
    file.write_file

end

lines2 = ['connect soft nproc 99000','connect hard nproc 99000']

lines2.each do |line| 

    file = Chef::Util::FileEdit.new('/etc/security/limits.d/20-nproc.conf')
    file.insert_line_if_no_match(/#{line}/, line)
    file.write_file

end

kernel_params = [
    {
        'name' => 'net.core.wmem_default',
        'value'=> '131072'
    },
    {
        'name' => 'vm.swappiness',
        'value'=> '1'
    },
    {
        'name' => 'net.core.wmem_max',
        'value'=> '2097152'
    },
    {
        'name' => 'net.core.rmem_max',
        'value'=> '2097152'
    },
    {
        'name' => 'net.ipv4.tcp_window_scaling',
        'value'=> '1'
    }
]

kernel_params.each do |kp|  
    sysctl kp['name'] do
        value kp['value']
    end
  end


  user 'connect' do
    action :create
  end

  group 'connect' do
    members 'connect'
    action :create
  end
  
  %w[ /sdp /usr/java /sdp/sw /sdp/oracle ].each do |path|
    directory path do
      owner 'connect'
      group 'connect'
      mode '0755'
    end
  end

  lvm_physical_volume '/dev/sdb'

  lvm_volume_group 'appvg' do
    physical_volumes ['/dev/sdb']
    wipe_signatures true
    
    logical_volume 'jdk' do
        size        '100M'
        filesystem  'xfs'
        mount_point location: '/usr/java', options: 'noatime'

    end

    logical_volume 'sw' do
        size        '100M'
        filesystem  'xfs'
        mount_point location: '/sdp/sw', options: 'noatime'
    end

    logical_volume 'log' do
        size        '100M'
        filesystem  'xfs'
        mount_point location: '/sdp/log', options: 'noatime'
    end

end

remote_file '/sdp/sw/unrar-5.60-1.0.cf.rhel7.x86_64.rpm' do
  source 'http://www.city-fan.org/ftp/contrib/yum-repo/rhel7/x86_64/unrar-5.60-1.0.cf.rhel7.x86_64.rpm'
  owner 'connect'
  group 'connect'
  mode '0755'
  action :create
end


rpm_package '/sdp/sw/unrar-5.60-1.0.cf.rhel7.x86_64.rpm' do
  action :install
end

link '/tmp/confluent-4.1.1' do
    to '/tmp/confluent'
    link_type :symbolic
end

file "/etc/systemd/system/conect.service" do
    owner 'connect'
    group 'connect'
    mode 0755
    content ::File.open("/sdp/sw/config").read
    action :create
  end


# service 'connect' do
#   action [ :enable, :start ]
# end
  