*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=Policy Map      @author=MinGu

*** Variables ***
&{tg_us_param}    ovlan=${match_vlan}    mac_dst=${tg_server.mac}    mac_src=${tg_client.mac}    ip_dst=${tg_server.ip}    ip_src=${tg_client.ip}    rate_mbps=${pkt_rate}
&{tg_ds_param}    ovlan=${service_vlan}    mac_dst=${tg_client.mac}    mac_src=${tg_server.mac}    ip_dst=${tg_client.ip}    ip_src=${tg_server.ip}    rate_mbps=${pkt_rate}
${us_traffic_filter}    (vlan.id==${service_vlan}) && (eth.src==${tg_client.mac}) && (eth.dst==${tg_server.mac}) && (ip.src == ${tg_client.ip}) && (ip.dst == ${tg_server.ip})
${ds_traffic_filter}    (vlan.id==${match_vlan}) && (eth.src==${tg_server.mac}) && (eth.dst==${tg_client.mac}) && (ip.src == ${tg_server.ip}) && (ip.dst == ${tg_client.ip})


*** Test Cases ***
tc_remove_cevlan
    [Documentation]
      
    ...    1	create a class-map to match VLAN x in flow 1	succesfully		
    ...    2	create a policy-map to bind the class-map with the action of remove cevlan	succesfully		
    ...    3	add eth-port1 to s-tag with transport-service-profile	succesfully		
    ...    4	apply the s-tag and policy-map to ethernet uni	succesfully		
    ...    5	send upstream traffic with VLAN x to ethernet uni and downstream with s-tag to eth-port1	eth-port1 can pass the upstream traffic with right tag; client can receive the downstream traffic with tag x		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4351      @subFeature=10GE-12: Policy Map support      @globalid=2532600      @priority=P1      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
    [Template]    template_bidirection_raw_traffic_and_check
    ${tg_us_param}    ${tg_ds_param}    ${us_traffic_filter}    ${ds_traffic_filter}    ${traffic_loss_rate}
      

    
*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    STEP:1 create a class-map to match VLAN x in flow 1 
    log    STEP:2 create a policy-map to bind the class-map with the action of remove cevlan 
    log    STEP:3 add eth-port1 to s-tag with transport-service-profile 
    log    STEP:4 apply the s-tag and policy-map to ethernet uni
    subscriber_point_add_svc    subscriber_point1    ${match_vlan}    ${service_vlan}    remove-cevlan
    
case teardown
    [Documentation]
    [Arguments]
    log    svc teardown
    subscriber_point_remove_svc    subscriber_point1    ${match_vlan}    ${service_vlan}