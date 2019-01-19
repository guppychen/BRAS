*** Settings ***
Documentation    test_suite keyword lib
Resource         ../base.robot

*** Variable ***
${igmpv2_type_query}    0x11
${igmpv2_type_report}    0x16
${igmpv2_type_leave}    0x17
${igmpv2_gen_query_dst_ip}    224.0.0.1
${igmpv3_report_dst_ip}    224.0.0.22
${ip_protocol_udp}    17


*** Keywords ***
delete_tg_igmp_session
    [Arguments]    ${tg}    ${igmp_querier}    ${igmp_host}
    tg control igmp    ${tg}    ${igmp_host}    leave
    # : FOR    ${index}    IN RANGE    1    ${range}
    # \    tg delete igmp group    ${tg}    igmp_group_${index}
    # tg delete multicast source    ${tg}    source_pool
    # : FOR    ${index}    IN RANGE    1    ${range}
    # \    tg delete multicast group    ${tg}    group_${index}
    tg delete igmp    ${tg}    ${igmp_host}
    
    tg control igmp querier by name    ${tg}    ${igmp_querier}    stop
    tg delete igmp querier    ${tg}    ${igmp_querier}
    
delete_tg_dhcp_session
    [Arguments]    ${tg}    ${dhcps}    ${dhcpc}    ${dhcpc_group}
    Tg Control Dhcp Client    ${tg}    ${dhcpc_group}    stop 
    Tg Delete Dhcp Client Group    ${tg}    ${dhcpc_group}
    # Tg Delete Dhcp Client    ${tg}    ${dhcpc} 
    
    Tg Control Dhcp Server    ${tg}    ${dhcps}    stop 
    Tg Delete Dhcp Server    ${tg}    ${dhcps}
