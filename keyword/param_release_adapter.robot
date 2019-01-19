*** Settings ***
Documentation    parameter file for cmd adapter in different release will used by release_cmd_adapter keyword
Resource         ../base.robot

*** Variables ***
# default release: AXOS_3_1
&{prov_interface_ip_config_mask}
...    DEFAULT=/%s
...    AXOS_4_1= mask %s

# default release: AXOS_3_4 and later
&{show_version_match_version}
...    DEFAULT=details\\s+%s
...    AXOS_3_1=description\\s+%s

# default release: AXOS_3_1
&{prov_policy_map_config_add_tag}
...    DEFAULT=add-cevlan-tag
...    AXOS_4_1=add-ctag

# default release: AXOS_3_4 and later
&{prov_reload_cmd}
...    DEFAULT=all
...    AXOS_3_1=

# default release: AXOS_3_4 and later
&{prov_interface_ethernet_lag}
...    AXOS_3_1=group
...    DEFAULT=system-lag

# provision rmon-session bin-count for interface pon, default release: AXOS_4_2 and later
&{prov_interface_pon_config_rmon_session_bin_count}
...    AXOS_3_1=%s
...    AXOS_3_4=%s
...    DEFAULT=bin-count %s
...    AXOS_19_1=%s

# deprovision rmon-session bin-count for interface pon, default release: AXOS_4_2 and later
&{prov_interface_pon_rmon_session_bin_duration_view}
...    AXOS_3_1=bin-count
...    AXOS_3_4=bin-count
...    DEFAULT=
...    AXOS_19_1=bin-count

# clear igmp statistics, default release: AXOS_4_2 and later
&{clear_igmp_statistics_vlan}
...    AXOS_3_1=vlan-id %s
...    AXOS_3_4=vlan-id %s
...    DEFAULT=%s

#show info fan-speed change to show sensors fan, default : AXOS_4_2 and later
&{show_info_fan_speed}
...    AXOS_3_1=speed
...    AXOS_3_4=speed
...    DEFAULT=

#vlan egress configure, default : AXOS_4_2 and later
&{prov_vlan_egress}
...    AXOS_3_1=
...    AXOS_3_4=
...    DEFAULT=egress
 


#########################parameter added by ARF, DONOT change, start#########################
# for icmp ping, version: default AXOS_3_4_0
&{ping_version}
...    AXOS_3_1=20121221
...    DEFAULT=20151218

&{detail_version}
...    AXOS_3_1=description
...    DEFAULT=details
#########################parameter added by ARF, DONOT change, end#########################
