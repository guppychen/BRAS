*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       Layer_2_SIP_support_suite_provision
Suite Teardown    Layer_2_SIP_support_suit_deprovision
Force Tags        @feature=Layer_2_SIP_support    @subfeature=Layer_2_SIP_support    @author=XUAN_LI
Resource          ./base.robot

*** Variables ***
&{rule_pattern_dict}    1=${pattern1}    2=${pattern2}    


*** Keywords ***
Layer_2_SIP_support_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=XUAN_LI
    log    suite provision for sub_feature
    prov_vlan    eutA    ${service_vlan}
    cli    ontA    sh
    cli    ontA    rm -rf /exa_data/var_log_messages_reset_saved
    cli    ontA    rm -rf /exa_data/ngx_console_saved  
    prov_class_map    eutA    ${class_map_name}    ${class_map_type1}    ${flow_type}    ${flow_index}    ${rule_index}    =untagged
    prov_policy_map    eutA    ${policy_map_name}    ${class_map_type2}    ${class_map_name}    ${flow_type}    ${flow_index}  
    service_point_prov    service_point_list1      
    log    service_point_add_vlan for uplink service 
    service_point_add_vlan    service_point_list1    ${service_vlan}
    
    log    sip-profile
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    
    
    log    dial-plan
    prov_dial_Plan    eutA    ${dial_plan}    &{rule_pattern_dict}       
    
    log    prov ont
    subscriber_point_prov    subscriber_point1
    prov_interface_sip_profile    eutA    ${ont_ua_id}    ${sip_profile_id}    ${service_vlan}        
    prov_interface_sip_profile    eutA    ${ont_ua_id}    ${sip_profile_id}    ${service_vlan}  
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    ${pots_id2}    subscriber_point_get_interface_pot_name    subscriber_point1    2       
    prov_interface_pots    eutA    ${pots_id1}    ${ua_id}    ${uri_number1}    ${user_number1}    ${password}    ${dial_plan}
    Wait Until Keyword Succeeds    5min    10sec    check_pots_sip_service_status    eutA    ${pots_id1}           
    prov_interface_pots    eutA    ${pots_id2}    ${ua_id}    ${uri_number2}    ${user_number2}    ${password}    ${dial_plan}
    Wait Until Keyword Succeeds    5min    10sec    check_pots_sip_service_status    eutA    ${pots_id2}  
Layer_2_SIP_support_suit_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=XUAN_LI
    log    suite deprovision for sub_feature
    # ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    # ${pots_id2}    subscriber_point_get_interface_pot_name    subscriber_point1    2 
    # dprov_interface_pots    eutA    ${pots_id2}    sip-service=${sip_service_number}
    # dprov_interface_pots    eutA    ${pots_id1}    sip-service=${sip_service_number}
    # subscriber_point_dprov    subscriber_point1
    # delete_config_object    eutA    dial-plan    ${dial_plan}          
    # delete_config_object    eutA    sip-profile    ${sip_profile} 
    # service_point_remove_vlan    service_point_list1    ${service_vlan}
    # # service_point_dprov    service_point_list1   
    # dprov_policy_map    eutA    ${policy_map_name}    policy-map=${policy_map_name}
    # dprov_class_map     eutA    ${class_map_name}    ${class_map_type1}    ${EMPTY}    ${EMPTY}    class-map ethernet=${class_map_name}   
    # dprov_vlan    eutA    ${service_vlan}  