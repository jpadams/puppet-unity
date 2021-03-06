
# Define a Unity System
unity_system { 'FNM12345678901':
  ip       => '192.168.1.50',
  user     => 'admin',
  password => 'password',
}

# Create a Unity Pool
unity_pool { 'puppet_pool':
  unity_system            => Unity_system['FNM12345678901'],
  description             => 'created by puppet module',
  raid_groups             => [{
    disk_group   => 'dg_15',
    raid_type    => 1,
    stripe_width => 0,
    disk_num     => 5,
  }],
  alert_threshold         => 80,
  is_snap_harvest_enabled => true,
  is_harvest_enabled      => true,
  ensure                  => present,
}

# Create a Unity IO limit policy (density-based)
unity_io_limit_policy { 'puppet_policy':
  unity_system     => Unity_system['FNM12345678901'],
  policy_type      => 2,
  description      => 'Created by puppet',
  max_iops_density => 100,
  max_kbps_density => 1024,
}

# Create a Host for lun access
unity_host { 'my_host':
  unity_system => Unity_system['FNM12345678901'],
  description  => 'Created by puppet',
  ip           => '192.168.1.139',
  os           => 'Ubuntu16',
  host_type    => 1,
  iqn          => 'iqn.1993-08.org.debian:01:unity-puppet-host',
  wwns         => ['20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D3',
    '20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D4'],
  ensure       => present,
}

# Create another Host for lun access
unity_host { 'my_host2':
  unity_system => Unity_system['FNM12345678901'],
  description  => 'Created by puppet2',
  ip           => '192.168.1.140',
  os           => 'Ubuntu14',
  host_type    => 1,
  # iqn          => 'iqn.1993-08.org.debian:01:unity-puppet-host',
  # wwns         => ['20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D3',
  #   '20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D4'],
  ensure       => present,
}

# Create a Lun, and
# 1. Configure the IO limit policy
# 2. Assign host access
unity_lun { 'puppet_lun':
  unity_system    => Unity_system['FNM12345678901'],
  pool            => Unity_pool['puppet_pool'],
  size            => 30,
  thin            => true,
  compression     => false,
  sp              => 0,
  description     => "Created by puppet_unity.",
  io_limit_policy => Unity_io_limit_policy['puppet_policy'],
  hosts           => [Unity_host['my_host']],
  ensure          => present,
}
