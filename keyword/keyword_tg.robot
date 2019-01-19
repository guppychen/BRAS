*** Settings ***
Documentation    tg keyword, only support stc operation now
Resource         ../base.robot

*** Keywords ***
############################################# tg operation keyword ################################################
create_dhcp_server
    [Arguments]    ${tg}    ${server_name}    ${port}    ${server_mac}    ${server_ip}    ${pool_ip_start}
    ...    ${ovlan}=${EMPTY}    ${ivlan}=${EMPTY}    ${ovlan_pbit}=7    ${ivlan_pbit}=7
    ...    ${pool_size}=128    ${lease_time}=300    ${gateway}=${EMPTY}    &{dict_option}
    [Documentation]    Description: setup dhcp server on traffic generater
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | server_name | dhcp server name |
    ...    | port | tg port name in topo.yaml |
    ...    | server_mac | dhcp server mac |
    ...    | server_ip | dhcp server ip |
    ...    | pool_ip_start | dhcp pool start ip |
    ...    | ovlan | dhcp server outer vlan |
    ...    | ivlan | dhcp server inner vlan |
    ...    | ovlan_pbit | dhcp server outer vlan pbit |
    ...    | ivlan_pbit | dhcp server inner vlan pbit |
    ...    | pool_size | dhcp pool size, default value=128 |
    ...    | lease_time | dhcp lease, default value=300 |
    ...    | dict_option | dictionary type tg paramater, format as param_key=param_value |
    ...
    ...    Example:
    ...    1. create untag dhcp server
    ...    | create_dhcp_server | tg1 | dhcps_utag | service_p1 | ${server_mac} | ${server_ip} | ${pool_ip_start} | lease_time=50 | 
    ...    2. create single tag dhcp server
    ...    | create_dhcp_server | tg1 | dhcps_stag | service_p1 | ${server_mac} | ${server_ip} | ${pool_ip_start} | 100 | lease_time=100 | 
    ...    3. create double tag dhcp server
    ...    | create_dhcp_server | tg1 | dhcps_dtag | service_p1 | ${server_mac} | ${server_ip} | ${pool_ip_start} | 100 | 300 | lease_time=100 | 
    [Tags]    @author=CindyGao
    log    ****** [${tg}:${port}] create dhcp server ${server_name} with mac:${server_mac} ip:${server_ip} ovlan:${ovlan} ivlan:${ivlan} ******
    Run Keyword If    '${EMPTY}'=='${ovlan}'    Set To Dictionary    ${dict_option}    encapsulation=ETHERNET_II
    ...    ELSE IF    '${EMPTY}'=='${ivlan}'    Set To Dictionary    ${dict_option}    encapsulation=ETHERNET_II_VLAN    vlan_id=${ovlan}    vlan_user_priority=${ovlan_pbit}
    ...    ELSE    Set To Dictionary    ${dict_option}    encapsulation=ETHERNET_II_QINQ    vlan_outer_id=${ovlan}    vlan_outer_user_priority=${ovlan_pbit}    vlan_id=${ivlan}    vlan_user_priority=${ivlan_pbit}

    log    set server_ip as gateway if not specify gateway
    ${gateway}    Set Variable If    '${EMPTY}'=='${gateway}'    ${server_ip}    ${gateway}
    Tg Create Dhcp Server On Port    ${tg}    ${server_name}    ${port}    local_mac=${server_mac}
    ...    ip_version=4    ip_address=${server_ip}    ip_gateway=${gateway}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${gateway}
    ...    ipaddress_pool=${pool_ip_start}    ipaddress_count=${pool_size}    lease_time=${lease_time}    &{dict_option}

create_dhcp_client
    [Arguments]    ${tg}    ${client_name}    ${port}    ${group_name}    ${client_mac}
    ...    ${ovlan}=${EMPTY}    ${ivlan}=${EMPTY}    ${ovlan_pbit}=0    ${ivlan_pbit}=0
    ...    ${first_group}=true    ${session}=1    &{dict_option}
    [Documentation]    Description: setup single tag dhcp client on traffic generater
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | client_name | dhcp client name |
    ...    | port | tg port name in topo.yaml |
    ...    | group_name | dhcp client group name |
    ...    | client_mac | dhcp client mac |
    ...    | ovlan | dhcp client outer vlan |
    ...    | ivlan | dhcp client inner vlan |
    ...    | ovlan_pbit | dhcp client outer vlan pbit |
    ...    | ivlan_pbit | dhcp client inner vlan pbit |
    ...    | session | dhcp client session number, default value=1 |
    ...    | dict_option | dictionary type tg paramater, format as param_key=param_value |
    ...
    ...    Example:
    ...    1. create untag dhcp client
    ...    | create_dhcp_client | tg1 | dhcpc_utag | subscriber_p1 | grp_utag | ${client_mac} | 
    ...    2. create single tag dhcp client
    ...    | create_dhcp_client | tg1 | dhcpc_stag | subscriber_p1 | grp_stag | ${client_mac} | 100 | session=10 |
    ...    3. create double tag dhcp client
    ...    | create_dhcp_client | tg1 | dhcpc_dtag | subscriber_p1 | grp_dtag | ${client_mac} | 100 | 300 |
    [Tags]    @author=CindyGao
    log    ****** [${tg}:${port}] create dhcp client ${client_name} with mac:${client_mac} ovlan:${ovlan} ivlan:${ivlan} ******
    Run Keyword If    'true'=='${first_group}'    Tg Create Dhcp Client On Port    ${tg}    ${client_name}    ${port}

    Run Keyword If    '${EMPTY}'=='${ovlan}'    Set To Dictionary    ${dict_option}    encap=ethernet_ii
    ...    ELSE IF    '${EMPTY}'=='${ivlan}'    Set To Dictionary    ${dict_option}    encap=ethernet_ii_vlan    vlan_id=${ovlan}    vlan_user_priority=${ovlan_pbit}
    ...    ELSE    Set To Dictionary    ${dict_option}    encap=ethernet_ii_qinq    vlan_id_outer=${ovlan}    vlan_outer_user_priority=${ovlan_pbit}    vlan_id=${ivlan}    vlan_user_priority=${ivlan_pbit}
    Tg Create Dhcp Client Group    ${tg}    ${group_name}    ${client_name}
    ...    mac_addr=${client_mac}    num_sessions=${session}    &{dict_option}

create_bound_traffic_udp
    [Arguments]    ${tg}    ${traffic_name}    ${port}    ${dst_device}    ${src_device}    ${rate_mbps}=${EMPTY}    ${rate_pps}=${EMPTY}
    ...    ${frame_size}=512    ${udp_dst_port}=6000    ${udp_src_port}=6000    &{dict_option}
    [Documentation]    Description: create bound traffic with udp head on traffic generater
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | traffic_name | bound traffic name |
    ...    | port | tg port name in topo.yaml |
    ...    | dst_device | traffic destination device name |
    ...    | src_device | traffic source device name |
    ...    | rate_mbps | traffic rate (mbps), set rate_mbps or rate_pps |
    ...    | rate_pps | traffic rate (frame/sec), set rate_mbps or rate_pps |
    ...    | frame_size | traffic size, default value=512 |
    ...    | udp_dst_port | udp destination port, default value=6300 |
    ...    | udp_src_port | udp source port, default value=6400 |
    ...    | dict_option | dictionary type tg paramater, format as param_key=param_value |
    ...
    ...    Example:
    ...    1. create bound traffic with rate 10mbps
    ...    | create_bound_traffic_udp | tg1 | us_bound | subscriber_p1 | ${server_name} | ${client_group} | 10 | 
    ...    2. create bound traffic with rate 1000 frame/sec
    ...    | create_bound_traffic_udp | tg1 | us_bound | subscriber_p1 | ${server_name} | ${client_group} | rate_pps=1000 |
    ...    3. create bound traffic with rate 10mbps, frame size 256
    ...    | create_bound_traffic_udp | tg1 | us_bound | subscriber_p1 | ${server_name} | ${client_group} | 10 | frame_size=256 |
    [Tags]    @author=CindyGao
    log    ****** [${tg}:${port}] create bound traffic from ${src_device} to ${dst_device} ******
    ${rate_bps}    Run Keyword If    '${EMPTY}'!='${rate_mbps}'    evaluate    ${rate_mbps}*1000000
    Run Keyword If    '${EMPTY}'!='${rate_mbps}'    Set To Dictionary    ${dict_option}    rate_bps=${rate_bps}
    ...    ELSE IF    '${EMPTY}'!='${rate_pps}'    Set To Dictionary    ${dict_option}    rate_pps=${rate_pps}

    Tg Create Bound Untagged Stream On Port    ${tg}    ${traffic_name}    ${port}     ${dst_device}    ${src_device}
    ...    l4_protocol=udp    udp_dst_port=${udp_dst_port}   udp_src_port=${udp_src_port}
    ...    frame_size=${frame_size}    length_mode=fixed    &{dict_option}

create_raw_traffic_udp
    [Arguments]    ${tg}    ${traffic_name}    ${dst_port}    ${src_port}
    ...    ${ovlan}=${EMPTY}    ${ivlan}=${EMPTY}    ${ovlan_pbit}=0    ${ivlan_pbit}=0
    ...    ${mac_dst}=${EMPTY}    ${mac_src}=${EMPTY}    ${ip_dst}=${EMPTY}    ${ip_src}=${EMPTY}
    ...    ${rate_mbps}=${EMPTY}    ${rate_pps}=${EMPTY}    ${frame_size}=512    ${udp_dst_port}=6000    ${udp_src_port}=6000    &{dict_option}
    [Documentation]    Description: create bound traffic with udp head on traffic generater
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | traffic_name | traffic name |
    ...    | dst_port | tg destination port name in topo.yaml |
    ...    | src_port | tg source port name in topo.yaml |
    ...    | ovlan | traffic outer vlan |
    ...    | ivlan | traffic inner vlan |
    ...    | ovlan_pbit | traffic outer vlan pbit |
    ...    | ivlan_pbit | traffic inner vlan pbit |
    ...    | mac_dst | destination mac |
    ...    | mac_src | source mac |
    ...    | ip_dst | destination ip |
    ...    | ip_src | source ip |
    ...    | rate_mbps | traffic rate (mbps), set rate_mbps or rate_pps |
    ...    | rate_pps | traffic rate (frame/sec), set rate_mbps or rate_pps |
    ...    | frame_size | traffic size, default value=512 |
    ...    | udp_dst_port | udp destination port, default value=6300 |
    ...    | udp_src_port | udp source port, default value=6400 |
    ...    | dict_option | dictionary type tg paramater, format as param_key=param_value |
    ...
    ...    Example:
    ...    1. create untag raw traffic
    ...    | create_raw_traffic_udp | tg1 | up_raw1 | service_p1 | subscriber_p1 | mac_dst=${server_mac} | mac_src=${client_mac} | ip_dst=${server_ip} | ip_src=${pool_ip_start} | rate_pps=1000 | 
    ...    2. create single tag raw traffic
    ...    | create_raw_traffic_udp | tg1 | up_raw2 | service_p1 | subscriber_p1 | 100 | mac_dst=${server_mac} | mac_src=${client_mac} | ip_dst=${server_ip} | ip_src=${pool_ip_start} | rate_pps=1000 | 
    ...    3. create double tag raw traffic
    ...    | create_raw_traffic_udp | tg1 | up_raw3 | service_p1 | subscriber_p1 | 100 | 300 | mac_dst=${server_mac} | mac_src=${client_mac} | ip_dst=${server_ip} | ip_src=${pool_ip_start} | rate_mbps=10 | 
    [Tags]    @author=CindyGao
    log    ****** [${tg} port ${src_port} to ${dst_port}] create raw traffic with mac_dst:${mac_dst} mac_src:${mac_src} ip_dst:${ip_dst} ip_src:${ip_src} ovlan:${ovlan} ivlan:${ivlan}******
    Set To Dictionary    ${dict_option}        mac_dst=${mac_dst}    mac_src=${mac_src}
    ...    l3_protocol=ipv4    ip_dst_addr=${ip_dst}    ip_src_addr=${ip_src}
    ...    l4_protocol=udp    udp_dst_port=${udp_dst_port}    udp_src_port=${udp_src_port}
    ...    length_mode=fixed    frame_size=${frame_size}

    ${rate_bps}    Run Keyword If    '${EMPTY}'!='${rate_mbps}'    evaluate    ${rate_mbps}*1000000
    Run Keyword If    '${EMPTY}'!='${rate_mbps}'    Set To Dictionary    ${dict_option}    rate_bps=${rate_bps}
    ...    ELSE IF    '${EMPTY}'!='${rate_pps}'    Set To Dictionary    ${dict_option}    rate_pps=${rate_pps}

    Run Keyword If    '${EMPTY}'=='${ovlan}'    TG Create Untagged Stream On Port    ${tg}    ${traffic_name}    ${dst_port}    ${src_port}    &{dict_option}
    ...    ELSE IF    '${EMPTY}'=='${ivlan}'   TG Create Single Tagged Stream On Port    ${tg}    ${traffic_name}    ${dst_port}    ${src_port}    ${ovlan}    ${ovlan_pbit}    &{dict_option}
    ...    ELSE   TG Create Double Tagged Stream On Port    ${tg}    ${traffic_name}    ${dst_port}    ${src_port}    ${ivlan}    ${ivlan_pbit}    ${ovlan}    ${ovlan_pbit}    &{dict_option}

create_rg_bidirection_bound_traffic
    [Arguments]    ${tg}    ${us_traffic_name}    ${ds_traffic_name}    ${us_tg_port}    ${ds_tg_port}    ${us_rate_mbps}    ${ds_rate_mbps}
    ...    ${us_device}    ${ds_device}    ${wan_mac}    ${wan_ip}    ${rg_ip}=192.168.1.1
    ...    ${wan_ovlan}=${EMPTY}    ${wan_ivlan}=${EMPTY}    ${wan_ovlan_pbit}=0    ${wan_ivlan_pbit}=0
    ...    ${frame_size}=512    ${us_udp_port}=6700    ${ds_udp_port}=6800    &{dict_option}
    [Documentation]    Description: create bound traffic with udp head on traffic generater
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | us_traffic_name | upstream bound traffic name |
    ...    | ds_traffic_name | downstream bound traffic name |
    ...    | us_tg_port | uplink tg port name in topo.yaml |
    ...    | ds_tg_port | host side tg port name in topo.yaml |
    ...    | us_rate_mbps | upstream traffic rate (mbps) |
    ...    | ds_rate_mbps | downstream traffic rate (mbps) |
    ...    | us_device | uplink device name |
    ...    | ds_device | host side device name |
    ...    | wan_mac | ont wan mac |
    ...    | wan_ip | ont wan ip get from dhcp server |
    ...    | rg_ip | ont rg port ip, default=192.168.1.1 |
    ...    | wan_ovlan | simulate wan device outer vlan |
    ...    | wan_ivlan | simulate wan device inner vlan |
    ...    | wan_ovlan_pbit | simulate wan device outer vlan pbit |
    ...    | wan_ivlan_pbit | simulate wan device inner vlan pbit |
    ...    | frame_size | traffic size, default=512 |
    ...    | us_udp_port | uplink side udp port, default=6700 |
    ...    | ds_udp_port | host side udp port, default=6800 |
    ...    | dict_option | dictionary type tg paramater, format as param_key=param_value |
    ...
    ...    Example:
    ...    | create_rg_bidirection_bound_traffic | tg1 | us_bound_rg | ds_bound_rg | service_p1 | subscriber_p1 | 10 | 10 |
    ...    | ... | ${server_name} | ${client_group} | ${wan_mac} | ${wan_ip} | ${rg_ip} |${data_vlan} |
    [Tags]    @author=CindyGao
    &{wan_dict_option}    create dictionary    &{EMPTY}
    Run Keyword If    '${EMPTY}'=='${wan_ovlan}'    Set To Dictionary    ${wan_dict_option}    encapsulation=ethernet_ii
    ...    ELSE IF    '${EMPTY}'=='${wan_ivlan}'    Set To Dictionary    ${wan_dict_option}    encapsulation=ethernet_ii_vlan    vlan_id=${wan_ovlan}    vlan_user_pri=${wan_ovlan_pbit}
    ...    ELSE    Set To Dictionary    ${wan_dict_option}    encapsulation=ethernet_ii_qinq    vlan_outer_id=${wan_ovlan}    vlan_outer_user_pri=${wan_ovlan_pbit}    vlan_id=${wan_ivlan}    vlan_user_pri=${wan_ivlan_pbit}
    
    log    ******[${tg} port:${ds_tg_port}] simulate wan device with mac:${wan_mac} ip:${wan_ip} ovlan:${wan_ovlan} ivlan:${wan_ivlan}******
    Tg Stc Create Device On Port     ${tg}    wan_device    ${ds_tg_port}
    ...    mac_addr=${wan_mac}    intf_ip_addr=${wan_ip}    gateway_ip_addr=${wan_ip}
    ...    enable_ping_response=1    resolve_gateway_mac=true    &{wan_dict_option}
    
    log    ******[${tg} port:${ds_tg_port}] create upstream bound traffic:${us_traffic_name} from ${ds_device} to ${us_device}******
    ${us_rate_bps}    evaluate    ${us_rate_mbps}*1000000
    Tg Create Bound Untagged Stream On Port    ${tg}    ${us_traffic_name}    ${ds_tg_port}     ${us_device}    ${ds_device}
    ...    l4_protocol=udp    udp_dst_port=${us_udp_port}    udp_src_port=${ds_udp_port}    mac_discovery_gw=${rg_ip}
    ...    frame_size=${frame_size}    length_mode=fixed    rate_bps=${us_rate_bps}    &{dict_option}
    
    log    ******[${tg} port:${us_tg_port}] create downstream bound traffic:${ds_traffic_name} from ${us_device} to wan_device******
    ${ds_rate_bps}    evaluate    ${ds_rate_mbps}*1000000
    Tg Create Bound Untagged Stream On Port    ${tg}    ${ds_traffic_name}    ${us_tg_port}     wan_device    ${us_device}
    ...    l4_protocol=udp    udp_dst_port=${ds_udp_port}    udp_src_port=${us_udp_port} 
    ...    frame_size=${frame_size}    length_mode=fixed    rate_bps=${ds_rate_bps}    &{dict_option}
    [Return]    wan_device

create_rg_bidirection_raw_traffic
    [Arguments]    ${tg}    ${us_traffic_name}    ${ds_traffic_name}    ${us_tg_port}    ${ds_tg_port}    ${us_rate_mbps}    ${ds_rate_mbps}
    ...    ${up_mac}    ${down_mac}    ${up_ip}    ${down_ip}    ${wan_mac}    ${wan_ip}    ${rg_ip}=192.168.1.1
    ...    ${us_ovlan}=${EMPTY}    ${us_ivlan}=${EMPTY}    ${ovlan_pbit}=0    ${ivlan_pbit}=0
    ...    ${frame_size}=512    ${us_udp_port}=7700    ${ds_udp_port}=8800    &{dict_option}
    [Documentation]    Description: create raw traffic with udp head on traffic generater
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | us_traffic_name | upstream bound traffic name |
    ...    | ds_traffic_name | downstream bound traffic name |
    ...    | us_tg_port | uplink tg port name in topo.yaml |
    ...    | ds_tg_port | host side tg port name in topo.yaml |
    ...    | us_rate_mbps | upstream traffic rate (mbps) |
    ...    | ds_rate_mbps | downstream traffic rate (mbps) |
    ...    | up_mac | uplink side mac |
    ...    | down_mac | host side mac |
    ...    | up_ip | uplink side ip |
    ...    | down_ip | host side ip |
    ...    | wan_mac | ont wan mac |
    ...    | wan_ip | ont wan ip get from dhcp server |
    ...    | rg_ip | ont rg port ip, default=192.168.1.1 |
    ...    | us_ovlan | uplink side outer vlan |
    ...    | us_ivlan | uplink side inner vlan |
    ...    | ovlan_pbit | uplink side outer vlan pbit |
    ...    | ivlan_pbit | uplink side inner vlan pbit |
    ...    | frame_size | traffic size, default=512 |
    ...    | us_udp_port | uplink side udp port, default=7700 |
    ...    | ds_udp_port | host side udp port, default=8800 |
    ...    | dict_option | dictionary type tg paramater, format as param_key=param_value |
    ...
    ...    Example:
    ...    | create_rg_bidirection_raw_traffic | tg1 | us_raw_rg | ds_raw_rg | service_p1 | subscriber_p1 | 10 | 10 |
    ...    | ... | ${server_mac} | ${client_mac} | ${server_ip} | ${client_ip} | ${wan_mac} | ${wan_ip} | ${rg_ip} |${data_vlan} |
    [Tags]    @author=CindyGao
    log    ******[${tg} port:${ds_tg_port}] create upstream raw traffic:${us_traffic_name} mac: ip: ******
    create_raw_traffic_udp    ${tg}    ${us_traffic_name}    ${us_tg_port}    ${ds_tg_port}
    ...    mac_dst=${wan_mac}    mac_src=${down_mac}    ip_dst=${up_ip}    ip_src=${down_ip}    mac_discovery_gw=${rg_ip}
    ...    rate_mbps=${us_rate_mbps}    frame_size=${frame_size}    udp_dst_port=${us_udp_port}    udp_src_port=${ds_udp_port}
    log    ******[${tg} port:${us_tg_port}] create downstream raw traffic:${ds_traffic_name} mac: ip: ******
    create_raw_traffic_udp    ${tg}    ${ds_traffic_name}   ${ds_tg_port}    ${us_tg_port}    ${us_ovlan}    ${us_ivlan}    ${ovlan_pbit}    ${ivlan_pbit}
    ...    mac_dst=${wan_mac}    mac_src=${up_mac}    ip_dst=${wan_ip}    ip_src=${up_ip}    mac_discovery_gw=${wan_ip}
    ...    rate_mbps=${ds_rate_mbps}    frame_size=${frame_size}    udp_dst_port=${ds_udp_port}    udp_src_port=${us_udp_port}

create_igmp_querier
    [Arguments]    ${tg}    ${name}    ${port}    ${version}    ${mac}    ${ip}    ${gateway}
    ...    ${ovlan}=${EMPTY}    ${ivlan}=${EMPTY}    ${ovlan_pbit}=7    ${ivlan_pbit}=7    &{dict_option}
    [Documentation]    Description: create igmp querier on traffic generater
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | name | igmp querier name |
    ...    | port | tg port name in topo.yaml |
    ...    | version | igmp querier version, <v2|v3>|
    ...    | mac | igmp querier mac |
    ...    | ip | igmp querier ip |
    ...    | gateway | gateway ip |
    ...    | ovlan | igmp querier outer vlan |
    ...    | ivlan | igmp querier inner vlan |
    ...    | ovlan_pbit | igmp querier outer vlan pbit |
    ...    | ivlan_pbit | igmp querier inner vlan pbit |
    ...    | dict_option | dictionary type tg paramater, format as param_key=param_value |
    ...
    ...    Example:
    ...    1. create untag igmpv2 querier
    ...    | create_igmp_querier | tg1 | igmp_querier | service_p1 | v2 | ${querier_mac} | ${querier_ip} | ${gateway_ip} | 
    ...    2. create single igmpv2 querier
    ...    | create_igmp_querier | tg1 | igmp_querier | service_p1 | v2 | ${querier_mac} | ${querier_ip} | ${gateway_ip} | 100 |
    ...    3. create double igmpv2 querier
    ...    | create_igmp_querier | tg1 | igmp_querier | service_p1 | v2 | ${querier_mac} | ${querier_ip} | ${gateway_ip} | 100 | 10 | 
    [Tags]    @author=CindyGao
    log    ****** [${tg}:${port}] create igmp querier ${name} with mac:${mac} ip:${ip} ovlan:${ovlan} ivlan:${ivlan} ******
    Run Keyword If    '${EMPTY}'=='${ovlan}'    Set To Dictionary    ${dict_option}    ${EMPTY}
    ...    ELSE IF    '${EMPTY}'=='${ivlan}'    Set To Dictionary    ${dict_option}    vlan_id=${ovlan}    vlan_user_priority=${ovlan_pbit}
    ...    ELSE    Set To Dictionary    ${dict_option}    vlan_id_outer=${ovlan}    vlan_outer_user_priority=${ovlan_pbit}    vlan_id=${ivlan}    vlan_user_priority=${ivlan_pbit}
    
    tg create igmp querier on port    ${tg}    ${name}    ${port}    ${version}    
    ...    intf_ip_addr=${ip}    neighbor_intf_ip_addr=${gateway}    source_mac=${mac}    &{dict_option}
    
create_igmp_host 
    [Arguments]    ${tg}    ${igmp_host}    ${port}    ${version}    ${mac}    ${ip}    ${gateway}
    ...    ${ovlan}=${EMPTY}    ${ivlan}=${EMPTY}    ${ovlan_pbit}=0    ${ivlan_pbit}=0
    ...    ${session}=1    ${mc_group_name}=mcast_group    ${mc_group_start_ip}=224.1.1.1    
    ...    ${add_source}=no    ${source_filter_mode}=INCLUDE    ${source_num}=1    ${source_ip_start}=128.0.1.0    &{dict_option}
    [Documentation]    Description: create igmpv2 host on traffic generater
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | igmp_host | igmp host name |
    ...    | port | tg port name in topo.yaml |
    ...    | version | igmp querier version, <v2|v3>|
    ...    | mac | igmp host mac |
    ...    | ip | igmp host ip |
    ...    | gateway | gateway ip |
    ...    | ovlan | igmp host outer vlan |
    ...    | ivlan | igmp host inner vlan |
    ...    | ovlan_pbit | igmp host outer vlan pbit |
    ...    | ivlan_pbit | igmp host inner vlan pbit |
    ...    | session | session number in one multicast group |
    ...    | mc_group_start_ip | multicast group start ip | 
    ...    | add_source | <yes|no> add source ip for igmpv3 or not |
    ...    | source_filter_mode | <INCLUDE|EXCLUDE> source_filter_mode for igmpv3, set this argument when add_source=yes, default value=INCLUDE |
    ...    | source_num | source ip number for igmpv3, set this argument when add_source=yes |
    ...    | source_ip_start | source ip start for igmpv3, set this argument when add_source=yes |
    ...    | dict_option | dictionary type tg paramater, format as param_key=param_value |
    ...
    ...    Example:
    ...    1. create untag igmpv2 host, multicast group start ip 225.0.0.1, have 5 session in this group
    ...    | create_igmp_host | tg1 | igmp_host1 | subscriber_p1 | v2 | ${host_mac} | ${host_ip} | ${gateway_ip} | session=5 | mc_group_start_ip=225.0.0.1 |
    ...    2. create single igmpv2 host, use default value: multicast group start ip 224.1.1.1, have 1 session in this group
    ...    | create_igmp_host | tg1 | igmp_host1 | subscriber_p1 | v2 | ${host_mac} | ${host_ip} | ${gateway_ip} | 100 |
    ...    3. create double igmpv2 host
    ...    | create_igmp_host | tg1 | igmp_host1 | subscriber_p1 | v2 | ${host_mac} | ${host_ip} | ${gateway_ip} | 100 | 10 | session=5 | mc_group_start_ip=225.0.0.1 |
    ...    4. create igmpv3 host withour source_ip
    ...    |  create_igmp_host | tg1 | igmp_host_v3 | subscriber_p1 | v3 | ${host_mac} | ${host_ip} | ${gateway_ip} | ${host_vlan} | session=3 | mc_group_start_ip=225.0.0.1 |
    ...    5. create igmpv3 host with include source_ip
    ...    |  create_igmp_host | tg1 | igmp_host_v3 | subscriber_p1 | v3 | ${host_mac} | ${host_ip} | ${gateway_ip} | ${host_vlan} | session=3 | mc_group_start_ip=225.0.0.1 | add_source=yes | source_filter_mode=INCLUDE | source_num=3 | source_ip_start=192.0.3.1 |
    ...    6. create igmpv3 host with exclude source_ip
    ...    |  create_igmp_host | tg1 | igmp_host_v3 | subscriber_p1 | v3 | ${host_mac} | ${host_ip} | ${gateway_ip} | ${host_vlan} | session=3 | mc_group_start_ip=225.0.0.1 | add_source=yes | source_filter_mode=EXCLUDE | source_num=3 | source_ip_start=192.1.1.1 |
    ...    7. Get return value
    ...    | &{dict_name} |  create_igmp_host | ......parameter...... |
    ...    Use &{dict_prf}[mc_grp] to get mcast group name; &{dict_prf}[igmp_grp] to get igmp group name; &{dict_prf}[src_pool] to get source pool name
    [Tags]    @author=CindyGao
    log    ******[${tg}:${port}] create igmp host ${igmp_host} with mac:${mac} ip:${ip} ovlan:${ovlan} ivlan:${ivlan}******
    Run Keyword If    '${EMPTY}'=='${ovlan}'    Set To Dictionary    ${dict_option}    &{EMPTY}
    ...    ELSE IF    '${EMPTY}'=='${ivlan}'    Set To Dictionary    ${dict_option}    vlan_id=${ovlan}    vlan_user_priority=${ovlan_pbit}
    ...    ELSE    Set To Dictionary    ${dict_option}    vlan_id_outer=${ovlan}    vlan_outer_user_priority=${ovlan_pbit}    vlan_id=${ivlan}    vlan_user_priority=${ivlan_pbit}
    tg create igmp on port    ${tg}    ${igmp_host}    ${port}    ${version}
    ...    intf_ip_addr=${ip}    neighbor_intf_ip_addr=${gateway}    source_mac=${mac}    &{dict_option}

    # ${mc_group}    set variable    mcast_group
    ${igmp_grp_name}    set variable    igmp_group
    ${src_pool_name}    set variable    source_pool
    &{dict_name}    create dictionary    mc_grp=${mc_group_name}    igmp_grp=${igmp_grp_name}    src_pool=${src_pool_name}
    log    ******[${tg}] create multicast group with start_ip:${mc_group_start_ip} session:${session}******
    tg create multicast group    ${tg}    ${mc_group_name}    num_groups=${session}    ip_addr_start=${mc_group_start_ip}    ip_prefix_len=32
    
    log    ******[${tg}] create igmp group with add_source:${add_source}******
    Run Keyword If    "no"=="${add_source}"    tg create igmp group    ${tg}    ${igmp_grp_name}    ${igmp_host}    ${mc_group_name}
    ...    filter_mode=EXCLUDE    enable_user_defined_sources=0    specify_sources_as_list=0
    Return From Keyword If    "no"=="${add_source}"    &{dict_name}
    
    log    ******[${tg}] create igmp group with source ip start:${source_ip_start}******
    # ${source_pool_name}    set variable    source_pool
    tg create multicast source    ${tg}    ${src_pool_name}    num_sources=${source_num}    ip_addr_start=${source_ip_start}    ip_prefix_len=32
    ${source_pool_list}    create list    ${src_pool_name}
    tg create igmp group    ${tg}    ${igmp_grp_name}    ${igmp_host}    ${mc_group_name}    ${source_pool_list}
    ...    filter_mode=${source_filter_mode}    enable_user_defined_sources=1    specify_sources_as_list=0
    [Return]    &{dict_name}

add_one_multicast_group_to_igmp_host
    [Arguments]    ${tg}    ${igmp_host}    ${mc_grp_name}    ${start_ip}    ${session}=1
    [Documentation]    Description: add one igmp group to igmp host on traffic generater, must use create_igmp_host to create host first
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | igmp_host | igmpv2 host name |
    ...    | mc_grp_name | multicast group name |
    ...    | start_ip | multicast group start ip |
    ...    | session | session number in one multicast group |
    ...
    ...    Example:
    ...    | add_one_multicast_group_to_igmp_host | tg1 | igmp_host1 | mc_grp1 | 224.1.0.1 | 5 | 
    [Tags]    @author=CindyGao
    log    ******[${tg}] igmp host ${igmp_host} add multicast group ${mc_grp_name} with start_ip:${start_ip} session:${session}******
    tg create multicast group    ${tg}    ${mc_grp_name}    num_groups=${session}    ip_addr_start=${start_ip}    ip_prefix_len=32
    tg create igmp group    ${tg}    igmp_grp_${mc_grp_name}    ${igmp_host}    ${mc_grp_name}    filter_mode=EXCLUDE    enable_user_defined_sources=0    specify_sources_as_list=0

add_multicast_group_to_igmp_host
    [Arguments]    ${tg}    ${igmp_host}    ${group_num}    ${session}    ${list_mc_group_start_ip}    ${mc_grp_prefix}=mcast_group
    [Documentation]    Description: batch add igmp group to igmp host on traffic generater, must use create_igmp_host to create host first
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | igmp_host | igmpv2 host name |
    ...    | group_num | multicast group number |
    ...    | session | session number in one multicast group |
    ...    | list_mc_group_start_ip | list format multicast group start ip, each multicast group need one start ip |
    ...
    ...    Example:
    ...    1. add 4 multicast group(each group has 5 session) with start ip 224.1.0.1, 224.1.1.1, 224.1.2.1, 224.1.3.1 in each group
    ...    | add_multicast_group_to_igmp_host | tg1 | igmp_host1 | 4 | 5 | 224.1.0.1 | 224.1.1.1 | 224.1.2.1 | 224.1.3.1 | 
    [Tags]    @author=CindyGao
    log    ******[${tg}] add ${group_num} multicast group to igmp host ${igmp_host}******
    ${list_mc_grp_name}    create list    @{EMPTY}
    : FOR    ${index}    IN RANGE    0    ${group_num}
    \    log    ******[${tg}] create multicast group ${mc_grp_prefix}_${index} with start_ip:@{list_mc_group_start_ip}[${index}] session:${session}******
    \    tg create multicast group    ${tg}    ${mc_grp_prefix}_${index}    num_groups=${session}    ip_addr_start=@{list_mc_group_start_ip}[${index}]    ip_prefix_len=32
    \    Append To List    ${list_mc_grp_name}    ${mc_grp_prefix}_${index}
    
    log    ******[${tg}] create igmp group without source******
    : FOR    ${index}    IN RANGE    0    ${group_num}
    \    tg create igmp group    ${tg}    igmp_grp_${index}    ${igmp_host}    ${mc_grp_prefix}_${index}
    \    ...    filter_mode=EXCLUDE    enable_user_defined_sources=0    specify_sources_as_list=0
    [Return]    ${list_mc_grp_name}

verify_traffic_stream_all_pkt_loss
    [Arguments]    ${tg}    ${stream_name}
    [Documentation]    Description: verify all packet loss for stream
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | stream_name | stream name |
    ...
    ...    Example:
    ...    | verify_traffic_stream_all_pkt_loss | tg1 | us_traffic |
    [Tags]    @author=CindyGao
    ${res}    Tg Get Traffic Stats By Key On Stream    ${tg}    ${stream_name}    rx.total_pkts
    @{rx_pkts}    Get Dictionary Values    ${res}
    
    ${res}    Tg Get Traffic Stats By Key On Stream    ${tg}    ${stream_name}    tx.total_pkts
    @{tx_pkts}    Get Dictionary Values    ${res}
    
    log    ******[${tg}]traffic stream ${stream_name}:rx_pkt:@{rx_pkts}[0], tx_pkt:@{tx_pkts}[0]******
    should be true    (@{rx_pkts}[0]==0) and (@{tx_pkts}[0]>0)

verify_traffic_stream_rx_pkt
    [Arguments]    ${tg}    ${stream_name}    ${expect_pkt}
    [Documentation]    Description: verify rx packet loss for stream is ${expect_pkt}
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | stream_name | stream name |
    ...    | expect_pkt | expect packet number |
    ...
    ...    Example:
    ...    | verify_traffic_stream_rx_pkt | tg1 | us_traffic | 0 |
    [Tags]    @author=CindyGao
    ${res}    Tg Get Traffic Stats By Key On Stream    ${tg}    ${stream_name}    rx.total_pkts
    @{rx_pkts}    Get Dictionary Values    ${res}
    log    ******[${tg}]traffic stream ${stream_name}:rx_pkt:@{rx_pkts}[0], expect pkt:${expect_pkt}******
    should be true    @{rx_pkts}[0]==${expect_pkt}

verify_traffic_stream_drop_pkt
    [Arguments]    ${tg}    ${stream_name}    ${expect_pkt}
    [Documentation]    Description: verify rx.drop packet loss for stream is ${expect_pkt}
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | stream_name | stream name |
    ...    | expect_pkt | expect packet number |
    ...
    ...    Example:
    ...    | verify_traffic_stream_drop_pkt | tg1 | us_traffic | 0 |
    [Tags]    @author=CindyGao
    ${res}    Tg Get Traffic Stats By Key On Stream    ${tg}    ${stream_name}    rx.dropped_pkts
    @{drop_pkts}    Get Dictionary Values    ${res}
    log    ******[${tg}]traffic stream ${stream_name}:drop_pkt:@{drop_pkts}[0], expect pkt:${expect_pkt}******
    should be true    @{drop_pkts}[0]==${expect_pkt}

get_traffic_stream_stats
    [Arguments]    ${tg}    ${stream_name}    ${direction}    ${item}
    [Documentation]    Description: get traffic stream stats
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | stream_name | stream name |
    ...    | direction | {rx|tx} | 
    ...    | item | item to get stats, should be the same as tg printing stats item |
    ...
    ...    Example:
    ...    | ${tx_total} | get_traffic_stream_stats | tg1 | us_traffic1 | tx | total_pkts |
    ...    | ${rx_drop} | get_traffic_stream_stats | tg1 | us_traffic1 | rx | dropped_pkts |
    [Tags]    @author=CindyGao
    ${res}    Tg Get Traffic Stats By Key On Stream    ${tg}    ${stream_name}    ${direction}.${item}
    @{query_stats}    Get Dictionary Values    ${res}
    log    ******[${tg}]traffic stream ${stream_name} ${direction}.${item}=@{query_stats}[0]******
    [Return]    @{query_stats}[0]

############################################# packet analyze keyword ################################################
start_capture
    [Arguments]    ${tg}    ${port}
    [Documentation]    Description:start capture before start traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | port | tg port |
    ...
    ...    Example:
    ...    | start_capture | tg1 | p1 |
    [Tags]    @author=AnneLi
    Tg Config Packet Buffers    ${tg}    ${port}    stop
    Tg Packet Control    ${tg}    ${port}    start
    log    wait 1s after start_capture
    sleep    1

stop_capture
    [Arguments]    ${tg}    ${port}
    [Documentation]    Description:stop capure after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | port | tg port |
    ...
    ...    Example:
    ...    | stop_capture | tg1 | p1 |
    [Tags]    @author=AnneLi
    Tg Packet Control    ${tg}    ${port}    stop
    log    wait 1s after stop_capture
    sleep    1

get_packet_counter_on_port_with_filter
    [Arguments]    ${tg}    ${rx_port}    ${filter}=${EMPTY}     ${filename}=/tmp/${TEST NAME}.pcap
    [Documentation]    Description:get rx counter on stc port with filter. if use this keyword ,must use keyword "start_capture"  before start
    ...    traffic and "stop_capture" after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | rx_port | tg port |
    ...    | filter | wireshark filter |
    ...
    ...    Example:
    ...    | get_packet_counter_on_port_with_filter | tg1 | p1 | eth.src==00:00:01:00:00:01 and eth.dst==00:00:02:00:00:02 |
    ...    | get_packet_counter_on_port_with_filter | tg1 | p1 | ip.src==10.10.10.1 and eth.dst==10.10.10.2 |
    ...    | get_packet_counter_on_port_with_filter | tg1 | p1 | vlan.id == 800 |
    [Tags]    @author=AnneLi
    Tg Store Captured Packets    ${tg}    ${rx_port}    ${filename}
    Wsk Load File    ${filename}    ${filter}
    ${cnt}    wsk_get_total_packet_count
    [Return]    ${cnt}

verify_traffic_loss_within_with_filter
    [Arguments]    ${tg}    ${traffic_name}    ${rx_port}    ${filter}    ${error_rate}
    [Documentation]     Description:verify traffic loss rate less than one value . if use this keyword ,must use keyword "start_capture"  before start
    ...    traffic and "stop_capture" after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | traffic_name | traffic name |
    ...    | rx_port | tg port |
    ...    | filter | wireshark filter |
    ...
    ...    Example:
    ...    | verify_traffic_loss_within_with_filter | tg1 | stream1 | p1 | eth.src==00:00:01:00:00:01 and eth.dst==00:00:02:00:00:02 | 0.001 |
    ...    | verify_traffic_loss_within_with_filter | tg1 | stream1 | p1 | ip.src==10.10.10.1 and eth.dst==10.10.10.2 | 0.001 |
    ...    | verify_traffic_loss_within_with_filter | tg1 | stream1 | p1 | vlan.id == 800 | 0.001 |
    [Tags]    @author=AnneLi
    ${rx_counter}    get_packet_counter_on_port_with_filter    ${tg}    ${rx_port}    ${filter}
    log    ${rx_port} rx is ${rx_counter}, filter:[${filter}]
    ${res}    Tg Get Traffic Stats By Key On Stream    tg1    ${traffic_name}    tx.total_pkts
    @{tx_pkts}    Get Dictionary Values    ${res}
    ${tx_counter}    Set Variable    @{tx_pkts}[0]
    log    ${traffic_name} tx is ${tx_counter}
    should be true     abs(float(${tx_counter})-float(${rx_counter}))/${tx_counter} <= ${error_rate}

verify_no_traffic_on_port_with_filter
    [Arguments]    ${tg}    ${rx_port}    ${filter}
    [Documentation]     Description:verify no receive traffic by filter . if use this keyword ,must use keyword "start_capture"  before start
    ...    traffic and "stop_capture" after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | rx_port | tg port |
    ...    | filter | wireshark filter |
    ...    Example:
    ...    | verify_no_traffic_on_port_with_filter | tg1 | p1 | eth.src==00:00:01:00:00:01 and eth.dst==00:00:02:00:00:02 |
    ...    | verify_no_traffic_on_port_with_filter | tg1 | p1 | ip.src==10.10.10.1 and eth.dst==10.10.10.2 |
    ...    | verify_no_traffic_on_port_with_filter | tg1 | p1 | vlan.id == 800 |
    [Tags]    @author=AnneLi
    ${rx_counter}    get_packet_counter_on_port_with_filter    ${tg}    ${rx_port}    ${filter}
    log    ${rx_port} rx is ${rx_counter}, filter:[${filter}]
    Should Be Equal As Integers    ${rx_counter}    0

save_and_analyze_packet_on_port
    [Arguments]    ${tg}    ${rx_port}    ${filter}    ${file_path}=/tmp/${TEST NAME}.pcap
    [Documentation]    Description:analyze packet  field information  by filter. if use this keyword ,must use keyword "start_capture"  before start
    ...    traffic and "stop_capture" after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | rx_port | tg port |
    ...    | filter | wireshark filter |
    ...    | save_file | tg store file path and name, if not input will use: /tmp/${TEST NAME}.pcap |
    ...
    ...    Example:
    ...    | analyze_packet_on_port | tg1 | p1 | eth.src==00:00:01:00:00:01 and eth.dst==00:00:02:00:00:02 |
    ...    | analyze_packet_on_port | tg1 | p1 | ip.src==10.10.10.1 and eth.dst==10.10.10.2 |
    ...    | analyze_packet_on_port | tg1 | p1 | bootp.type == 2 |
    [Tags]    @author=AnneLi
    # ${file_path}    set variable if    '${EMPTY}'=='${save_file}'    /tmp/stcbigdata.pcap    ${save_file}
    Tg Store Captured Packets    ${tg}    ${rx_port}    ${file_path}
    log    save captured packets to ${file_path}
    sleep    5s
    log     ********packet:[${file_path}] filter:[${filter}]***************
    Wsk Load File    ${file_path}    ${filter}
    ${cnt}    wsk_get_total_packet_count
    log    get packet is ${cnt}
    Should Be True    ${cnt}>0
    [Return]    ${cnt}

analyze_packet_count_greater_than
    [Arguments]    ${save_file}    ${filter}    ${value}=0
    [Documentation]    Description: analyze filter packet count >${value}
    ...    If use this keyword ,must use keyword "start_capture" before start traffic and "stop_capture" after stop traffic,
    ...    and save packet by use "Tg Store Captured Packets" to save packet.
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | save_file | tg store file path and name |
    ...    | filter | wireshark filter |
    ...    | value | expect packet number greater than this value |
    ...
    ...    Example:
    ...    | analyze_packet_count_greater_than | tg1 | eth.src==00:00:01:00:00:01 and eth.dst==00:00:02:00:00:02 | ${file_name} |
    ...    | analyze_packet_count_greater_than | tg1 | ip.src==10.10.10.1 and eth.dst==10.10.10.2 | ${file_name} |
    ...    | analyze_packet_count_greater_than | tg1 | bootp.type == 2 | ${file_name} | 10 |
    [Tags]    @author=CindyGao
    log     ********packet:[${save_file}] filter:[${filter}]***************
    Wsk Load File    ${save_file}    ${filter}
    ${cnt}    wsk_get_total_packet_count
    log    get packet is ${cnt}, expect more than ${value}
    Should Be True    ${cnt}>${value}
    [Return]    ${cnt}

analyze_packet_count_equal
    [Arguments]    ${save_file}    ${filter}    ${value}=0
    [Documentation]    Description: analyze filter packet count ==${value}
    ...    If use this keyword ,must use keyword "start_capture" before start traffic and "stop_capture" after stop traffic,
    ...    and save packet by use "Tg Store Captured Packets" to save packet.
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | save_file | tg store file path and name |
    ...    | filter | wireshark filter |
    ...    | value | expect packet number equal this value |
    ...
    ...    Example:
    ...    | analyze_packet_count_equal | tg1 | eth.src==00:00:01:00:00:01 and eth.dst==00:00:02:00:00:02 | ${file_name} |
    ...    | analyze_packet_count_equal | tg1 | ip.src==10.10.10.1 and eth.dst==10.10.10.2 | ${file_name} |
    ...    | analyze_packet_count_equal | tg1 | bootp.type == 2 | ${file_name} | 10 |
    [Tags]    @author=CindyGao
    Wsk Load File    ${save_file}    ${filter}
    ${cnt}    wsk_get_total_packet_count
    Should Be True    ${cnt}==${value}
    [Return]    ${cnt}