*** Settings ***
Documentation    test_suite keyword lib
Resource         ../base.robot

*** Keywords ***
prov_sip_profile
    [Arguments]    ${device}    ${sip-profile}    ${proxy-server}=${EMPTY}    ${proxy-server-port}=${EMPTY}    ${proxy-server-secondary}=${EMPTY}     
    ...    ${proxy-server-port-secondary}=${EMPTY}    &{dict_cmd}                            
    [Documentation]    Description: provision sip-profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | sip-profile | sip-profile id  |
    ...    | proxy-server| IP address or hostname of SIP proxy server |
    ...    | proxy-server-port | UDP port for proxy server | 
    ...    | proxy-server-secondary | IP address of secondary SIP proxy server |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...    Example:
    ...    | prov_sip_profile | eutA | 10.245.252.2 | 
    [Tags]    @author=XUAN LI
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    sip-profile ${sip-profile} proxy-server ${proxy-server}
    run keyword if    '${EMPTY}'!='${proxy-server-port}'    Axos Cli With Error Check    ${device}    proxy-server-port ${proxy-server-port}    
    run keyword if    '${EMPTY}'!='${proxy-server-secondary}'    Axos Cli With Error Check    ${device}    proxy-server-secondary ${proxy-server-secondary}
    run keyword if    '${EMPTY}'!='${proxy-server-port-secondary}'    Axos Cli With Error Check    ${device}    proxy-server-port-secondary ${proxy-server-port-secondary}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end  
    
dprov_sip_profile
    [Arguments]    ${device}    ${sip-profile}    &{dict_cmd}                            
    [Documentation]    Description: provision sip-profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | sip-profile | sip-profile id  |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...    Example:
    ...    | dprov_sip_profile | eutA | 10.245.252.2 | 
    [Tags]    @author=XUAN LI
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    sip-profile ${sip-profile}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    no ${cmd_string}
    [Teardown]    cli    ${device}    end  
    
prov_dial_Plan
    [Arguments]    ${device}    ${dial-plan}    &{dict}                            
    [Documentation]    Description: provision sip-profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | dial-plan | dial-plan id  |
    ...    | dict | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...    Example:
    ...    | prov_dial_Plan | eutA | autosip | 
    [Tags]    @author=XUAN LI
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    dial-plan ${dial-plan}
    @{list_key}    Get Dictionary Keys    ${dict}
    : FOR    ${key}    IN    @{list_key}
    \    ${value}    Get From Dictionary    ${dict}    ${key}
    \    cli    ${device}    rule ${key} pattern ${value}        
    [Teardown]    cli    ${device}    end  
    
prov_interface_pots
    [Arguments]    ${device}    ${pots_id}    ${sip_service_number}    ${uri}    ${user}    
    ...    ${password}    ${dial-plan}=${EMPTY}    &{dict_cmd}                            
    [Documentation]    Description: provision interface pots
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | pots_id | pots port |
    ...    | sip_service_number | sip-service associated ont-ua |
    ...    | uri | uri |
    ...    | user | user name |
    ...    | password | password |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...    Example:
    ...    | prov_dial_Plan | eutA | autosip | 
    [Tags]    @author=XUAN LI
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface pots ${pots_id} sip-service ${sip_service_number} uri ${uri} user ${user} password ${password}
    run keyword if    '${EMPTY}'!='${dial-plan}'    Axos Cli With Error Check    ${device}    dial-plan ${dial-plan}   
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}     
    [Teardown]    cli    ${device}    end 
     
dprov_interface_pots
    [Arguments]    ${device}    ${pots_id}    &{dict_cmd}                            
    [Documentation]    Description: interface pots deprovision
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | pots_id | pots port |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...    Example:
    ...    | prov_dial_Plan | eutA | autosip | 
    [Tags]    @author=XUAN LI
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface pots ${pots_id} 
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    Axos Cli With Error Check    ${device}    no ${cmd_string}   
    [Teardown]    cli    ${device}    end  
    
prov_interface_sip_profile
    [Arguments]    ${device}    ${ua_id}    ${sip_profile_id}    ${vlan_id}    &{dict_cmd}                            
    [Documentation]    Description: interface pots deprovision
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    | ua_id | interface ua id |
    ...    | sip_profile_id | sip profile id |
    ...    | vlan_id | vlan id |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...    Example:
    ...    | prov_dial_Plan | eutA | autosip | 
    [Tags]    @author=XUAN LI
    cli    ${device}    configure
    # run keyword if    '${EMPTY}'!='${ont_id}'    Axos Cli With Error Check    ${device}    ont ${ont_id}
    # modify for release adapter, start
    # ${ua_id_prefix}    release_cmd_adapter    ${device}    ${prov_sip_profile_ua_id_prefix}    ${ont_id}
    Axos Cli With Error Check    ${device}    interface ont-ua ${ua_id} sip-profile ${sip_profile_id}
    # modify for release adapter, end
    Axos Cli With Error Check    ${device}    vlan ${vlan_id}
    prov_policy_map    ${device}    ${policy_map_name}    class-map-ethernet    ${class_map_name}    ${flow_type}    ${flow_index} 
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string} 
    [Teardown]    cli    ${device}    end
    
prov_interface_ont_ua
    [Arguments]    ${device}    ${ont_ua_id}    ${sip_profile_id}    ${vlan_id}    &{dict_cmd}                            
    [Documentation]    Description: interface pots deprovision
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    | ont_ua_id | interface ua id |
    ...    | sip_profile_id | sip profile id |
    ...    | vlan_id | vlan id |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...    Example:
    ...    | prov_dial_Plan | eutA | autosip | 
    [Tags]    @author=XUAN LI
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}   interface ont-ua ${ont_ua_id} sip-profile ${sip_profile_id}
    Axos Cli With Error Check    ${device}    vlan ${vlan_id} 
    prov_policy_map    ${device}    ${policy_map_name}    class-map-ethernet    ${class_map_name}    ${flow_type}    ${flow_index}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string} 
    [Teardown]    cli    ${device}    end  
    
check_pots_sip_service_status
    [Arguments]    ${device}    ${pots_id}                             
    [Documentation]    Description: interface pots deprovision
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | pots_id | ont id |  
    ...    Example:
    ...    | check_pots_sip_service | eutA | 838/p1 | 
    [Tags]    @author=XUAN LI
    ${res}    Axos Cli With Error Check    ${device}    show interface pots ${pots_id} sip-service
    ${res1}    Get Lines Containing String    ${res}    service-status   
    Should Match Regexp    ${res1}    service-status\\s+registered  
    [return]    ${res1} 
    
check_running_configure_sip_profile
    [Arguments]    ${device}    ${sip_profile}    ${check_item}    ${exp_value}                                
    [Documentation]    Description: interface pots deprovision
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | sip_profile | name of sip-profile |  
    ...    | check_item | the item needed to be checked |
    ...    | exp_value | expect value of this item |
    ...    Example:
    ...    | check_running_configure_sip_profile | eutA | autosip-1 | dns-primary | 0.0.0.0 | 
    [Tags]    @author=XUAN LI
    ${res}    Axos Cli With Error Check    ${device}    show running-config sip-profile ${sip_profile} | details
    Should Match Regexp    ${res}    (?i)${check_item}\\s+${exp_value}
 
    
check_ont_sip_profile
    [Arguments]    ${device}    ${expect_value}    ${check_item}                                
    [Documentation]    Description: check parameters in sip_profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | expect_value | expect value of the check item |  
    ...    | check_item | choosed item |
    ...    Example:
    ...    | check_ont_sip_profile | ontA | 10.245.252.2 |  
    [Tags]    @author=XUAN LI
    cli    ${device}    sh
    ${res}    cli   ${device}    dcli potsmgr show sip_profile
    @{profile_list}    create list    SIP_PROFILE_2    SIP_PROFILE_1
    : FOR    ${sip_prf_name}    IN    @{profile_list}
    \    ${match}    Should Match Regexp    ${res}    (?s)SIP Profile Name:\\s+${sip_prf_name}.*?${check_item}:\\s* ${expect_value}        
    [return]    ${match}
    [Teardown]    cli    ${device}    exit

check_ont_sip_profile_reboot
    [Arguments]    ${device}    ${expect_value}    ${check_item}                                
    [Documentation]    Description: check parameters in sip_profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | expect_value | expect value of the check item |  
    ...    | check_item | choosed item |
    ...    Example:
    ...    | check_ont_sip_profile | ontA | 10.245.252.2 |  
    [Tags]    @author=XUAN LI
    cli    ${device}    sh    
    ${res}    cli   ${device}    dcli potsmgr show sip_profile
    @{profile_list}    create list    SIP_PROFILE_2    SIP_PROFILE_1
    : FOR    ${sip_prf_name}    IN    @{profile_list}
    \    Should Match Regexp    ${res}    (?s)SIP Profile Name:\\s+${sip_prf_name}.*?${check_item}:\\s* ${expect_value}
    [Teardown]    cli    ${device}    exit
    
check_ont_sip_service
    [Arguments]    ${device}    ${sip_pots_port_name}    ${check_item}    ${expect_value}                                    
    [Documentation]    Description: check parameters in sip_profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | expect_value | expect value of the check item |  
    ...    | check_item | choosed item |
    ...    Example:
    ...    | check_ont_sip_profile | ontA | 10.245.252.2 |  
    [Tags]    @author=XUAN LI
    cli    ${device}    sh    
    ${res}    cli   ${device}    dcli potsmgr show sip_service   
    Should Match Regexp    ${res}    (?s)POTS Port:\\s+${sip_pots_port_name}.*?${check_item}:\\s* ${expect_value} 
    [Teardown]    cli    ${device}    exit
    
check_ont_sip_pro_RTP
    [Arguments]    ${device}    ${order_num}    ${param}    ${expect_value}                                
    [Documentation]    Description: check parameters in sip_profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | order_num | SIP_PROFILE_2 or SIP_PROFILE_1 |  
    ...    | param | parameter which needs to check |
    ...    | expect_value | expect value of the choosed param |
    ...    Example:
    ...    | check_ont_sip_profile | ontA | 10.245.252.2 |  
    [Tags]    @author=XUAN LI 
    cli    ${device}    sh   
    ${res}    cli   ${device}    dcli potsmgr show sip_profile  
    @{profile_list}    create list    SIP_PROFILE_2    SIP_PROFILE_1
    : FOR    ${sip_prf_name}    IN    @{profile_list}
    \     Should Match Regexp    ${res}    (?s)SIP Profile Name:\\s+${sip_prf_name}.*?${order_num}.*?${param}:\\s* ${expect_value}         
    [Teardown]    cli    ${device}    exit
    
check_ont_ip_host
     [Arguments]    ${device}    ${param}    ${value}                                
    [Documentation]    Description: interface pots deprovision
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | param | parameter which needs to check |  
    ...    | value | expect value of the choosed param |
    ...    Example:
    ...    | check_ont_ip_host | ontA | DNS Primary |   
    [Tags]    @author=XUAN LI    
    ${res}    cli   ${device}    dcli potsmgr show ip_host 1
    ${res1}    Get Lines Containing String    ${res}    ${param}
    should contain    ${res1}    ${value}
    
subscriber_point_get_interface_pot_name
    [Arguments]    ${subscriber_point}    ${port_num}
    [Documentation]    Description: ont_port subscriber get pon port name
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | port_num | pon port number |
    ...    
    ...    Return Value:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | pon_port | pon port name |
    ...
    ...    Example:
    ...    1. get first interface pots name
    ...    | ${pots_id1} | subscriber_point_get_pon_port_name | subscriber_point1 |
    ...    2. get second interface pots name
    ...    | ${pots_id2} | subscriber_point_get_pon_port_name | subscriber_point1 | 2 |
    [Tags]    @author=XUAN LI
    ${index}    evaluate    ${port_num}-1
    ${pots_id_list}    set variable    @{service_model.${subscriber_point}.attribute.pots_id_list}[${index}]
    [Return]    ${pots_id_list}
    
check_interface_pots_detail
    [Arguments]    ${device}    ${pot_id}    ${ua_id}    &{check_item_values}                                 
    [Documentation]    Description: check parameters in interface pots
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | pot_id | interface pot id |
    ...    | ua_id | ont-ua id |
    ...    | uri_value | the value of uri |
    ...    | user_value | the value of user |
    ...    | password_value | the value of password |

    ...    Example:
    ...    | check_ont_ip_host | ontA | DNS Primary |   
    [Tags]    @author=XUAN LI  
    ${res}    Axos Cli With Error Check    ${device}   show running-config interface pots ${pot_id} | detail
    @{list_key}    Get Dictionary Keys    ${check_item_values}
    : FOR    ${check_item}   IN    @{list_key}
    \    ${exp_value}    Get From Dictionary    ${check_item_values}   ${check_item}
    \    Should Match Regexp    ${res}    (?s)sip-service ${ua_id}.*?${check_item}\\s* ${exp_value}
    [Return]    ${res}
    
check_ont_discovered
    [Arguments]    ${device}    ${ont_id} 
    [Documentation]    show ont 1 status
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    | dict | more option |
    ...    Example:
    ...    | check_ont_status | n1 | 100 | vendor=CXNK | oper-state=present | model=801XGS |
    ...    | check_ont_status | n1 | 100 | curr-version=15.0.555.201 | alt-version =15.0.555.100 |
    ...    | check_ont_status | n1 |100|
    [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show discovered-onts
    should contain    ${result}    ${ont_id}
    
    
check_ont_not_discovered
    [Arguments]    ${device}    ${serial_number}
    [Documentation]    show ont 1 status
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    | dict | more option |
    ...    Example:
    ...    | check_ont_status | n1 | 100 | vendor=CXNK | oper-state=present | model=801XGS |
    ...    | check_ont_status | n1 | 100 | curr-version=15.0.555.201 | alt-version =15.0.555.100 |
    ...    | check_ont_status | n1 |100|
    [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show discovered-onts
    should not contain    ${result}    ${serial_number}

check_ont_pots
    [Arguments]    ${device}    ${pots_id}    ${check_item}    ${expect_value}                                    
    [Documentation]    Description: check parameters in sip_profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | expect_value | expect value of the check item |  
    ...    | check_item | choosed item |
    ...    Example:
    ...    | check_ont_sip_profile | ontA | 10.245.252.2 |  
    [Tags]    @author=XUAN LI
    cli    ${device}    sh    
    ${res}    cli   ${device}    dcli potsmgr show pots   
    Should Match Regexp    ${res}    (?s)${check_item}.*?${pots_id}.*${expect_value} 
    [Teardown]    cli    ${device}    exit    
        
    
check_ont_reset
    [Arguments]    ${device}                                    
    [Documentation]    Description: check parameters in sip_profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | expect_value | expect value of the check item |  
    ...    | check_item | choosed item |
    ...    Example:
    ...    | check_ont_sip_profile | ontA | 10.245.252.2 |  
    [Tags]    @author=XUAN LI
    cli    ontA    sh
    ${res}    cli    ${device}    " "    timeout=5    
    should contain    ${res}    VODSL detects potsmgr is up
    [Return]    ${res}
    [Teardown]    cli    ${device}    exit
    
exit_ont_shell_mode
    [Arguments]    ${device}
    [Documentation]    Description: exit ont shell mode
    [Tags]    @author=llin
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    Example:
    ...    | exit_shell_mode | ontA
    cli    ${device}     exit     prompt=>

enter_ont_shell_mode
    [Arguments]    ${device}
    [Documentation]    Description: enter ont shell mode
    [Tags]    @author=llin
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    Example:
    ...    | exit_shell_mode | ontA
    cli    ${device}     sh     prompt=\\~\\s*\\#


check_ont_reset_success
    [Arguments]    ${device}
    [Documentation]    Description: check ont reset success and could enter to shell mode
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    Example:
    ...    | check_ont_reset_success | ontA | 2min
    [Tags]    @author=llin
    Wait Until Keyword Succeeds    2min    10sec    exit_ont_shell_mode    ${device}
    enter_ont_shell_mode    ${device}



#check_ont_reset_success
#    [Arguments]    ${device}
#    [Documentation]    Description: check parameters in sip_profile
#    ...
#    ...    Arguments:
#    ...    | =Argument Name= | \ =Argument Value= \ |
#    ...    | device | device name setting in your yaml |
#    ...    | expect_value | expect value of the check item |
#    ...    | check_item | choosed item |
#    ...    Example:
#    ...    | check_ont_sip_profile | ontA | 10.245.252.2 |
#    [Tags]    @author=XUAN LI
#    Wait Until Keyword Succeeds    2min    10sec    check_ont_reset    ${device}

    
    
    
