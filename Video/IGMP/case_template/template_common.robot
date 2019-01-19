*** Settings ***
Documentation    test_suite keyword lib
Resource          ../base.robot

*** Variable ***
${video_vlan}    @{p_video_vlan_list}[0]
${ip_not_zero}    [1-9]\\d*(\\.\\d+){3}

*** Keywords ***
send_traffic_and_check_loss
    [Arguments]    ${tg}    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_service_point_list}=${EMPTY}
    [Documentation]    Description: send traffic and check no packet loss with show interface count
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | uplink_eth_service_point_list | uplink eth port service_point_list name in service_model.yaml |
    ...    | ring_service_point_list | ring service_point_list name in service_model.yaml |
    [Tags]    @author=CindyGao
    # Tg Start Arp Nd On All Devices 	  ${tg}
    # Tg Start Arp Nd On All Stream Blocks 	  ${tg}
    TG Clear Traffic Stats    tg1
    
    log    clear interface counter before send traffic
    service_point_list_interface_counter_stats    ${uplink_eth_service_point_list}    clear
    Run Keyword If    "${ring_service_point_list}"!="${EMPTY}"    service_point_list_interface_counter_stats    ${ring_service_point_list}    clear
    test_point_interface_counter_stats    ${subscriber_point}    clear
    
    Tg Start All Traffic    tg1
    log    add for packet loss debug:show igmp table during send traffic
    ${uplink_eth_point}    set variable    @{service_model.${uplink_eth_service_point_list}}[0]
    ${traffic_sleep_step}    set variable    2
    : FOR    ${index}    IN RANGE    0    ${p_traffic_run_time}    ${traffic_sleep_step}
    \    sleep    ${traffic_sleep_step}
    \    cli    ${service_model.${subscriber_point}.device}    show igmp multicast group summary
    \    cli    ${service_model.${uplink_eth_point}.device}    show igmp multicast group summary
    
    Tg Stop All Traffic    tg1
    log    sleep for traffic stop
    sleep    ${p_traffic_stop_time}
    
    log    show interface counter after send traffic
    service_point_list_interface_counter_stats    ${uplink_eth_service_point_list}    show
    Run Keyword If    "${ring_service_point_list}"!="${EMPTY}"    service_point_list_interface_counter_stats    ${ring_service_point_list}    show
    test_point_interface_counter_stats    ${subscriber_point}    show
    
    Tg Verify Traffic Loss Rate For All Streams Is Within    tg1    ${p_traffic_loss_rate}

send_traffic_stream_and_check_loss
    [Arguments]    ${tg}    ${traffic_name}
    [Documentation]    Description: send traffic and check no packet loss for one stream
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | traffic_name | traffic name |
    [Tags]    @author=CindyGao
    log    send traffic stream: ${traffic_name}
    Tg Control Traffic    ${tg}    ${traffic_name}    run
    log    sleep for traffic run
    sleep    2s
    Tg Control Traffic    ${tg}    ${traffic_name}    stop
    TG Clear Traffic Stats    tg1
    
    Tg Control Traffic    ${tg}    ${traffic_name}    run
    log    sleep for traffic run
    sleep    ${p_traffic_run_time}
    Tg Control Traffic    ${tg}    ${traffic_name}    stop
    log    sleep for traffic stop
    sleep    ${p_traffic_stop_time}
    log    verify no drop packet
    # Tg Verify No Traffic Loss For Stream    ${tg}    ${traffic_name}
    wait until keyword succeeds    2min    10s    verify_traffic_stream_drop_pkt    ${tg}    ${traffic_name}    0
    wait until keyword succeeds    2min    10s    Tg Verify Traffic Loss For Stream Is Within    ${tg}    ${traffic_name}    ${p_traffic_loss_rate} 
    
service_point_list_interface_counter_stats
    [Arguments]    ${service_point_list}    ${action}
    [Documentation]    Description: 
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | action | <clear|show> |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_list_interface_counter_stats | service_point_list1 |
    [Tags]    @author=CindyGao
    : FOR    ${service_point}    IN    @{service_model.${service_point_list}}
    \    log    ******${action} interface counter for ${service_point}******
    \    Run Keyword    test_point_interface_counter_stats    ${service_point}    ${action}
 
test_point_interface_counter_stats
    [Arguments]    ${test_point}    ${action}
    [Documentation]    Description: add transport_profile to service_point interface (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | action | <clear|show> |
    ...    | test_point | service_point or subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | test_point_interface_counter_stats | eutA | service_point1 | show |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${test_point}.device}
    : FOR    ${port_key}    IN    @{service_model.${test_point}.member}
    \    ${port}    set variable    ${service_model.${test_point}.member.${port_key}}
    \    cli    ${device}    ${action} interface ${service_model.${test_point}.attribute.interface_type} ${port} counter
    \    Run Keyword If    "ont_port"=="${service_model.${test_point}.type}"
    \    ...    cli    ${device}    ${action} interface pon @{service_model.${test_point}.attribute.pon_port}[0] counter
    
############################################# non-mvr keyword #############################################
check_igmp_querier_non_mvr
    [Arguments]    ${service_point_list}    ${version}
    [Documentation]    Description: non-mvr video check igmp querier on other ring device, if ring node is the same with uplink node, check on uplink eth
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | version | igmp version, {v2|v3} |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    [Tags]       @author=CindyGao
    log    check igmp querier on other ring device
    ${index}    set variable    0
    : FOR    ${node}    IN    @{service_model.${service_point_list}}
    \    ${querier_node}    Set Variable If    '${service_model.${node}.device}'=='${service_model.${uplink_eth_point}.device}'    ${uplink_eth_point}    ${node}
    \    ${querier_ip}    Set Variable If    '${service_model.${node}.device}'=='${service_model.${uplink_eth_point}.device}'    ${p_igmp_querier.ip}    ${ip_not_zero}
    \    service_point_check_igmp_routers    ${querier_node}    ${video_vlan}    @{p_proxy.ip}[${index}]    ${querier_ip}    ${version}
    \    ${index}    evaluate    ${index}+1

check_non_mvr_igmp_multicast_group_on_ring_node
    [Arguments]    ${ring_type}    ${ring_service_point_list}
    [Documentation]    Description: non-mvr video check igmp multicast group on ring node with igmp router
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | ring_type | ring_type, {erps|g.8032} |
    ...    | ring_service_point_list | ring service_point_list name in service_model.yaml |
    [Tags]       @author=CindyGao
    log    check igmp multicast group on ring node with igmp router
    : FOR    ${ring_node}    IN    @{service_model.${ring_service_point_list}}
    \    ${ring_eut}    set variable    ${service_model.${ring_node}.device}
    \    Continue For Loop If    '${ring_eut}'!='${service_model.${uplink_eth_point}.device}'
    \    check_igmp_multicast_group_summary    ${ring_eut}    @{p_mvr_start_ip_list}[0]    ${video_vlan}    ${ring_type}-${service_model.${ring_node}.name}

non_mvr_template_teardown
    [Arguments]    ${subscriber_point}
    [Documentation]    template teardown for template_non_mvr_video and template_ring_switch_non_mvr_video
    [Tags]       @author=CindyGao
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    ${subscriber_point}    ${p_match_vlan}    ${video_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    ${subscriber_eut}    multicast-profile    ${p_mcast_prf}

    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    
############### these are keyword for ring case setup and teardown when using this template ###############
igmp_over_ring_non_mvr_provision
    [Arguments]    ${ring_service_point_list}
    [Documentation]    case provision for non-mvr IGMP over Rings
    [Tags]       @author=CindyGao
    log    suite provision service_point_provision for ring
    service_point_prov    ${ring_service_point_list}

    log    add vlan and igmp service on ring
    ${max_arr_index}    evaluate    ${p_max_mvr_vlan_num}-1
    service_point_add_vlan    ${ring_service_point_list}    ${video_vlan}
    service_point_prov_igmp    ${ring_service_point_list}    ${p_igmp_prf}    ${p_proxy.intf_name}    ${p_proxy.ip}    ${p_proxy.mask}    ${p_proxy.gw}    ${video_vlan}

igmp_over_ring_non_mvr_deprovision
    [Arguments]    ${ring_service_point_list}
    [Documentation]    case deprovision for non-mvr IGMP over Rings
    [Tags]       @author=CindyGao
    log    ring deprovision
    service_point_dprov_igmp    ${ring_service_point_list}    ${p_igmp_prf}    ${p_proxy.intf_name}    ${video_vlan}
    ${max_arr_index}    evaluate    ${p_max_mvr_vlan_num}-1
    service_point_remove_vlan    ${ring_service_point_list}    ${video_vlan}
    
    log    service_point remove_svc deprovision
    service_point_dprov    ${ring_service_point_list}

############################################# mvr keyword #############################################
check_igmp_querier_mvr
    [Arguments]    ${service_point_list}    ${version}
    [Documentation]    Description: mvr video check igmp querier on other ring device, if ring node is the same with uplink node, check on uplink eth
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | version | igmp version, {v2|v3} |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    [Tags]       @author=CindyGao
    log    check igmp querier on other ring device
    ${index}    set variable    0
    : FOR    ${node}    IN    @{service_model.${service_point_list}}
    \    ${querier_node}    Set Variable If    '${service_model.${node}.device}'=='${service_model.${uplink_eth_point}.device}'    ${uplink_eth_point}    ${node}
    \    ${querier_ip}    Set Variable If    '${service_model.${node}.device}'=='${service_model.${uplink_eth_point}.device}'    ${p_igmp_querier.ip}    ${ip_not_zero}
    \    service_point_check_igmp_routers    ${querier_node}    @{p_video_vlan_list}[0]    @{p_proxy.ip}[${index}]    ${querier_ip}    ${version}
    \    service_point_check_igmp_routers    ${querier_node}    @{p_video_vlan_list}[1]    @{p_proxy.ip}[${index}]    ${querier_ip}    ${version}
    \    service_point_check_igmp_routers    ${querier_node}    @{p_video_vlan_list}[2]    @{p_proxy.ip}[${index}]    ${querier_ip}    ${version}
    \    service_point_check_igmp_routers    ${querier_node}    @{p_video_vlan_list}[3]    @{p_proxy.ip}[${index}]    ${querier_ip}    ${version}
    \    ${index}    evaluate    ${index}+1

check_igmp_multicast_group_on_ring_node
    [Arguments]    ${ring_type}    ${ring_service_point_list}    ${contain}=yes
    [Documentation]    Description: mvr video check igmp multicast group on ring node with igmp router
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | ring_type | ring_type, {erps|g.8032} |
    ...    | ring_service_point_list | ring service_point_list name in service_model.yaml |
    ...    | contain | should contain igmp multicast group or not, {yes|no} |
    [Tags]       @author=CindyGao
    log    check igmp multicast group on ring node with igmp router
    ${keyword}    set variable if    'yes'=='${contain}'    check_igmp_multicast_group_summary    check_igmp_multicast_group_not_contain
    : FOR    ${ring_node}    IN    @{service_model.${ring_service_point_list}}
    \    ${ring_eut}    set variable    ${service_model.${ring_node}.device}
    \    Continue For Loop If    '${ring_eut}'!='${service_model.${uplink_eth_point}.device}'
    \    run keyword    ${keyword}    ${ring_eut}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]    ${ring_type}-${service_model.${ring_node}.name}
    \    run keyword    ${keyword}    ${ring_eut}    @{p_mvr_start_ip_list}[1]    @{p_video_vlan_list}[1]    ${ring_type}-${service_model.${ring_node}.name}
    \    run keyword    ${keyword}    ${ring_eut}    @{p_mvr_start_ip_list}[2]    @{p_video_vlan_list}[2]    ${ring_type}-${service_model.${ring_node}.name}
    \    run keyword    ${keyword}    ${ring_eut}    @{p_mvr_start_ip_list}[3]    @{p_video_vlan_list}[3]    ${ring_type}-${service_model.${ring_node}.name}

mvr_template_teardown
    [Arguments]    ${subscriber_point}
    [Documentation]    template teardown for template_mvr_video and template_ring_switch_mvr_video
    [Tags]       @author=CindyGao
    log    case teardown: subscriber side deprovision
    Tg Save Config Into File    tg1     /tmp/${TEST_NAME}.xml
    log   save ${TEST_NAME}.xml file done

    subscriber_point_remove_svc    ${subscriber_point}    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    ${subscriber_eut}    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    ${subscriber_eut}    mvr-profile    ${p_mvr_prf}

    log    delete tg session
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    tg control igmp querier by name    tg1    igmp_querier${index}    stop
    \    tg delete igmp querier    tg1    igmp_querier${index}
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    
    delete_tg_dhcp_session    tg1    dhcps    dhcpc    dhcpc_group
    
############### these are keyword for ring case setup and teardown when using this template ###############
igmp_over_ring_mvr_provision
    [Arguments]    ${ring_service_point_list}
    [Documentation]    case provision for mvr IGMP over Rings
    [Tags]       @author=CindyGao
    log    suite provision service_point_provision for ring
    service_point_prov    ${ring_service_point_list}

    log    add vlan and igmp service on ring
    ${max_arr_index}    evaluate    ${p_max_mvr_vlan_num}-1
    service_point_add_vlan    ${ring_service_point_list}    ${p_data_vlan},@{p_video_vlan_list}[0]-@{p_video_vlan_list}[${max_arr_index}]
    service_point_prov_igmp    ${ring_service_point_list}    ${p_igmp_prf}    ${p_proxy.intf_name}    ${p_proxy.ip}    ${p_proxy.mask}    ${p_proxy.gw}    @{p_video_vlan_list}  
    
igmp_over_ring_mvr_deprovision
    [Arguments]    ${ring_service_point_list}
    [Documentation]    case deprovision for mvr IGMP over Rings
    [Tags]       @author=CindyGao
    log    ring deprovision
    service_point_dprov_igmp    ${ring_service_point_list}    ${p_igmp_prf}    ${p_proxy.intf_name}    @{p_video_vlan_list}
    ${max_arr_index}    evaluate    ${p_max_mvr_vlan_num}-1
    service_point_remove_vlan    ${ring_service_point_list}    ${p_data_vlan},@{p_video_vlan_list}[0]-@{p_video_vlan_list}[${max_arr_index}]
    
    log    service_point remove_svc deprovision
    service_point_dprov    ${ring_service_point_list}  
    
    
 