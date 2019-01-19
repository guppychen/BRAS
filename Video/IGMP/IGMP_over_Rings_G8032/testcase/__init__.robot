*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       igmp_over_g8032_suite_provision
Suite Teardown    igmp_over_g8032_suite_deprovision
Force Tags        @feature=IGMP    @subfeature=IGMP over Rings (G.8032)    @author=CindyGao
Resource          ./base.robot

*** Variables ***
${uplink_eth_service_point_list}    service_point_list2
${ring_list}    service_point_list1

*** Keywords ***
igmp_over_g8032_suite_provision
    [Documentation]    suite provision for IGMP over Rings (G.8032)
    [Tags]       @author=CindyGao
    log    suite provision service_point_provision for uplink side
    service_point_prov    ${uplink_eth_service_point_list}
    
    log    create vlan
    :FOR    ${ring_node}    IN    @{service_model.${ring_list}}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${ring_node}.device}    ${p_data_vlan}
    \    prov_vlan_egress    ${service_model.${ring_node}.device}    ${p_data_vlan}    broadcast-flooding	ENABLED
    \    prov_vlan    ${service_model.${ring_node}.device}    @{p_video_vlan_list}[0]
    \    prov_vlan    ${service_model.${ring_node}.device}    @{p_video_vlan_list}[1]
    \    prov_vlan    ${service_model.${ring_node}.device}    @{p_video_vlan_list}[2]
    \    prov_vlan    ${service_model.${ring_node}.device}    @{p_video_vlan_list}[3]

    log    add vlan and igmp service
    ${max_arr_index}    evaluate    ${p_max_mvr_vlan_num}-1
    service_point_add_vlan    ${uplink_eth_service_point_list}    ${p_data_vlan},@{p_video_vlan_list}[0]-@{p_video_vlan_list}[${max_arr_index}]
    
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1

igmp_over_g8032_suite_deprovision
    [Documentation]    suite deprovision for IGMP over Rings (G.8032)
    [Tags]       @author=CindyGao
    log    suite deprovision subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1   
    
    log    uplink side deprovision
    ${max_arr_index}    evaluate    ${p_max_mvr_vlan_num}-1
    service_point_remove_vlan    ${uplink_eth_service_point_list}    ${p_data_vlan},@{p_video_vlan_list}[0]-@{p_video_vlan_list}[${max_arr_index}]   
    
    log    service_point remove_svc deprovision
    service_point_dprov    ${uplink_eth_service_point_list}
    
    log    delete vlan
    :FOR    ${ring_node}    IN    @{service_model.${ring_list}}
    \    log    delete service vlan
    \    delete_config_object    ${service_model.${ring_node}.device}    vlan    ${p_data_vlan}
    \    delete_config_object    ${service_model.${ring_node}.device}    vlan    @{p_video_vlan_list}[0]
    \    delete_config_object    ${service_model.${ring_node}.device}    vlan    @{p_video_vlan_list}[1]
    \    delete_config_object    ${service_model.${ring_node}.device}    vlan    @{p_video_vlan_list}[2]
    \    delete_config_object    ${service_model.${ring_node}.device}    vlan    @{p_video_vlan_list}[3]


