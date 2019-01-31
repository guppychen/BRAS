*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=Ethernet Class Map      @author=MinGu

*** Variables ***
&{tg_us_param}    ovlan=0    ovlan_pbit=2    mac_dst=${tg_server.mac}    mac_src=${tg_client.mac}    ip_dst=${tg_server.ip}    ip_src=${tg_client.ip}    rate_mbps=${pkt_rate}
&{tg_ds_param}    ovlan=${service_vlan_1}    ivlan=0    ivlan_pbit=2    mac_dst=${tg_client.mac}    mac_src=${tg_server.mac}    ip_dst=${tg_client.ip}    ip_src=${tg_server.ip}    rate_mbps=${pkt_rate}
${us_traffic_filter}    (vlan.id==${service_vlan_1}) && (vlan.id==0) && (vlan.priority == 2) && (eth.src==${tg_client.mac}) && (eth.dst==${tg_server.mac}) && (ip.src == ${tg_client.ip}) && (ip.dst == ${tg_server.ip})
${ds_traffic_filter}    (vlan.id==0) && (vlan.priority == 2) && (eth.src==${tg_server.mac}) && (eth.dst==${tg_client.mac}) && (ip.src == ${tg_server.ip}) && (ip.dst == ${tg_client.ip})

*** Test Cases ***
tc_Match_priority_tagged_add_s_tag
    [Documentation]
      
    ...    1	create a class-map to match priority-tagged pcp 3 in flow 1	successfully		
    ...    2	create a policy-map to bind the class-map	successfully		
    ...    3	add eth-port1 to s-tag with transport-service-profile	successfully		
    ...    4	apply the s-tag and policy-map to ethernet uni	successfully		
    ...    5	send upstream traffic with priority-tagged pcp 3 to ethernet uni	eth-port1 can pass the upstream traffic with right tag		
    ...    6	send tagged downstream traffic to eth-port1	client can receive the downstream traffic;		
    #[AXOS-7101] added by Anson Zhang for AXOS R19.1: the tag action of match priority-tagged on eth-uni cannot work
    #jira:http://jira.calix.local/browse/AXOS-7101 
    
    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4342      @subFeature=10GE-12: Ethernet class map support      @globalid=2531529      @priority=P1      @eut=10GE-12          @user_interface=CLI    @jira=AXOS-7101    
    [Setup]     case setup
    [Teardown]     case teardown
    [Template]    template_bidirection_raw_traffic_and_check
    ${tg_us_param}    ${tg_ds_param}    ${us_traffic_filter}    ${ds_traffic_filter}    ${traffic_loss_rate}

*** Keywords ***
case setup
    [Documentation]    setup
    log    STEP:1 create a class-map to match priority-tagged pcp 3 in flow 1 
    prov_class_map    eutA    ${class_map}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    priority-tagged=${EMPTY}
    
    log    STEP:2 create a policy-map to bind the class-map
    prov_policy_map    eutA    ${policy_map}    class-map-ethernet    ${class_map}
    
    log    STEP:3 add eth-port1 to s-tag with transport-service-profile (done in suite_setup)
      
    log    STEP:4 apply the s-tag and policy-map to ethernet uni 
    subscriber_point_add_svc_user_defined    subscriber_point1     ${service_vlan_1}     ${policy_map}
    
case teardown
    [Documentation]    teardown
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${service_vlan_1}    ${policy_map}
    
    log    delete vlan policy-map class-map
    delete_config_object    eutA    policy-map    ${policy_map}
    delete_config_object    eutA    class-map ethernet    ${class_map}
    
   
    