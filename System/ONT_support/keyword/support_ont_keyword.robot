*** Settings ***
Documentation    keyword for ont support
Resource         ../base.robot

*** Keywords ***
paginate_set
    [Arguments]    ${device}    ${page_setvalue}                            
    [Documentation]    Description: paginate set
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | page_setvalue | pageinate set, value set as 'true' or 'false' |
    ...    
    ...    Example:
    ...    | paginate_set | eutA | false | 
    [Tags]    @author=YUE SUN
   Axos Cli With Error Check   ${device}    paginate ${page_setvalue}
    
prov_ont_profile_interface_invalid
    [Arguments]    ${device}    ${profile_name}    ${port}    ${role}=${EMPTY}    ${alarm}=${EMPTY}   
    [Documentation]    Description: provision ont-profile interface parameter invaild, rejected
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | profile_name | ont profile-id |
    ...    | port | ont-port-name |
    ...    | role | role status, as uni or rg |
    ...    | alarm | alarm-suppression, as DISABLED or ENABLED |
    ...    
    ...    Example:
    ...    | prov_ont_profile_interface_invalid | eutA | 822G | g2 | uni | DISABLED |
    [Tags]    @author=YUE SUN      
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ont-profile ${profile_name}
    log    modify default interface ont-ethernet, rejected
    ${cmd_str}    set variable    interface ont-ethernet ${port}
    ${cmd_str}    set variable if    "${role}"!='${EMPTY}'     ${cmd_str} role ${role}     ${cmd_str}
    ${cmd_str}    set variable if    "${alarm}"!='${EMPTY}'     ${cmd_str} alarm-suppression ${alarm}     ${cmd_str}
    ${res}    cli    ${device}    ${cmd_str}
    should contain    ${res}    Error: failed to apply modifications
    [Return]    ${res}
    [Teardown]    cli    ${device}    end
    
dprov_object_invaild
    [Arguments]    ${device}    ${object}    ${object_value}=${EMPTY}    ${subview1}=${EMPTY}    ${subview1_value}=${EMPTY}    ${subview2}=${EMPTY}    ${subview2_value}=${EMPTY}
    [Documentation]    Description: delete object invaild, rejected
    ...     Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | object | all object by deprovision ? |
    ...    | object_value | value of object |
    ...    | subview1 | the first subview of object |
    ...    | subview1_value | value of  subview1 |
    ...    | subview2 | the second subview of object |
    ...    | subview2_value | value of  subview2 |
    ...    
    ...    Example:
    ...    | dprov_object_invaild | eutA | ont-profile | 822G |
    ...    | dprov_object_invaild | eutA | ont-profile | 822G | interface | ont-ethernet | g2 |
    ...    | dprov_object_invaild | eutA | voice-policy-profile | vppro_test |
    [Tags]    @author=YUE SUN  
    cli    ${device}    configure
    ${res}    cli    ${device}     no ${object} ${object_value} ${subview1} ${subview1_value} ${subview2} ${subview2_value}
    should contain    ${res}    Error: failed to apply modifications
    [Return]    ${res}
    [Teardown]    cli    ${device}    end

prov_port_parameter
    [Arguments]    ${device}    ${interface_type}    ${interface_name}=${EMPTY}    ${item}=${EMPTY}    ${parameter}=${EMPTY}
    [Documentation]    Description: provision ont-port 
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | interface_type | interface type |
    ...    | interface_name | interface name |
    ...    | item | item of ont-port |
    ...    | parameter | ont-port parameter of item |
    ...    
    ...    Example:
    ...    | prov_port_parameter | eutA | ont-ethernet | 822/g2 | role | uni |
    ...    | prov_port_parameter | eutA | ont-ethernet | 822/g2 | voice-policy-profile | vppro_test |
    ...    | prov_port_parameter | eutA | ont-ethernet | 822/g2 | poe-priority | high |
    ...    | prov_port_parameter | eutA | ont-ethernet | 822/g2 | poe-admin-state | ENABLED |
    [Tags]    @author=YUE SUN    
    cli    ${device}    configure
    ${res}    Axos Cli With Error Check    ${device}    interface ${interface_type} ${interface_name} ${item} ${parameter}
    [Return]    ${res}
    [Teardown]    cli    ${device}    end
    
prov_ont_parameter
    [Arguments]    ${device}    ${ont_id}    ${item}    ${parameter}=${EMPTY}    ${item2}=${EMPTY}    ${parameter2}=${EMPTY}
    [Documentation]    Description: provision ont parameter 
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | object | all object by ont-port provision ? |
    ...    | object_value | value of object |
    ...    | subview | the subview of object |
    ...    | subview_value | value of  subview |
    ...    
    ...    Example:
    ...    | prov_ont_parameter | eutA | 822 | poe-high-power-mode |
    ...    | prov_ont_parameter | eutA | 822 | pse-max-power-budget | 60 |
    [Tags]    @author=YUE SUN    
    cli    ${device}    configure
    ${res}    Axos Cli With Error Check    ${device}    ont ${ont_id} ${item} ${parameter} ${item2} ${parameter2}
    [Return]    ${res}
    [Teardown]    cli    ${device}    end
      
dprov_port_voice_policy_profile
    [Arguments]    ${device}    ${port_type}    ${port}
    [Documentation]    Description: dprovision ont-port voice-policy-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port_type | ont-port type |
    ...    | port | port name |
    ...    
    ...    Example:
    ...    | dprov_port_voice_policy_profile | eutA | ont-ethernet | 822/g2 |
    [Tags]    @author=YUE SUN    
    cli    ${device}    configure  
    ${res}    Axos Cli With Error Check    ${device}    no interface ${port_type} ${port} voice-policy-profile
    [Return]    ${res}
    [Teardown]    cli    ${device}    end
    
check_ont_lldp
    [Arguments]    ${device}    ${port_num}    ${vlan}    ${p_bit}    ${dscp}    
    [Documentation]    Description: check ont lldp status parameter on ont side
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port_num | ont-port number on ont side |
    ...    | vlan | voice-policy-profile vlan-id |
    ...    | p_bit | voice-policy-profile priority |
    ...    | dscp | voice-policy-profile dscp value |
    ...    
    ...    Example:
    ...    | check_ont_lldp | ontA | 1 | 4094 | 1 | 46 |
    [Tags]    @author=YUE SUN 
    cli    ${device}    sh    timeout=10
    cli    ${device}    omci    timeout=10
    ${res}    cli    ${device}    lldp status    timeout=60
    Should Match Regexp    ${res}    ${port_num}\\s+${vlan}+\\s+${p_bit}+\\s+${dscp}
    cli    ${device}    exit
    [Return]    ${res}
    [Teardown]    disconnect    ${device}    
    
check_ont_poe
    [Arguments]    ${device}    ${misc_poe_table}    ${poe_item}    ${uni_port}    ${exp_value}
    [Documentation]    Description: check ont misc poe parameter on ont side
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | misc_poe_table | table form in paramater file |
    ...    | poe_item | row key for check item |
    ...    | uni_port | column key for check item|
    ...    | exp_value | expect value for check item |
    ...    
    ...    Example:
    ...    | check_ont_poe | ontA | misc_poe_table | uni1 | poe_enable | 1 |
    ...    | check_ont_poe | ontA | misc_poe_table | uni3 | priority | 1 |
    [Tags]    @author=YUE SUN 
    cli    ${device}    sh    timeout=10
    cli    ${device}    omci    timeout=10
    ${res}    cli    ${device}    misc poe    timeout=60
    verify_cli_response_table_by_key    ${res}    ${misc_poe_table}    ${poe_item}    ${uni_port}    ${exp_value}
     cli    ${device}    exit
    [Return]    ${res}
    [Teardown]    disconnect    ${device}  
    
check_ont_detail
    [Arguments]    ${device}    ${ont_id}    ${owner}=${EMPTY}    ${power}=${EMPTY}    ${output}=${EMPTY}
    [Documentation]    show ont detail
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    | owner | pse-mgmt-ownership value |
    ...    | power | pse-available-power-budget 0-90 |
    ...    | output | pse-agg-output-power |
    ...    
    ...    Example:
    ...    | check_ont_status | eutA | 822 | OMCI-Only | 30.0 |
    [Tags]    @author=YUE SUN 
    ${res}    Axos Cli With Error Check    ${device}    show ont ${ont_id} detail
    run keyword if    '${owner}'!='${EMPTY}'    Should Match Regexp    ${res}    pse-mgmt-ownership\\s+${owner}
    run keyword if    '${power}'!='${EMPTY}'    Should Match Regexp    ${res}    pse-available-power-budget\\s+${power}
    run keyword if    '${output}'!='${EMPTY}'    Should Match Regexp    ${res}    pse-agg-output-power\\s+${output}
    [Return]    ${res}
    
dprov_vlan_timeout
    [Arguments]    ${device}    ${vlan}
    [Documentation]    delete vlan
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | vlan name |
    ...    
    ...    Example:
    ...    | dprov_vlan_timeout | n1 | 100 |
    [Tags]    @author=YUE SUN
    cli    ${device}    configure
    ${res}    Axos Cli With Error Check    ${device}    no vlan ${vlan}    120
    [Return]    ${res}
    [Teardown]    cli    ${device}    end
    