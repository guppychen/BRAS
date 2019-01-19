*** Settings ***
Documentation    test_suite keyword lib

*** Keywords ***
config_interface_with_service_role_inni
    [Arguments]    ${device}    ${port_type}    ${port_name}                      
    [Documentation]    check_interface_module_param_not_empty 
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | eutA | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | input_cmd | high-tx-opt-pwr-ne-thresh |
    ...    | exp_value | high-tx-opt-pwr-ne | 
    ...
    ...    Example:
    ...    | Check_high-tx-opt-pwr-ne_alarm | eutA | pon | 1/1/gp1 |               
    [Tags]    @author=Luna Zhang
    ${}set variable
    Cli    ${device}    config
    Cli    ${device}    interface ${port_type} ${port_name} 
    Cli    ${device}    role inni
    Cli    ${device}    end     


config_interface_with_lldp_profile
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${profile_name}                      
    [Documentation]    check_interface_module_param_not_empty 
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | eutA | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | input_cmd | high-tx-opt-pwr-ne-thresh |
    ...    | exp_value | high-tx-opt-pwr-ne | 
    ...
    ...    Example:
    ...    | Check_high-tx-opt-pwr-ne_alarm | eutA | pon | 1/1/gp1 |               
    [Tags]    @author=Luna Zhang
    Cli    ${device}    config
    Cli    ${device}    interface ${port_type} ${port_name} 
    Cli    ${device}    lldp profile ${profile_name}  
    Cli    ${device}    end     

remove_lldp_profile_from_interface  
    [Arguments]    ${device}    ${port_type}    ${port_name}                          
    [Documentation]    check_interface_module_param_not_empty 
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | eutA | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | input_cmd | high-tx-opt-pwr-ne-thresh |
    ...    | exp_value | high-tx-opt-pwr-ne | 
    ...
    ...    Example:
    ...    | Check_high-tx-opt-pwr-ne_alarm | eutA | pon | 1/1/gp1 |               
    [Tags]    @author=Luna Zhang
    Cli    ${device}    config
    Cli    ${device}    interface ${port_type} ${port_name} 
    Cli    ${device}    no lldp profile
    Cli    ${device}    end       
    
lldp_admin_state
    [Arguments]    ${device}    ${interface}    ${admin_state}                      
    [Documentation]    check_interface_module_param_not_empty 
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | interface | interface name in service_model.yaml |
    ...    | admin_state | disable,enable |
    ...    Example:
    ...    | lldp_admin_state | eutA | 1/1/x1 | disabled |
    ...    | lldp_admin_state | eutA | 1/1/x1 | enabled |
    [Tags]    @author=Luna Zhang
    cli    eutA    config
    cli    eutA    interface ethernet ${service_model.service_point1.member.interface1} lldp admin-state ${admin_state}    
    cli    eutA    end    
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    ${admin_state}      

config_hostname
    [Arguments]    ${device}    ${hostname}    ${remove_opt}=${EMPTY}                      
    [Documentation]    check_interface_module_param_not_empty 
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | interface | interface name in service_model.yaml |
    ...    | admin_state | disable,enable |
    ...    Example:
    ...    | config_hostname | eutA | test_name | remove_opt=no |
    ...    | config_hostname | eutA | test_name |  
    [Tags]    @author=Luna Zhang
    cli    eutA    config
    cli    eutA    ${remove_opt} hostname ${hostname}     
    cli    eutA    end    

prov_lldp_profile
    [Arguments]    ${device}    ${profile_name}    ${obj}=${EMPTY}    ${obj_opt}=${EMPTY}    
    [Documentation]    provision ont
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | obj_opt | suppress,transmit |
    ...    Example:
    ...    | prov_lldp_profile | n1 | lldp | system-name-tlv | suppress |
    ...    | prov_lldp_profile | n1 | lldp | 
    [Tags]    @author=LunaZhang
    cli    ${device}    configure
    Axos Cli With Error Check    eutA    lldp-profile ${profile_name} 
    cli    eutA    ${obj} ${obj_opt}   
    cli    eutA    end

dprov_lldp_profile
    [Arguments]    ${device}    ${profile_name}  
    [Documentation]    provision ont
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | obj_opt | suppress,transmit |
    ...    Example:
    ...    | prov_lldp_profile | n1 | lldp | system-name-tlv | suppress |
    ...    | prov_lldp_profile | n1 | lldp | 
    [Tags]    @author=LunaZhang
    cli    ${device}    configure
    cli    eutA    no lldp-profile ${profile_name}   
    [Teardown]    cli    ${device}    end          