*** Settings ***
Documentation    keyword for axos command level
Resource         ../base.robot

*** Variables ***
${device_reload_time}    5min
${card_reload_time}    5min

*** Keywords ***
convert_dictionary_to_string
    [Arguments]    &{dict}
    [Documentation]    Description: convert dictionary to string with all key and value
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | dict | input dictionary |
    ...
    ...    Return Value:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | result_string | output string |
    ...
    ...    Example:
    ...    | ${res} | convert_dictionary_to_string | vlan=100 | dhcp=test |
    ...    In this example, ${res}= vlan 100 dhcp test
    [Tags]    @author=CindyGao
    ${result_string}    set variable    ${EMPTY}
    # @{list_key}    Get Dictionary Keys    ${dict}
    : FOR    ${key}   IN    @{dict.keys()} 
    \    ${value}    Get From Dictionary    ${dict}   ${key}
    \    ${result_string}    set variable    ${result_string} ${key} ${value}
    [Return]    ${result_string}

axos_config_keyword_template
    [Arguments]    ${device}    ${view_type}    ${view_name}    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description: this is the template for writing keyword in axos config view
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | view_type | cli view type, when writing keyword for detail command this is always mandatory, no need to add it in Arguments |
    ...    | view_name | cli view name |
    ...    | sub_view_type | cli sub_view type, if don't have sub_view, no need to add it in Arguments |
    ...    | sub_view_value | cli sub_view name, if don't have sub_view, no need to add it in Arguments |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    1. one layer cli view:
    ...    In this example, first go to 'interface ethernet 1/1/x4' cli view, then input command 'description intf switchport ENABLED role inni'
    ...    | axos_config_keyword_template | eutA | interface | ethernet 1/1/x4 | description=intf | switchport=ENABLED | role=inni |
    ...    2. two layer cli view:
    ...    In this example, first go to 'class-map ethernet l2classmap' cli view, then go to 'flow 1' sub view,
    ...    then input command 'rule 1 match src-mac 00:01:00:00:00:01'
    ...    | axos_config_keyword_template | eutA | class-map | ethernet l2classmap | flow | 1 | rule=1 match src-mac 00:01:00:00:00:01 |
    ...    3. you can add more sub_view option if command have more layer
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    cli    ${device}    ${view_type} ${view_name}
    run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

prov_interface
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${svc_vlan}=${EMPTY}    ${policy_map_name}=${EMPTY}
    ...    ${class_map_type}=${EMPTY}    ${class_map_name}=${EMPTY}    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description: interface provision, especially for add svc
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | svc_vlan | Ethernet service vlan |
    ...    | policy_map_name | name for policy-map |
    ...    | class_map_type | type for class-map, {class-map-ethernet|class-map-ip} |
    ...    | class_map_name | name for class-map |
    ...    | sub_view_type | sub_view type depends on cli layer |
    ...    | sub_view_value | sub_view name depends on cli layer |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    1. add policy-map to ethernet port
    ...    | prov_interface | eutA | ethernet | 1/1/x1 | 200 | l2policymap |
    ...    2. add policy-map with flow setting to ont-ethernet port
    ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 100 | l2policymap | class-map-ethernet | l2classmap | flow | 1 | ingress-meter=cir 1000 |
    ...    3. add igmp to ont-ethernet port
    ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 300 | sub_view_type=igmp multicast-profile | sub_view_value=igmptest | igmp max-streams=64 |
    ...    4. add ip host to ont-ethernet port
    ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 400 | sub_view_type=ipv4 host | sub_view_value=192.1.1.1 | inner-vlan=100 | gateway1=192.1.1.1 |
    ...    5. add no subview parameter to ethernet port
    ...    | prov_interface | eutA | ethernet | 1/1/x1 | role=inni | transport-service-profile=test | speed=10Gbs |
    [Tags]    @author=CindyGao
    log    ****** [${device}] provision interface ${port_type} ${port_name}: svlan=${svc_vlan}, policy-map=${policy_map_name} ******
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port_type} ${port_name}
    run keyword if    '${EMPTY}'!='${svc_vlan}'    Axos Cli With Error Check    ${device}    vlan ${svc_vlan}
    run keyword if    '${EMPTY}'!='${policy_map_name}'    Axos Cli With Error Check    ${device}    policy-map ${policy_map_name}
    run keyword if    '${EMPTY}'!='${class_map_type}'    Axos Cli With Error Check    ${device}    ${class_map_type} ${class_map_name}
    run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

dprov_interface
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${svc_vlan}=${EMPTY}    ${policy_map_name}=${EMPTY}    ${class_map_type}=${EMPTY}    ${class_map_name}=${EMPTY}
    ...    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description: interface deprovision, especially for remove svc
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | svc_vlan | Ethernet service vlan |
    ...    | policy_map_name | name for policy-map |
    ...    | class_map_type | type for class-map, {class-map-ethernet|class-map-ip} |
    ...    | class_map_name | name for class-map |
    ...    | sub_view_type | sub_view type depends on cli layer |
    ...    | sub_view_value | sub_view name depends on cli layer |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    1. remove vlan service from ont-ethernet port
    ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | vlan=100 |
    ...    2. remove policy-map from ethernet port
    ...    | dprov_interface | eutA | ethernet | 1/1/x1 | 200 | policy-map=l2policymap |
    ...    3. remove policy-map flow 1 parameter ingress-meter from ont-ethernet port
    ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 100 | l2policymap | class-map-ethernet | l2classmap | flow | 1 | ingress-meter=cir 1000 |
    ...    4. remove igmp from ont-ethernet port
    ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 300 | igmp multicast-profile=igmptest |
    ...    5. remove ip host from ont-ethernet port
    ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 400 | ipv4 host=192.1.1.1 |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port_type} ${port_name}
    run keyword if    '${EMPTY}'!='${svc_vlan}'    Axos Cli With Error Check    ${device}    vlan ${svc_vlan}
    run keyword if    '${EMPTY}'!='${policy_map_name}'    Axos Cli With Error Check    ${device}    policy-map ${policy_map_name}
    run keyword if    '${EMPTY}'!='${class_map_type}'    Axos Cli With Error Check    ${device}    ${class_map_type} ${class_map_name}
    run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    no ${cmd_string}
    [Teardown]    cli    ${device}    end

prov_interface_ip
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${ip}=${EMPTY}    ${mask}=${EMPTY}    ${gateway}=${EMPTY}
    [Documentation]    Description: add service to subscriber port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | subscriber_port type, {ethernet|ont-ethernet|dsl} |
    ...    | port_name | subscriber_port name |
    ...    | ip | IP Address |
    ...    | mask | IP Mask |
    ...    | gateway | Default Gateway |
    ...
    ...    Example:
    ...    | prov_interface_ip | eutA | craft | 1 | 10.245.10.100 | 255.255.255.0 | 10.245.10.1 | 
    ...    | prov_interface_ip | eutA | restricted-ip-host | 1 | 10.10.10.10 | 255.255.255.0 | 10.10.10.1 | 
    ...    | prov_interface_ip | eutA | restricted-ip-host | 1 | mask=255.255.255.0 | gateway=10.10.10.1 | 
    ...    | prov_interface_ip | eutA | ip-host | 1 | dhcp |
    [Tags]    @author=CindyGao
    log    ****** [${device}] provision interface ${port_type} ${port_name}: ip ${ip} mask ${mask} gateway ${gateway} ******
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port_type} ${port_name}
    ${cmd_str}    set variable    ip 
    ${cmd_str}    Set Variable If    '${ip}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} address ${ip}
    # [AT-3396] modify by CindyGao for 35b adapt, start
    ${mask_str}    Run Keyword If    '${mask}'!='${EMPTY}'    prov_interface_ip_adapter_mask    ${device}    ${mask}
    ...    ELSE    set variable    ${EMPTY}
    ${cmd_str}    Set Variable If    '${gateway}'=='${EMPTY}'    ${cmd_str}${mask_str}    ${cmd_str}${mask_str} gateway ${gateway}
    # [AT-3396] modify by CindyGao for 35b adapt, end
    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end

prov_interface_one2one
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${svc_vlan}=${EMPTY}    ${c_vlan}=${EMPTY}    ${policy_map_name}=${EMPTY}
    ...    ${class_map_type}=${EMPTY}    ${class_map_name}=${EMPTY}    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description: interface provision, especially for add svc
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | svc_vlan | Ethernet service vlan |
    ...    | c_vlan | one2one c-vlan |
    ...    | policy_map_name | name for policy-map |
    ...    | class_map_type | type for class-map, {class-map-ethernet|class-map-ip} |
    ...    | class_map_name | name for class-map |
    ...    | sub_view_type | sub_view type depends on cli layer |
    ...    | sub_view_value | sub_view name depends on cli layer |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    1. add policy-map to ethernet port
    ...    | prov_interface | eutA | ethernet | 1/1/x1 | 200 | l2policymap |
    ...    2. add policy-map with flow setting to ont-ethernet port
    ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 100 | l2policymap | class-map-ethernet | l2classmap | flow | 1 | ingress-meter=cir 1000 |
    ...    3. add igmp to ont-ethernet port
    ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 300 | sub_view_type=igmp multicast-profile | sub_view_value=igmptest | igmp max-streams=64 |
    ...    4. add ip host to ont-ethernet port
    ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 400 | sub_view_type=ipv4 host | sub_view_value=192.1.1.1 | inner-vlan=100 | gateway1=192.1.1.1 |
    ...    5. add no subview parameter to ethernet port
    ...    | prov_interface | eutA | ethernet | 1/1/x1 | role=inni | transport-service-profile=test | speed=10Gbs |
    ...    6. add policy-map to ont-ethernet port for one2one service
    ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 500 | 10 | l2policymap |
    ...    [AT-5607] move from feature folder to common keyword
    [Tags]    @author=LincolnYu
    log    ****** [${device}] provision interface ${port_type} ${port_name}: svlan=${svc_vlan}, cvlan=${c_vlan}, policy-map=${policy_map_name} ******
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port_type} ${port_name}
    run keyword if    '${EMPTY}'!='${svc_vlan}'    Axos Cli With Error Check    ${device}    vlan ${svc_vlan}
    run keyword if    '${EMPTY}'!='${c_vlan}'    Axos Cli With Error Check    ${device}    c-vlan ${c_vlan}
    run keyword if    '${EMPTY}'!='${policy_map_name}'    Axos Cli With Error Check    ${device}    policy-map ${policy_map_name}
    run keyword if    '${EMPTY}'!='${class_map_type}'    Axos Cli With Error Check    ${device}    ${class_map_type} ${class_map_name}
    run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

dprov_interface_one2one
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${svc_vlan}=${EMPTY}    ${c_vlan}=${EMPTY}    ${policy_map_name}=${EMPTY}    ${class_map_type}=${EMPTY}    ${class_map_name}=${EMPTY}
    ...    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description: interface deprovision, especially for remove svc
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | svc_vlan | Ethernet service vlan |
    ...    | c_vlan | one2one c-vlan |
    ...    | policy_map_name | name for policy-map |
    ...    | class_map_type | type for class-map, {class-map-ethernet|class-map-ip} |
    ...    | class_map_name | name for class-map |
    ...    | sub_view_type | sub_view type depends on cli layer |
    ...    | sub_view_value | sub_view name depends on cli layer |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    1. remove vlan service from ont-ethernet port
    ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | vlan=100 |
    ...    2. remove policy-map from ethernet port
    ...    | dprov_interface | eutA | ethernet | 1/1/x1 | 200 | policy-map=l2policymap |
    ...    3. remove policy-map flow 1 parameter ingress-meter from ont-ethernet port
    ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 100 | l2policymap | class-map-ethernet | l2classmap | flow | 1 | ingress-meter=cir 1000 |
    ...    4. remove igmp from ont-ethernet port
    ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 300 | igmp multicast-profile=igmptest |
    ...    5. remove ip host from ont-ethernet port
    ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 400 | ipv4 host=192.1.1.1 |
    ...    6. remove policy-map from one2one service
    ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 500 | 10 | policy-map=l2policymap |
    ...    [AT-5607] move from feature folder to common keyword
    [Tags]    @author=LincolnYu
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port_type} ${port_name}
    run keyword if    '${EMPTY}'!='${svc_vlan}'    Axos Cli With Error Check    ${device}    vlan ${svc_vlan}
    run keyword if    '${EMPTY}'!='${c_vlan}'    Axos Cli With Error Check    ${device}    c-vlan ${c_vlan}
    run keyword if    '${EMPTY}'!='${policy_map_name}'    Axos Cli With Error Check    ${device}    policy-map ${policy_map_name}
    run keyword if    '${EMPTY}'!='${class_map_type}'    Axos Cli With Error Check    ${device}    ${class_map_type} ${class_map_name}
    run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    no ${cmd_string}
    [Teardown]    cli    ${device}    end

shutdown_port
    [Arguments]    ${device}    ${port-type}    ${port}
    [Documentation]    Puts an interface in shutdown mode
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port-type | interface type |
    ...    | port |interface name |
    ...    | shelf | interface shelf |
    ...    | slot | interface Slot number |
    ...
    ...    Example:
    ...    | shutdown_port | AXOS | 1 | pon | gp16 | 1 | 1 |
    [Tags]    @author=BlairWang
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port-type} ${port}
    Axos Cli With Error Check    ${device}    shutdown
    [Teardown]    Axos Cli With Error Check    ${device}    end

no_shutdown_port
    [Arguments]    ${device}    ${port-type}    ${port}
    [Documentation]    Puts an interface in shutdown mode
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port-type | interface type |
    ...    | port |interface name |
    ...    | shelf | interface shelf |
    ...    | slot | interface Slot number |
    ...
    ...    Example:
    ...    | shutdown_port | AXOS | 1 | pon | gp16 | 1 | 1 |
    [Tags]    @author=BlairWang
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port-type} ${port}
    Axos Cli With Error Check    ${device}    no shutdown    30
    [Teardown]    Axos Cli With Error Check    ${device}    end

check_cmd_result
    [Arguments]    ${result}    ${contain}=yes    &{dict_check_item}
    [Documentation]    Description: check &{dict_check_item} for command result
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | name | vlan or interface name, default=${EMPTY} for summary type |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    | dict_check_item | dictionary type check item, format as check_item=exp_value or check_item=${EMPTY} |
    ...    Example:
    ...    | ${res} | check_igmp_statistics | eutA | summary |
    ...    | check_cmd_result | ${res} | tx-general-queries=10 |
    [Tags]    @author=CindyGao
    : FOR    ${check_item}   IN    @{dict_check_item.keys()}
    \    ${pattern}    Set Variable    (?i)${check_item}\\s+${dict_check_item['${check_item}']}\\s*
    \    Run Keyword If    "yes"=="${contain}"    Should Match Regexp    ${result}    ${pattern}
    \    ...    ELSE    Should Not Match Regexp    ${result}    ${pattern}

check_interface_up
    [Arguments]    ${device}    ${port_type}    ${port_name}
    [Documentation]    Description: check interface status up
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...
    ...    Example:
    ...    | check_interface | eutA | ont-ethernet | 100/x1 |
    ...    | check_interface | eutA | ethernet | 1/1/x1 |
    [Tags]    @author=CindyGao
    ${res}    Axos Cli With Error Check    ${device}    show interface ${port_type} ${port_name} status
    Should Match Regexp    ${res}    oper-state\\s+up
    [Return]    ${res}

check_interface
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${query_cmd}    ${check_item}    ${exp_value}
    [Documentation]    Description: check "show interface ${port_type} ${port_name} ${query_cmd}" information 
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | query_cmd | command key for "show interface ${port_type} ${port_name} ${query_cmd}" command, it also can be set to ${EMPTY} |
    ...    | check_item | check item in show command display |
    ...    | exp_value | expect value for check item |
    ...
    ...    Example:
    ...    | check_interface | eutA | ont-ethernet | 100/x1 | detail | rate | 10g |
    ...    | check_interface | eutA | ethernet | 1/1/x1 | status | oper-state | up |
    [Tags]    @author=CindyGao
    ${res}    Axos Cli With Error Check    ${device}    show interface ${port_type} ${port_name} ${query_cmd}
    Should Match Regexp    ${res}    ${check_item}\\s+${exp_value}
    [Return]    ${res}

check_running_config_interface
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${query_cmd}=${EMPTY}    &{dict_check_item}
    [Documentation]    Description: check "show running-config interface ${port_type} ${port_name} ${query_cmd}" information
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | query_cmd | command key for "show running-config interface ${port_type} ${port_name} ${query_cmd}" command, it also can be set to ${EMPTY} |
    ...    | dict_check_item | dictionary type check item, format as check_item=exp_value or check_item=${EMPTY} |
    ...
    ...    Example:
    ...    | check_running_config_interface | eutA | ont-ethernet | 100/x1 | policy-map=policyMapName |
    ...    | check_running_config_interface | eutA | ethernet | 1/1/x1 | transport-service-profile=tsp_name |
    [Tags]    @author=CindyGao
    ${res}    Axos Cli With Error Check    ${device}    show running-config interface ${port_type} ${port_name} ${query_cmd}
    @{list_key}    Get Dictionary Keys    ${dict_check_item}
    : FOR    ${check_item}   IN    @{list_key}
    \    ${exp_value}    Get From Dictionary    ${dict_check_item}   ${check_item}
    \    Should Match Regexp    ${res}    ${check_item}\\s+${exp_value}
    [Return]    ${res}

prov_vlan
    [Arguments]    ${device}    ${vlan}    ${l2-dhcp-profile}=${EMPTY}    ${igmp-profile}=${EMPTY}    ${pppoe-ia-id-profile}=${EMPTY}    ${mac-learning}=${EMPTY}
    ...    ${mode}=${EMPTY}    ${source-verify}=${EMPTY}    ${mff}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description: provision vlan
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | vlan id |
    ...    | l2-dhcp-profile | l2-dhcp-profile name |
    ...    | igmp-profile | igmp-profile name |
    ...    | pppoe-ia-id-profile | pppoe-ia-id-profile name |
    ...    | mac-learning | enable/disable |
    ...    | mode | mode of vlan |
    ...    | source-verify | enable/disable |
    ...    | mff | enable /disable |
    ...    | dict_cmd | more option |
    ...
    ...    Example:
    ...    | prov_vlan | n1 | 100 | l2-dhcp-profile=pro1 | mac-learning=enable |
    [Tags]    @author=AnneLi
    ${cmd_str}    set variable    vlan ${vlan}
    ${cmd_str}    Set Variable If    '${l2-dhcp-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} l2-dhcp-profile ${l2-dhcp-profile}
    ${cmd_str}    Set Variable If    '${igmp-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} igmp-profile ${igmp-profile}
    ${cmd_str}    Set Variable If    '${pppoe-ia-id-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} pppoe-ia-id-profile ${pppoe-ia-id-profile}
    ${cmd_str}    Set Variable If    '${mac-learning}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mac-learning ${mac-learning}
    ${cmd_str}    Set Variable If    '${mode}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mode ${mode}
    # ${cmd_str}    Set Variable If    '${source-verify}'=='${EMPTY}' and '${mff}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} security
    ${cmd_str}    Set Variable If    '${source-verify}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} source-verify ${source-verify}
    ${cmd_str}    Set Variable If    '${mff}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mff ${mff}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${cmd_str}
    ${cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end

dprov_vlan
    [Arguments]    ${device}    ${vlan}    @{cmd_list}
    [Documentation]    deprovision vlan
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | cmd_list | part of " igmp-profile l2-dhcp-profile l3-service mac-learning mode pppoe-ia-id-profile security source-verify security mff " and so on |
    ...    Example:
    ...    | dprov_vlan | n1 | 100| l2-dhcp-profile mac-learning |
    ...    | dprov_vlan | n1 | 100| security source-verify |
    ...    | dprov_vlan | n1 | 100|
    [Tags]    @author=AnneLi
    cli    ${device}    configure
    cli    ${device}    vlan ${vlan}
    ${cmd_string}    Set Variable    ${EMPTY}
    : FOR    ${element}    IN    @{cmd_list}
    \    ${cmd_string}    set variable    no ${element}
    \    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

check_running_configure_vlan
    [Arguments]    ${device}    ${vlan_id}    &{dict}
    [Documentation]    show run-configure vlan
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    | dict | more option |
    ...    Example:
    ...    | check_run_configure_vlan | n1 | 100 | mode=N2ONE | igmp-profile=anne | security source-verify=ENABLE |
    [Tags]    @author=AnneLi
    Axos Cli With Error Check      ${device}    show running-config vlan ${vlan_id}
    ${result}    cli      ${device}    show running-config vlan ${vlan_id}
    @{list_key}    Get Dictionary Keys    ${dict}
    : FOR    ${key}    IN    @{list_key}
    \    ${value}    Get From Dictionary    ${dict}    ${key}
    \    ${res1}    Get Lines Containing String    ${result}    ${key}
    \    Should contain    ${res1}    ${value}

prov_class_map
    [Arguments]    ${device}    ${class_map_name}    ${class_map_type}    ${flow_type}    ${flow_index}   ${rule_index}    &{dict_cmd}
    [Documentation]    Description: provision class-map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | class_map_name | name for class-map |
    ...    | class_map_type | type for class-map, {ethernet|ip} |
    ...    | flow_type | {flow} for ethernet class-map; {ingress-flow|egress-flow} for ip class-map |
    ...    | flow_index | Flow index 1-8 |
    ...    | rule_index | Rule index 1-16 |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    | prov_class_map | eutA | l2classmap | ethernet | flow | 1 | 1 | src-mac=01:00:00:01:00:00 |
    ...    | prov_class_map | eutA | l3classmap | ip | ingress-flow | 1 | 1 | dscp=0x00 |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    cli    ${device}    class-map ${class_map_type} ${class_map_name}
    Axos Cli With Error Check    ${device}    ${flow_type} ${flow_index}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    Axos Cli With Error Check    ${device}    rule ${rule_index} match ${cmd_string}
    [Teardown]    cli    ${device}    end

dprov_class_map
    [Arguments]    ${device}    ${class_map_name}    ${class_map_type}    ${flow_type}=${EMPTY}    ${flow_index}=${EMPTY}   &{dict_cmd}
    [Documentation]    Description: deprovision class-map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | class_map_name | name for class-map |
    ...    | class_map_type | type for class-map, {ethernet|ip} |
    ...    | flow_type | {flow} for ethernet class-map; {ingress-flow|egress-flow} for ip class-map |
    ...    | flow_index | Flow index 1-8 |
    ...    | rule_index | Rule index 1-16 |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    | dprov_class_map | eutA | l2classmap | ethernet | flow | 1 | rule=1 |
    ...    | dprov_class_map | eutA | l3classmap | ip | ingress-flow=1 |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    cli    ${device}    class-map ${class_map_type} ${class_map_name}
    run keyword if    '${EMPTY}'!='${flow_type}'    Axos Cli With Error Check    ${device}    ${flow_type} ${flow_index}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    Axos Cli With Error Check    ${device}    no ${cmd_string}
    [Teardown]    cli    ${device}    end

prov_policy_map
    [Arguments]    ${device}    ${policy_map_name}    ${class_map_type}    ${class_map_name}    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description: provision policy-map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | policy_map_name | name for policy-map |
    ...    | class_map_type | type for class-map, {class-map-ethernet|class-map-ip} |
    ...    | class_map_name | name for class-map |
    ...    | sub_view_type | {flow} for ethernet class-map; {ingress-flow|egress-flow|ingress|egress} for ip class-map |
    ...    | sub_view_value | flow index, or shaper |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    | prov_policy_map | eutA | l2policymap | class-map-ethernet | l2classmap | flow | 1 | remove-cevlan=${EMPTY} | add-ctag=200 |
    ...    | prov_policy_map | eutA | l2policymap2 | class-map-ethernet | l2classmap2 | translate-cevlan-tag=100 | set-cevlan-pcp=3 | add-ctag=200 |
    ...    | prov_policy_map | eutA | l3policymap | class-map-ip | l3classmap | egress-flow | 2 | set-dscp-value=0x00 |
    ...    | prov_policy_map | eutA | l3policymap2 | class-map-ip | l3classmap2 | egress | shaper | maximum=100 |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    cli    ${device}    policy-map ${policy_map_name}
    Axos Cli With Error Check    ${device}    ${class_map_type} ${class_map_name}
    run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

dprov_policy_map
    [Arguments]    ${device}    ${policy_map_name}    ${class_map_type}=${EMPTY}    ${class_map_name}=${EMPTY}    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description:  deprovision policy-map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | policy_map_name | name for policy-map |
    ...    | class_map_type | type for class-map, {class-map-ethernet|class-map-ip} |
    ...    | class_map_name | name for class-map |
    ...    | sub_view_type | {flow} for ethernet class-map; {ingress-flow|egress-flow|ingress|egress} for ip class-map |
    ...    | sub_view_value | flow index, or shaper |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    | dprov_policy_map | eutA | l2policymap | class-map-ethernet | l2classmap | flow | 1 | remove-cevlan=${EMPTY} | add-ctag=200 |
    ...    | dprov_policy_map | eutA | l2policymap | class-map-ethernet | l2classmap2 | flow=2 |
    ...    | dprov_policy_map | eutA | l2policymap | class-map-ethernet=l2classmap |
    ...    | dprov_policy_map | eutA | l3policymap | class-map-ip | l3classmap2 | egress | shaper | maximum=100 |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    cli    ${device}    policy-map ${policy_map_name}
    run keyword if    '${EMPTY}'!='${class_map_type}'    Axos Cli With Error Check    ${device}    ${class_map_type} ${class_map_name}
    run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    Axos Cli With Error Check    ${device}    no ${cmd_string}
    [Teardown]    cli    ${device}    end

prov_transport_service_profile
    [Arguments]    ${device}    ${transport-service-profile}    ${vlan-list}
    [Documentation]    Puts an interface in shutdown mode
     ...
     ...    Arguments:
     ...    | =Argument Name= | \ =Argument Value= \ |
     ...    | device | device name setting in your yaml |
     ...    | transport-service-profile | transport-service-profile name |
     ...    | vlan-list |vlan list attached to transport-service-profile |
     ...    | dict_cmd | dictionary type command, format as cli_key=cli_value |
     ...
     ...    Example:
     ...    | prov_transport_service_profile | AXOS | blair | 600-700 |
     [Tags]    @author=BlairWang
     Axos Cli With Error Check    ${device}    configure
     Axos Cli With Error Check    ${device}    transport-service-profile ${transport-service-profile}
     Axos Cli With Error Check    ${device}    vlan-list ${vlan-list}
     [Teardown]    Axos Cli With Error Check    ${device}    end

dprov_transport_service_profile
    [Arguments]    ${device}    ${transport-service-profile}    ${vlan-list}=${EMPTY}    ${timeout}=300
    [Documentation]    Puts an interface in shutdown mode
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
     ...    | device | device name setting in your yaml |
     ...    | transport-service-profile | transport-service-profile name |
     ...    | vlan-list |vlan list attached to transport-service-profile |
     ...    | dict_cmd | dictionary type command, format as cli_key=cli_value |
     ...
     ...    Example:
     ...    | dprov_transport_service_profile | AXOS | blair | 600 |
     [Tags]    @author=BlairWang
     Axos Cli With Error Check    ${device}    configure
     Axos Cli With Error Check    ${device}    transport-service-profile ${transport-service-profile}
     Axos Cli With Error Check    ${device}    no vlan-list ${vlan-list}     ${timeout}
     [Teardown]    Axos Cli With Error Check    ${device}    end

prov_ont
    [Arguments]    ${device}    ${ont_id}    ${profile_id}=${EMPTY}    ${vendor_id}=${EMPTY}    ${serial_number}=${EMPTY}    ${reg_id}=${EMPTY}
    ...    &{dict_cmd}
    [Documentation]    provision ont
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    | profile_id | profile id |
    ...    | vendor_id | CXNK |
    ...    | serial_number | serial number |
    ...    | reg_id | reg id |
    ...    | dict_cmd | more option |
    ...    Example:
    ...    | prov_ont | n1 | 100 | 811NG | CXNK | 384CC8 |
    [Tags]    @author=AnneLi
    ${cmd_str}    Set Variable    ont ${ont_id}
    ${cmd_str}    Set Variable If    '${profile_id}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} profile-id ${profile_id}
    ${cmd_str}    Set Variable If    '${vendor_id}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} vendor-id ${vendor_id}
    ${cmd_str}    Set Variable If    '${serial_number}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} serial-number ${serial_number}
    ${cmd_str}    Set Variable If    '${reg_id}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} reg-id ${reg_id}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${cmd_str}
    ${cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end

dprov_ont
    [Arguments]    ${device}    ${ont_id}    @{cmd_list}
    [Documentation]    deprovision ont
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    | dict_cmd | more option |
    ...    Example:
    ...    | prov_ont | n1 | 100 | profile-id | serial-number |
    [Tags]    @author=AnneLi
    cli    ${device}    configure
    cli    ${device}    ont ${ont_id}
    ${cmd_str}    Set Variable    ${EMPTY}
    : FOR    ${element}    IN    @{cmd_list}
    \    ${cmd_str}    set variable    no ${element}
    \    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end

check_ont_linkage
    [Arguments]    ${device}    ${ont_id}    ${status}=${EMPTY}    ${linked_by}=${EMPTY}
    [Documentation]    show ont 1 linkage
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    | status | Confirmed or others |
    ...    | linked_by | Serial-Number, reg-id |
    ...    Example:
    ...    | check_ont_linkage | n1 | Confirmed | Serial-Number |
    ...    | check_ont_linkage | n1 | linked_by=Serial-Number |
    [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show ont ${ont_id} linkage
    ${res1}    Get Lines Containing String    ${result}    status
    ${res2}    Get Lines Containing String    ${result}    linked-by
    run keyword if    '${status}'!='${EMPTY}'    Should contain    ${res1}    ${status}
    run keyword if    '${status}'!='${EMPTY}'    Should contain    ${res2}    ${linked_by}

check_ont_status
    [Arguments]    ${device}    ${ont_id}    &{dict}
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
    ${result}    CLI    ${device}    show ont ${ont_id} status
    @{list_key}    Get Dictionary Keys    ${dict}
    : FOR    ${key}    IN    @{list_key}
    \    ${value}    Get From Dictionary    ${dict}    ${key}
    \    ${res1}    Get Lines Containing String    ${result}    ${key}
    \    Should contain    ${res1}    ${value}
      [Return]    ${result}

delete_config_object
    [Arguments]    ${device}    ${obj_type}    ${obj_name}
    [Documentation]    Delete service profile in config view
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value |
    ...    | obj_type | config object type |
    ...    | obj_name | config object name |
    ...
    ...    Example:
    ...    | delete_config_object | eutA | vlan | 600 |
    ...    | delete_config_object | eutA | class-map | ethernet l2classmap |
    [Tags]    @author=BlairWang
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    no ${obj_type} ${obj_name}
    [Teardown]    cli    ${device}    end

prov_ont_profile
    [Arguments]    ${device}    ${ont-profile}    ${interface_type}=${EMPTY}    ${interface_name}=${EMPTY}    &{dict_cmd}
    [Documentation]   provision ont profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont-profile | ont profile name |
    ...    | interface_type | interface type |
    ...    | interface_name | interface name |
    ...
    ...    Example:
    ...    | prov_ont_profile | AXOS | 811NG | ont-ethernet | x1 |
    ...    | prov_ont_profile | AXOS | 811NG | ont-ethernet | x1 | role=uni |
    [Tags]    @author=BlairWang
    cli    ${device}    configure
    cli    ${device}    ont-profile ${ont-profile}
    run keyword if      "${interface_type}"!="${EMPTY}"    cli    ${device}    interface ${interface_type} ${interface_name}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

dprov_ont_profile
    [Arguments]    ${device}    ${ont-profile}    ${interface_type}=${EMPTY}    ${interface_value}=${EMPTY}    @{list_cmd}
    [Documentation]   deprovision ont profile
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont-profile | ont profile name |
    ...    | interface_type | interface type |
    ...    | interface_value | interface name |
    ...
    ...    Example:
    ...    | dprov_ont_profile | AXOS | 811NG | interface | vendor-id |
    ...    | dprov_ont_profile | AXOS | 811NG | ont-ethernet | x1 |
    [Tags]    @author=BlairWang
    cli    ${device}    configure
    cli    ${device}    ont-profile ${ont-profile}
    run keyword if      "${interface_type}"!="${EMPTY}"    cli    ${device}    no interface ${interface_type} ${interface_value}
    : FOR    ${element}    IN    @{list_cmd}
    \    Axos Cli With Error Check    ${device}    no ${element}
    [Teardown]    cli    ${device}    end

prov_ont_profile_with_port
    [Arguments]    ${device}    ${profile_name}    ${ge}=0    ${xe}=0    ${pots}=0    ${ua}=0
    ...    ${rf}=0    ${rg}=0    ${fb}=0    ${role}=uni   ${alarm}=ENABLED
    [Documentation]   provision ont profile with port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | profile_name | ont profile name |
    ...    | ge | ge port number, default=0 |
    ...    | xe | xe port number, default=0 |
    ...    | pots | pots port number, default=0 |
    ...    | ua | ont-ua port number, default=0 |
    ...    | rf | rf-video port number, default=0 |
    ...    | rg | rg port number, default=0 |
    ...    | fb | full bridge port number, default=0 |
    ...    | role | {uni|rg}, interface ont-ethernet role, default=uni |
    ...    | alarm | {ENABLED|DISABLED}, interface ont-ethernet alarm-suppression, default=ENABLED |
    ...
    ...    Example:
    ...    | prov_ont_profile_with_port | eutA | 854G | ge=4 | pots=2 | ua=3 | rf=1 | rg=1 |
    ...    | prov_ont_profile_with_port | eutA | test | xe=1 | rg=1 |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ont-profile ${profile_name}
    log    add ge port
    : FOR    ${index}    IN RANGE    1    ${ge}+1
    \    Axos Cli With Error Check    ${device}    interface ont-ethernet g${index}
    \    Axos Cli With Error Check    ${device}    alarm-suppression ${alarm}
    \    Axos Cli With Error Check    ${device}    role ${role}
    log    add xe port
    : FOR    ${index}    IN RANGE    1    ${xe}+1
    \    Axos Cli With Error Check    ${device}    interface ont-ethernet x${index}
    \    Axos Cli With Error Check    ${device}    alarm-suppression ${alarm}
    \    Axos Cli With Error Check    ${device}    role ${role}
    log    add RG port
    : FOR    ${index}    IN RANGE    1    ${rg}+1
    \    Axos Cli With Error Check    ${device}    interface rg G${index}
    log    add pots port
    : FOR    ${index}    IN RANGE    1    ${pots}+1
    \    Axos Cli With Error Check    ${device}    interface pots p${index}
    log    add ont-ua port
    : FOR    ${index}    IN RANGE    1    ${ua}+1
    \    Axos Cli With Error Check    ${device}    interface ont-ua ${index}
    log    add rf port
    : FOR    ${index}    IN RANGE    1    ${rf}+1
    \    Axos Cli With Error Check    ${device}    interface rf-video r${index}
    log    add full bridge port
    : FOR    ${index}    IN RANGE    1    ${fb}+1
    \    Axos Cli With Error Check    ${device}    interface full-bridge F${index}
    [Teardown]    cli    ${device}    end

check_ont_profile_parameter
    [Arguments]    ${device}    ${profile_name}    ${ge}=0    ${xe}=0    ${pots}=0    ${ua}=0
    ...    ${rf}=0    ${rg}=0    ${fb}=0    ${role}=uni   ${alarm}=ENABLED
    [Documentation]   check ont profile parameter
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | profile_name | ont profile name |
    ...    | ge | ge port number, default=0 |
    ...    | xe | xe port number, default=0 |
    ...    | pots | pots port number, default=0 |
    ...    | ua | ont-ua port number, default=0 |
    ...    | rf | rf-video port number, default=0 |
    ...    | rg | rg port number, default=0 |
    ...    | fb | full bridge port number, default=0 |
    ...    | role | {uni|rg}, interface ont-ethernet role, default=uni |
    ...    | alarm | {ENABLED|DISABLED}, interface ont-ethernet alarm-suppression, default=ENABLED |
    ...
    ...    Example:
    ...    | check_ont_profile_parameter | eutA | 854G | ge=4 | pots=2 | ua=3 | rf=1 | rg=1 |
    ...    | check_ont_profile_parameter | eutA | test | xe=1 | rg=1 |
    [Tags]    @author=CindyGao
    ${res}    Axos Cli With Error Check    ${device}    show running-config ont-profile ${profile_name} | detail
    log    check ge port
    : FOR    ${index}    IN RANGE    1    ${ge}+1
    \    Should Match Regexp    ${res}    (?i)interface\\s+ont-ethernet\\s+g${index}[\\r\\n]\\s+alarm-suppression\\s+${alarm}[\\r\\n]\\s+role\\s+${role}
    log    check xe port
    : FOR    ${index}    IN RANGE    1    ${xe}+1
    \    Should Match Regexp    ${res}    (?i)interface\\s+ont-ethernet\\s+x${index}[\\r\\n]\\s+alarm-suppression\\s+${alarm}[\\r\\n]\\s+role\\s+${role}
    log    check RG port
    : FOR    ${index}    IN RANGE    1    ${rg}+1
    \    Should Match Regexp    ${res}    interface\\s+rg\\s+G${index}
    log    check pots port
    : FOR    ${index}    IN RANGE    1    ${pots}+1
    \    Should Match Regexp    ${res}    interface\\s+pots\\s+p${index}
    log    check ont-ua port
    : FOR    ${index}    IN RANGE    1    ${ua}+1
    \    Should Match Regexp    ${res}    interface\\s+ont-ua\\s+${index}
    log    check rf port
    : FOR    ${index}    IN RANGE    1    ${rf}+1
    \    Should Match Regexp    ${res}    interface\\s+rf-video\\s+r${index}
    log    check full bridge port
    : FOR    ${index}    IN RANGE    1    ${fb}+1
    \    Should Match Regexp    ${res}    interface\\s+full-bridge\\s+F${index}

prov_dhcp_profile
    [Arguments]    ${device}    ${profile_name}    ${option}=${EMPTY}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    l2-dhcp-profile ${profile_name}
    run keyword if    "${option}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    ${option}
    [Teardown]    Axos Cli With Error Check    ${device}    end

check_l3_hosts
    [Arguments]    ${device}    ${num}=${EMPTY}    ${vlan}=${EMPTY}    ${interface}=${EMPTY}   ${ivlan}=${EMPTY}    ${ip}=${EMPTY}    &{dict_check}
    [Documentation]   check vlan and interface infos for dhcp lease
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | num | lease numbers |
    ...    | vlan | ip vlan |
    ...    | interface |interface name |
    ...
    ...    Example:
    ...    | check_dhcp_leases | AXOS | 2 | 53 |
    [Tags]    @author=BlairWang
    # [AT-3357] added by CindyGao for 35b adapt, start
    ${res}    cli    ${device}    show l3-hosts
    ${contain_num}      Run Keyword And Return Status    Should Contain    ${res}    total-dhcpv4-leases
    run keyword if    ${contain_num} and ("${num}"!="${EMPTY}")    should match regexp    ${res}    total-dhcpv4-leases\\s+${num}
    run keyword if    "${vlan}"!="${EMPTY}"    should match regexp    ${res}    l3-host\\s+${vlan}\\s+
    run keyword if    "${ip}"!="${EMPTY}"    should match regexp    ${res}    l3-host\\s+\\d+\\s+${ip}\\s+
    run keyword if    "${ivlan}"!="${EMPTY}"    should match regexp    ${res}    inner-vlan\\s+${ivlan}\\s+
    run keyword if    "${interface}"!="${EMPTY}"    should match regexp    ${res}    interface\\s+${interface}\\s+
    # [AT-3357] added by CindyGao for 35b adapt, end
    @{check_name}    Get Dictionary Keys    ${dict_check}
    : FOR    ${key}   IN    @{check_name}
    \    ${res1}     Get Lines Containing String    ${res}    ${key}
    \    ${check_value}    Get From Dictionary    ${dict_check}   ${key}
    \    should contain    ${res1}    ${check_value}
    [Return]    ${res}

get_l3_host_ip
    [Arguments]    ${device}    ${vlan}    ${interface}   ${ivlan}=${EMPTY}
    [Documentation]   check vlan and interface infos for dhcp lease
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | ip vlan |
    ...    | interface |interface name |
    ...    | ivlan | inner vlan, default=${EMPTY} |
    ...
    ...    Example:
    ...    | ${wan_ip} | get_l3_hosts_ip | eutA | 100 | 844/G1 |
    [Tags]    @author=CindyGao
    ${res}    cli    ${device}    show l3-hosts
    ${pattern}    set variable    (?s)l3-host\\s+${vlan}\\s+(\\S+)\\s+.*?\\s+interface\\s+${interface}\\s+
    ${match}    ${ip}    Should Match Regexp    ${res}    ${pattern}
    [Return]    ${ip}

prov_igmp_profile
    [Arguments]    ${device}    ${igmp-profile-name}    ${igmp-version}=${EMPTY}    &{dict_cmd}
    [Documentation]    provision igmp-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | igmp-profile-name | igmp-profile name |
    ...    | igmp-version|v2 v3 auto |
    ...    | dict_cmd | more option |
    ...    Example:
    ...    | prov_igmp_profile | n1 | anne|v2 |
    ...    | prov_igmp_profile | n1 | anne|general-query-interval=100 |
    [Tags]    @author=AnneLi
    ${cmd_str}    Set Variable    igmp-profile ${igmp-profile-name}
    ${cmd_str}    Set Variable If    '${igmp-version}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} igmp-version ${igmp-version}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${cmd_str}
    ${cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end

dprov_igmp_profile
    [Arguments]    ${device}    ${igmp-profile-name}    @{cmd_list}
    [Documentation]    deprovision igmp-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | igmp-profile-name | igmp-profile name |
    ...    | dict_cmd | more option |
    ...    Example:
    ...    | dprov_igmp_profile | n1 | anne | igmp-version |
    [Tags]    @author=AnneLi
    cli    ${device}    configure
    cli    ${device}    igmp-profile ${igmp-profile-name}
    ${cmd_string}    Set Variable    ${EMPTY}
    : FOR    ${element}    IN    @{cmd_list}
    \    ${cmd_string}    set variable    no ${element}
    \    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

prov_multicast_profile
    [Arguments]    ${device}    ${multicast-profile-name}     ${mvr-profile}=${EMPTY}     ${max-streams}=${EMPTY}    &{dict_cmd}
    [Documentation]    provision multicast-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | multicast-profile-name | multicast-profile name |
    ...    | max-streams | max-streams |
    ...    | mvr-profile | mvr-profile |
    ...    | dict_cmd | more option |
    ...    Example:
    ...    | prov_multicast_profile | n1 | anne | anne |
    ...    | prov_multicast_profile | n1 | anne | max-streams=10 |
    [Tags]    @author=AnneLi
    ${cmd_str}    Set Variable    multicast-profile ${multicast-profile-name}
    ${cmd_str}    Set Variable If    '${max-streams}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} max-streams ${max-streams}
    ${cmd_str}    Set Variable If    '${mvr-profile}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} mvr-profile ${mvr-profile}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${cmd_str}
    ${cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end

dprov_multicast_profile
    [Arguments]    ${device}    ${multicast-profile-name}    @{cmd_list}
    [Documentation]    deprovision multicast-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | igmp-profile-name | igmp-profile name |
    ...    | cmd_list | more option |
    ...    Example:
    ...    | dprov_multicast_profile | n1 | anne | max-streams |
    [Tags]    @author=AnneLi
    cli    ${device}    configure
    cli    ${device}    multicast-profile ${multicast-profile-name}
    ${cmd_string}    Set Variable    ${EMPTY}
    : FOR    ${element}    IN    @{cmd_list}
    \    ${cmd_string}    set variable    no ${element}
    \    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

prov_mvr_profile
    [Arguments]    ${device}    ${mvr-profile-name}    ${start-address}=${EMPTY}      ${end-address}=${EMPTY}      ${vlan-id}=${EMPTY}
    [Documentation]    provision mvr-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | mvr-profile-name | mvr-profile name |
    ...    | start-address | start ip address |
    ...    | end-address | end ip address |
    ...    | vlan-id | vlan id |
    ...    Example:
    ...    | prov_mvr_profile | n1 | anne | 225.0.0.1 | 225.0.0.10 | 100 |
    [Tags]    @author=AnneLi

    ${cmd_string}    Set Variable    mvr-profile ${mvr-profile-name}
    ${cmd_string}    Set Variable If    '${start-address}'=='${EMPTY}'    ${cmd_string}    ${cmd_string} address ${start-address} ${end-address} ${vlan-id}
    cli    ${device}    configure
    ${res}    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Return]    ${res}
    [Teardown]    cli    ${device}    end

dprov_mvr_profile
    [Arguments]    ${device}    ${mvr-profile-name}    ${start-address}      ${end-address}      ${vlan-id}
    [Documentation]    deprovision mvr-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | mvr-profile-name | mvr-profile name |
    ...    | start-address | start ip address |
    ...    | end-address | end ip address |
    ...    | vlan-id | vlan id |
    ...    Example:
    ...    | drov_mvr_profile | n1 | anne | 225.0.0.1 | 225.0.0.10 | 100 |
    [Tags]    @author=AnneLi
    cli    ${device}    configure
    cli    ${device}    mvr-profile ${mvr-profile-name}
    Axos Cli With Error Check    ${device}    no address ${start-address} ${end-address} ${vlan-id}
    # ${cmd_string}    Set Variable      ${EMPTY}
    # ${cmd_string}    Set Variable If    '${start-address}'=='${EMPTY}'    ${cmd_string}    ${cmd_string} address ${start-address} ${end-address} ${vlan-id}
    # run keyword if    '${cmd_string}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    no ${cmd_string}
    [Teardown]    cli    ${device}    end

check_igmp_multicast_group_summary
    [Arguments]    ${device}    ${group}    ${domain}=${EMPTY}    ${interface}=${EMPTY}    ${contain}=yes
    [Documentation]    show igmp multicast group summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | group | group ip address |
    ...    | domain | vlan id |
    ...    | interface | port id |
    ...    Example:
    ...    | check_igmp_multicast_group_summary | eutA | 225.0.0.1 | 100 | 1/1/xp2 |
    ...    | check_igmp_multicast_group_summary | eutA | 225.0.0.1 | 100 |
    ...    | check_igmp_multicast_group_summary | eutA | 225.0.0.1 | contain=no |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp multicast group summary
    ${pattern}    set variable    ${group}\\s*${domain}\\s*.*${interface}
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

check_igmp_multicast_group_not_contain
    [Arguments]    ${device}    ${group}    ${domain}=${EMPTY}    ${interface}=${EMPTY}
    [Documentation]    show igmp multicast group summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | group | group ip address |
    ...    | domain | vlan id |
    ...    | interface | port id |
    ...    Example:
    ...    | check_igmp_multicast_group_not_contain | eutA | 225.0.0.1 | 100 | 1/1/xp2 |
    ...    | check_igmp_multicast_group_not_contain | eutA | 225.0.0.1 | 100 |
    ...    | check_igmp_multicast_group_not_contain | eutA | 225.0.0.1 |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp multicast group summary
    should not match regexp    ${result}    ${group}\\s*${domain}\\s*.*${interface}

check_igmp_multicast_group_ip
    [Arguments]    ${device}    ${ip}    ${domain}=${EMPTY}    ${interface}=${EMPTY}    ${contain}=yes
    [Documentation]    show igmp multicast group ip ${ip}
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | group | group ip address |
    ...    | domain | vlan id |
    ...    | interface | port id |
    ...    Example:
    ...    | check_igmp_multicast_group_ip | eutA | 225.0.0.1 | 100 | 1/1/xp2 |
    ...    | check_igmp_multicast_group_ip | eutA | 225.0.0.1 | 100 |
    ...    | check_igmp_multicast_group_ip | eutA | 225.0.0.1 | contain=no |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp multicast group ip ${ip}
    ${pattern}    set variable    ${ip}\\s+${domain}\\s+${interface}
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

check_igmp_multicast_vlan
    [Arguments]    ${device}    ${svlan}    ${interface}    ${shelf}=\\d+    ${slot}=\\d+    ${contain}=yes    &{dict_group_vlan}
    [Documentation]    show igmp multicast vlan ${svlan}
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | svlan | service vlan to check |
    ...    | interface | interface name |
    ...    | shelf | shelf number, default=0 |
    ...    | slot | slot number, default=0 |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    | dict_group_vlan | dictionary type mc group and video vlan pair, format as mc_group=video_vlan |
    ...    Example:
    ...    | check_igmp_multicast_vlan | eutA | 100 | ont/x1 | 225.1.1.1=${video_vlan} | 225.1.1.2=${video_vlan2} |
    ...    | check_igmp_multicast_vlan | eutA | 100 | xp1 | 1 | 1 | 225.1.1.1=${video_vlan} |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp multicast vlan ${svlan}
    ${result_string}    set variable    ${EMPTY}
    @{list_key_mc_grp}    Get Dictionary Keys    ${dict_group_vlan}
    : FOR    ${mc_grp}   IN    @{list_key_mc_grp}
    \    ${video_vlan}    Get From Dictionary    ${dict_group_vlan}   ${mc_grp}
    \    ${result_string}    set variable    ${result_string}\\s*${mc_grp}\\s*${video_vlan}.*\\r\\n
    ${pattern}    set variable    ${shelf}\\s*${slot}\\s+.*${interface}\\s*${result_string}
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

check_igmp_multicast_sum
    [Arguments]    ${device}    ${svlan}    ${interface}    ${shelf}    ${slot}    ${mc_group}    ${video_vlan}
    ...    ${total_stream}=(\\d+)    ${user}=(\\d+)    ${contain}=yes
    [Documentation]    show igmp multicast vlan summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | svlan | service vlan to check |
    ...    | interface | interface name |
    ...    | shelf | shelf number, default=0 |
    ...    | slot | slot number, default=0 |
    ...    | mc_group | multicast group |
    ...    | video_vlan | video source vlan |
    ...    | user | users number, default=(\\d+) |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    Example:
    ...    | check_igmp_multicast_sum | eutA | 100 | ont/x1 | 0 | 0 | 225.1.1.1 | ${video_vlan} | 
    ...    | check_igmp_multicast_sum | eutA | 100 | xp1 | 1 | 1 | 225.1.1.1 | ${video_vlan} |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp multicast summary
    ${pattern}    set variable    (?is)${svlan}\\s+${total_stream}\\s+.*?\\s+${shelf}\\s+${slot}\\s+.*${interface}\\s+[^a-zA-z]*?\\s+${mc_group}\\s+${video_vlan}\\s+${user}
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

check_igmp_routers
    [Arguments]    ${device}    ${query_cmd}    ${vlan}=\\d+    ${interface}=.+    ${source_ip}=.+    ${querier_ip}=.+
    ...    ${version}=V2    ${type}=.+    ${contain}=yes    ${shelf}=\\d+    ${slot}=\\d+
    [Documentation]   check infos for "show igmp routers ${query_cmd}" command
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | query_cmd | command key for "show igmp routers ${query_cmd}" command |
    ...    | vlan | igmp router vlan |
    ...    | interface | igmp router interface name, format as 1/1/x1 or erps-1 |
    ...    | source_ip | igmp router source ip address |
    ...    | querier_ip | igmp router querier ip address |
    ...    | version | igmp version, default=V2 |
    ...    | type | igmp router management status, [LEARNED|STATIC] |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...
    ...    Example:
    ...    | check_igmp_routers | eutA | summary | 53 | 1/1/x1 | 53.53.53.53 |
    ...    | check_igmp_routers | eutA | summary | 700 | 1/1/x1 | querier_ip=${p_igmp_querier_ip} |
    ...    | check_igmp_routers | eutA | vlan 700 | interface=1/1/x1 | source_ip=${p_proxy_ip} | querier_ip=${p_igmp_querier_ip} |
    ...    | check_igmp_routers | eutA | summary | 700 |
    ...    | check_igmp_routers | eutA | summary | 700 | erps-1 |
    ...    
    [Tags]    @author=CindyGao
    # # special operation for match interface name
    # ${match_intf}    set variable    .+
    # @{list_intf_item}    run keyword if    "${EMPTY}"!="${interface}"    Split String    ${interface}    /  
    # : FOR    ${item}    IN    @{list_intf_item}
    # \    ${match_intf}    set variable    ${match_intf}\\s*${item}\\s+
    
    ${result}    Axos Cli With Error Check    ${device}    show igmp routers ${query_cmd}
    ${pattern}    set variable    (?i)${vlan}\\s+${shelf}\\s+${slot}\\s+.*${interface}\\s+${type}\\s+${version}\\s+${source_ip}\\s+${querier_ip}
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

get_shelf_slot_interface_info   
    [Arguments]    ${interface_name}    ${interface_type}
    [Documentation]    Description: get subscriber port type
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | interface_name | interface name |
    ...    | interface_type | interface type |
    ...
    ...    Example:
    ...    | &{dict_intf} | get_shelf_slot_interface_info | 11/g1 | ont-ethernet |
    ...    | &{dict_intf} | get_shelf_slot_interface_info | 1/1/x1 | ethernet |
    ...    Then you can use &{dict_intf}[shelf], &{dict_intf}[slot], &{dict_intf}[port] to get shelf, slot, port info
    [Tags]    @author=CindyGao    @jira=AT-5296    @jira=AT-5519    @jira=AT-5677
    # Modify for AT-5296 by cgao, modify for check igmp port format change
    ${intf}    Set Variable If    "erps"=="${interface_type}"    erps-${interface_name}
    ...    "g8032"=="${interface_type}"    g.8032-${interface_name}
    ...    ${interface_name}
   
    &{dict_intf}    create dictionary    shelf=\\d+    slot=\\d+    port=${intf}
    # Modify for AT-5519, AT-5677 by cgao, list no need to split interface type here
    @{not_split_type}    create list    ont-ethernet    rg    erps    g8032    lag
    Return From Keyword If    '${interface_type}' in @{not_split_type}    &{dict_intf}
    # Modify for AT-5519, AT-5677 end
    # Modify for AT-5296, end
    
    ${result}    Get Regexp Matches    ${interface_name}    ([A-Za-z0-9]+)[\/]([0-9.]+)[\/]([A-Za-z0-9]+)    1    2   3
    Set To Dictionary    ${dict_intf}    shelf=${result[0][0]}
    Set To Dictionary    ${dict_intf}    slot=${result[0][1]}
    Set To Dictionary    ${dict_intf}    port=${result[0][2]}
    log    interface ${interface_type} ${interface_name} get shelf:&{dict_intf}[shelf] slot:&{dict_intf}[slot] port:&{dict_intf}[port]
    [Return]    &{dict_intf}

check_igmp_ports_summary
    [Arguments]    ${device}    ${vlan}    ${interface}    ${shelf}=\\d+    ${slot}=\\d+    ${version}=([A-Z0-9]+)    ${src_ip}=([0-9.]+)
    ...    ${mode}=([A-Z]+)    ${mgmt_status}=([A-Z]+)    ${oper_state}=([A-Z]+)    ${mcast_prf}=([\\w-]+)    ${contain}=yes
    [Documentation]   check infos for "show igmp ports summary" command
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | igmp service vlan |
    ...    | interface | interface name |
    ...    | shelf | shelf number, default=0 |
    ...    | slot | slot number, default=0 |
    ...    | version | igmp version, default=([A-Z0-9]+) |
    ...    | src_ip | igmp router source ip address, default=([0-9.]+) |
    ...    | mode | igmp mode, [HOST|ROUTER], default=([A-Z]+) |
    ...    | mgmt_status | management status, [STATIC|LEARNED], default=([A-Z]+) |
    ...    | oper_state | operational state, [UP|DOWN], default=([A-Z]+) |
    ...    | mcast_prf | multicast profile, default=([\\w-]+) |    
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...
    ...    Example:
    ...    | check_igmp_ports_summary | eutA | 400 | 801/x1 | version=v2 | src_ip=10.10.10.10 | 
    ...    | check_igmp_ports_summary | eutA | 400 | 801/x1 | 0 | 0 | v2 | 10.10.10.10 | HOST | STATIC | UP | ${p_mcast_prf} |
    ...    | check_igmp_ports_summary | eutA | 400 | 801/x1 | version=v2 | src_ip=10.10.10.10 | mode=HOST | mcast_prf=${p_mcast_prf} |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp ports summary
    ${pattern}    set variable
    ...    (?is)${vlan}.*?\\s+${shelf}\\s+${slot}\\s+.*${interface}\\s+${mode}\\s+${mgmt_status}\\s+${version}\\s+${src_ip}\\s+${oper_state}\\s+${mcast_prf}\\s+
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

check_igmp_ports_vlan
    [Arguments]    ${device}    ${vlan}    ${interface}    ${shelf}=\\d+    ${slot}=\\d+    ${version}=([A-Z0-9]+)    ${src_ip}=([0-9.]+)
    ...    ${mode}=([A-Z]+)    ${mgmt_status}=([A-Z]+)    ${oper_state}=([A-Z]+)    ${mcast_prf}=([\\w-]+)
    ...    ${mvr_prf}=([\\w-]+)    ${mvr_start_ip}=([0-9.]*)    ${mvr_end_ip}=([0-9.]*)    ${mvr_vlan}=(\\d*)    ${contain}=yes
    [Documentation]   check infos for "show igmp ports summary" command
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | igmp service vlan |
    ...    | interface | interface name |
    ...    | shelf | shelf number, default=0 |
    ...    | slot | slot number, default=0 |
    ...    | version | igmp version, default=([A-Z0-9]+) |
    ...    | src_ip | igmp router source ip address, default=([0-9.]+) |
    ...    | mode | igmp mode, [HOST|ROUTER], default=([A-Z]+) |
    ...    | mgmt_status | management status, [STATIC|LEARNED], default=([A-Z]+) |
    ...    | oper_state | operational state, [UP|DOWN], default=([A-Z]+) |
    ...    | mcast_prf | multicast profile, default=([\\w-]+) |    
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...
    ...    Example:
    ...    | check_igmp_ports_vlan | eutA | 400 | 801/x1 | version=v2 | src_ip=10.10.10.10 | 
    ...    | check_igmp_ports_vlan | eutA | 400 | 801/x1 | 0 | 0 | v2 | 10.10.10.10 | HOST | STATIC | UP | ${p_mcast_prf} |
    ...    | check_igmp_ports_vlan | eutA | 400 | 801/x1 | version=v2 | src_ip=10.10.10.10 | mode=HOST | mcast_prf=${p_mcast_prf} |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp ports vlan ${vlan}
    ${pattern}    set variable
    ...    ${vlan}\\s+${shelf}\\s+${slot}\\s+.*${interface}\\s+${mode}\\s+${mgmt_status}\\s+${version}\\s+${src_ip}\\s+${oper_state}\\s+${mcast_prf}\\s+
    ${pattern}    set variable
    ...    (?is)${pattern}${mvr_prf}\\s+${mvr_start_ip}\\s+${mvr_end_ip}\\s+${mvr_vlan}\\s+
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

check_igmp_hosts_summary
    [Arguments]    ${device}    ${vlan}    ${interface}    ${shelf}=\\d+    ${slot}=\\d+    ${version}=([A-Z0-9]+)    ${src_ip}=([0-9.]+)
    ...    ${mcast_prf}=([\\w-]+)    ${active_stream}=(\\d+)    ${stream_limit}=([\\d-]+)    ${rate_limit}=(\\d+)    ${burst_limit}=(\\d+)
    ...    ${mgmt_status}=([A-Z]+)    ${oper_state}=([A-Z]+)    ${querier_status}=([A-Z]+)    ${contain}=yes
    [Documentation]   check infos for "show igmp hosts summary" command
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | igmp service vlan |
    ...    | interface | interface name |
    ...    | shelf | shelf number, default=0 |
    ...    | slot | slot number, default=0 |
    ...    | version | igmp version, default=([A-Z0-9]+) |
    ...    | src_ip | igmp router source ip address, default=([0-9.]+) |
    ...    | mcast_prf | multicast profile, default=([\\w-]+) |    
    ...    | active_stream | active streams number, default=(\\d+) |
    ...    | stream_limit | stream limit number, default=(\\d+) |
    ...    | rate_limit | rate limit number, default=(\\d+) |
    ...    | burst_limit | burst limit number, default=(\\d+) |
    ...    | mgmt_status | management status, [STATIC|LEARNED], default=([A-Z]+) |
    ...    | oper_state | operational state, [UP|DOWN], default=([A-Z]+) |
    ...    | querier_status | querier state, [Querier|], default=([A-Z]+) |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...
    ...    Example:
    ...    | check_igmp_hosts_summary | eutA | 400 | 801/x1 | version=v2 | src_ip=10.10.10.10 | mcast_prf=${p_mcast_prf} |
    ...    | check_igmp_hosts_summary | eutA | 400 | 801/x1 | 0 | 0 | v2 | 10.10.10.10 | ${p_mcast_prf} | 5 | 16 | 50 | 62 | STATIC | UP | Querier |
    ...    | check_igmp_hosts_summary | eutA | 400 | 801/x1 | src_ip=10.10.10.10 | mcast_prf=${p_mcast_prf} | stream_limit=16 | rate_limit=50 | burst_limit=62 |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp hosts summary
    ${pattern}    set variable
    ...    (?is)${vlan}.*?\\s+${shelf}\\s+${slot}\\s+.*${interface}\\s+${mgmt_status}\\s+${version}\\s+${active_stream}\\s+${stream_limit}\\s+${src_ip}\\s+${querier_status}\\s+${oper_state}\\s+${mcast_prf}\\s+${rate_limit}\\s+${burst_limit}
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

check_igmp_hosts_vlan
    [Arguments]    ${device}    ${vlan}    ${interface}    ${shelf}=\\d+    ${slot}=\\d+    ${version}=([A-Z0-9]+)    ${src_ip}=([0-9.]+)
    ...    ${mcast_prf}=([\\w-]+)    ${active_stream}=(\\d+)    ${stream_limit}=([\\d-]+)    ${rate_limit}=(\\d+)    ${burst_limit}=(\\d+)
    ...    ${mgmt_status}=([A-Z]+)    ${oper_state}=([A-Z]+)    ${querier_status}=([A-Z]+)    ${contain}=yes
    [Documentation]   check infos for "show igmp hosts vlan ${vlan}" command
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | igmp service vlan |
    ...    | interface | interface name |
    ...    | shelf | shelf number, default=0 |
    ...    | slot | slot number, default=0 |
    ...    | version | igmp version, default=([A-Z0-9]+) |
    ...    | src_ip | igmp router source ip address, default=([0-9.]+) |
    ...    | mcast_prf | multicast profile, default=([\\w-]+) |    
    ...    | active_stream | active streams number, default=(\\d+) |
    ...    | stream_limit | stream limit number, default=(\\d+) |
    ...    | rate_limit | rate limit number, default=(\\d+) |
    ...    | burst_limit | burst limit number, default=(\\d+) |
    ...    | mgmt_status | management status, [STATIC|LEARNED], default=([A-Z]+) |
    ...    | oper_state | operational state, [UP|DOWN], default=([A-Z]+) |
    ...    | querier_status | querier state, [Querier|], default=([A-Z]+) |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...
    ...    Example:
    ...    | check_igmp_hosts_summary | eutA | 400 | 801/x1 | version=v2 | src_ip=10.10.10.10 | mcast_prf=${p_mcast_prf} |
    ...    | check_igmp_hosts_summary | eutA | 400 | 801/x1 | 0 | 0 | v2 | 10.10.10.10 | ${p_mcast_prf} | 5 | 16 | 50 | 62 | STATIC | UP | Querier |
    ...    | check_igmp_hosts_summary | eutA | 400 | 801/x1 | src_ip=10.10.10.10 | mcast_prf=${p_mcast_prf} | stream_limit=16 | rate_limit=50 | burst_limit=62 |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp hosts vlan ${vlan}
    ${pattern}    set variable
    ...    (?i)${vlan}\\s+${shelf}\\s+${slot}\\s+.*${interface}\\s+${mgmt_status}\\s+${version}\\s+${active_stream}\\s+${stream_limit}\\s+${src_ip}\\s+${querier_status}\\s+${oper_state}\\s+${mcast_prf}\\s+${rate_limit}\\s+${burst_limit}
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

check_igmp_domains
    [Arguments]    ${device}    ${vlan}    ${igmp_prf}=([\\w-]+)    ${mode}=([A-Z]+)    ${src_ip}=([0-9.]+)
    ...    ${discovery}=([A-Z]+)    ${domain_state}=([A-Z]+)    ${contain}=yes
    [Documentation]   check infos for "show igmp domains" command
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | igmp service vlan |
    ...    | igmp_prf | igmp profile, default=([\\w-]+) |    
    ...    | src_ip | igmp router source ip address, default=([0-9.]+) |
    ...    | mode | igmp mode, [Proxy|], default=([A-Z]+) |
    ...    | discovery | discovery state, [Enabled|Disabled], default=([A-Z]+) |
    ...    | domain_state | domain state, [WAIT|READY], default=([A-Z]+) |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...
    ...    Example:
    ...    | check_igmp_domains | eutA | igmp_non_mvr | src_ip=10.10.10.10 | domain_state=READY |
    [Tags]    @author=CindyGao
    ${result}    CLI    ${device}    show igmp domains
    ${pattern}    set variable    (?i)${vlan}\\s+.*\\s+${igmp_prf}\\s+${mode}\\s+${src_ip}\\s+${discovery}\\s+${domain_state}
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}
    
check_igmp_statistics
    [Arguments]    ${device}    ${type}    ${name}=${EMPTY}    &{dict_check_item}
    [Documentation]    Description: check "show igmp statistics ${type} ${name}" information
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | type | query type, {summary|vlan|interface} |
    ...    | name | vlan or interface name, default=${EMPTY} for summary type |
    ...    | dict_check_item | dictionary type check item, format as check_item=exp_value or check_item=${EMPTY} |
    ...    Example:
    ...    | check_igmp_statistics | eutA | summary | rx-pkts=8 | 
    ...    | check_igmp_statistics | eutA | vlan | 100 | tx-general-queries=10 |
    [Tags]    @author=CindyGao
    ${res}    Axos Cli With Error Check    ${device}    show igmp statistics ${type} ${name}
    @{list_key}    Get Dictionary Keys    ${dict_check_item}
    : FOR    ${check_item}   IN    @{list_key}
    \    ${exp_value}    Get From Dictionary    ${dict_check_item}   ${check_item}
    \    Should Match Regexp    ${res}    ${check_item}\\s+${exp_value}\\s*
    [Return]    ${res}

clear_igmp_statistics
    [Arguments]    ${device}    ${type}    ${name}=${EMPTY}
    [Documentation]    Description: check "clear igmp statistics ${type} ${name}" information
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | type | query type, {all|vlan|interface} |
    ...    | name | vlan or interface name, default=${EMPTY} for summary type |
    ...    Example:
    ...    | clear_igmp_statistics | eutA | summary |
    ...    | clear_igmp_statistics | eutA | vlan | 100 |
    [Tags]    @author=CindyGao
    ${name_str}    Run Keyword If    'vlan'=='${type}'    release_cmd_adapter    ${device}    ${clear_igmp_statistics_vlan}    ${name}
    ...    ELSE    Set Variable    ${name}
    ${res}    Axos Cli With Error Check    ${device}    clear igmp statistics ${type} ${name_str}

prov_g8032_ring
    [Arguments]    ${device}    ${g8032-ring}    ${control-vlan}=${EMPTY}    ${admin-state}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description: provision g8032-ring
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | g8032-ring | G.8032 ring instance id {1-6} |
    ...    | control-vlan | G.8032 ring instance control vlan |
    ...    | admin-state | G.8032 ring instance administration state |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    | prov_g8032_ring | eutA | 1 | 100 | enable |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    cli    ${device}    g8032-ring ${g8032-ring}
    run keyword if     "${control-vlan}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    control-vlan ${control-vlan}
    run keyword if     "${control-vlan}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    admin-state ${admin-state}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

dprov_g8032_ring
    [Arguments]    ${device}    ${g8032-ring}    @{list_cmd}
    [Documentation]    Description: provision g8032-ring
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps-ring id |
    ...    | role | ERPS ring domain node role |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value |
    ...
    ...    Example:
    ...    | dprov_g8032_ring | eutA | 1 | control-vlan |
    ...    | dprov_g8032_ring | eutA | 1 | control-vlan | guard-time | maintenance-entity-level |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    cli    ${device}    g8032-ring ${g8032-ring}
    : FOR    ${cmd}    IN    @{list_cmd}
    \    Axos Cli With Error Check    ${device}    no ${cmd}
    [Teardown]    cli    ${device}    end

prov_erps_ring
    [Arguments]    ${device}    ${erps-ring}    ${role}=${EMPTY}    ${control-vlan}=${EMPTY}    &{dict_cmd}
    [Documentation]    create erps ring
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps-ring id |
    ...    | role | ERPS ring domain node role |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value |
    ...
    ...    Example:
    ...    | pro_erps_ring | AXOS | 1 | transit | 3 |
    ...    | pro_erps_ring | AXOS | 1 | transit | 3 | health-time=2 | recovery-time=2 |
    [Tags]    @author=BlairWang
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    erps-ring ${erps-ring}
    run keyword if     "${role}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    role ${role}
    run keyword if     "${control-vlan}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    control-vlan ${control-vlan}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    Axos Cli With Error Check    ${device}    end

dprov_erps_ring
    [Arguments]    ${device}    ${erps-ring-id}    @{list_cmd}
    [Documentation]    delete erps ring
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps-ring id |
    ...    | role | ERPS ring domain node role |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value |
    ...
    ...    Example:
    ...    | dprov_erps_ring_parameter | AXOS | 1 | role | control-vlan |
    ...    | dprov_erps_ring_parameter | AXOS | 1 | role | control-vlan | health-time | recovery-time |
    [Tags]    @author=BlairWang
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    erps-ring ${erps-ring-id}
    : FOR    ${element}    IN    @{list_cmd}
    \    Axos Cli With Error Check    ${device}    no ${element}
    [Teardown]    Axos Cli With Error Check    ${device}    end

prov_erps_ring_on_interface
    [Arguments]    ${device}    ${interface}    ${erps-ring-id}    ${erps-ring-role}
    [Documentation]    delete erps ring
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | interface | interface ethernet |
    ...    | erps-ring-id | erps-ring-id |
    ...    | erps-ring-role | erps-ring-role of ethernet port |
    ...
    ...    Example:
    ...    | dprov_erps_ring_parameter | AXOS | 1 | role | control-vlan |
    ...    | dprov_erps_ring_parameter | AXOS | 1 | role | control-vlan | health-time | recovery-time |
    [Tags]    @author=BlairWang
    prov_interface_ethernet    ${device}    ${interface}    inni    erps-ring=${erps-ring-id}    role=${erps-ring-role}

check_erps_ring_configuration
    [Arguments]    ${device}    ${erps-ring}   &{dict_check}
    [Documentation]   check vlan and interface infos for dhcp lease
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | dict_check | input dictionary |
    ...
    ...    Example:
    ...    | check_erps_ring_configuration | AXOS | 1 | admin-state=disable | control-vlan=3 |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show erps-ring ${erps-ring} configuration
    @{check_name}    Get Dictionary Keys    ${dict_check}
    : FOR    ${key}   IN    @{check_name}
    \    ${res1}    Get Lines Containing String    ${res}    ${key}
    \    ${check_value}    Get From Dictionary    ${dict_check}   ${key}
    \    should contain     ${res1}    ${check_value}

check_erps_ring_counters
    [Arguments]    ${device}    ${erps-ring}   &{dict_check}
    [Documentation]   check vlan and interface infos for dhcp lease
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | dict_check | input dictionary |
    ...
    ...    Example:
    ...    | check_erps_ring_configuration | AXOS | 1 | ring-up=1 | ring-down=1 | health-rx=0 | hello-rx=0 |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show erps-ring ${erps-ring} counters
    @{check_name}    Get Dictionary Keys    ${dict_check}
    : FOR    ${key}   IN    @{check_name}
    \    ${res1}     Get Lines Containing String    ${res}    ${key}
    \    ${check_value}    Get From Dictionary    ${dict_check}   ${key}
    \    should contain    ${res1}    ${check_value}

prov_interface_ethernet
    [Arguments]    ${device}    ${interface}    ${interface_role}=${EMPTY}    ${switchport}=${EMPTY}    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    [Documentation]    configure on interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | interface | Name of spolicy map |
    ...    | switchport | type of service tag-action to create |
    ...    | role | role of interface ethernet |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value |
    ...
    ...    Example:
    ...    | Prov_interface_ethernet | eutA | 1/1/x1 | flow-control=none | transport-service-profile=service-profile |
    ...    | Prov_interface_ethernet | eutA | 1/1/x1 | lag | speed=auto | mtu=1500 |
    ...    | Prov_interface_ethernet | eutA | 1/1/x1 | sub_view_type=erps-ring | sub_view_value=1 | role=primary |
    [Tags]    @author=BlairWang
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ethernet ${interface}
    run keyword if    "${switchport}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    switchport ${switchport}
    run keyword if    "${interface_role}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    role ${interface_role}
    run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    Axos Cli With Error Check    ${device}    end

dprov_interface_ethernet
    [Arguments]    ${device}    ${interface}    @{list_cmd}
    [Documentation]    configure on interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | interface | Name of spolicy map |
    ...    | list_cmd | elements need to be deprovision |
    ...
    ...    Example:
    ...    | dprov_interface_ethernet | AXOS | 1/1/x1 | role | flow-control |
    [Tags]    @author=BlairWang
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ethernet ${interface}
    : FOR    ${element}    IN    @{list_cmd}
    \    Axos Cli With Error Check    ${device}    no ${element}
    [Teardown]    Axos Cli With Error Check    ${device}    end

prov_interface_ethernet_g8032
    [Arguments]    ${device}    ${interface}    ${g8032_ring}    ${rpl-mode}=${EMPTY}
    ...    ${ccm-protection}=${EMPTY}    ${ccm_meg_name}=${EMPTY}    ${ccm_mep_id}=${EMPTY}
    [Documentation]    configure on interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | interface | Name of spolicy map |
    ...    | g8032_ring | G.8032 ring id |
    ...    | rpl-mode | G.8032 ring instance ethernet port RPL mode |
    ...    | ccm-protection | [auto|mep], Type of MEG to use for ring protection |
    ...    | ccm_meg_name | ccm-protection meg name, leave it as ${EMPTY} if ccm-protection=auto |
    ...    | ccm_mep_id | ccm-protection mep id, leave it as ${EMPTY} if ccm-protection=auto |
    ...
    ...    Example:
    ...    | prov_interface_ethernet_g8032 | eutA | 1/1/x1 | owner | auto |
    ...    | prov_interface_ethernet_g8032 | eutA | 1/1/x1 | ccm-protection=mep ${meg_name} ${mep_id} |
    [Tags]    @author=CindyGao
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ethernet ${interface}
    Axos Cli With Error Check    ${device}    g8032-ring ${g8032_ring}
    run keyword if    "${EMPTY}"!="${rpl-mode}"    Axos Cli With Error Check    ${device}    rpl-mode ${rpl-mode}
    run keyword if    "${EMPTY}"!="${ccm-protection}"    Axos Cli With Error Check    ${device}    ccm-protection ${ccm-protection} ${ccm_meg_name} ${ccm_mep_id}
    [Teardown]    Axos Cli With Error Check    ${device}    end

dprov_interface_ethernet_g8032
    [Arguments]    ${device}    ${interface}    ${g8032_ring}=${EMPTY}    &{dict_cmd}
    [Documentation]    configure on interface
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | interface | Name of spolicy map |
    ...    | g8032_ring | G.8032 ring id |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value |
    ...
    ...    Example:
    ...    | dprov_interface_ethernet_g8032 | eutA | 1/1/x1 | g8032-ring={ring_id} |
    ...    | dprov_interface_ethernet_g8032 | eutA | 1/1/x1 | ccm-protection=${EMPTY} |
    [Tags]    @author=CindyGao
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ethernet ${interface}
    run keyword if    "${EMPTY}"!="${g8032_ring}"    Axos Cli With Error Check    ${device}    g8032-ring ${g8032_ring}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    Axos Cli With Error Check    ${device}    no ${cmd_string}
    [Teardown]    Axos Cli With Error Check    ${device}    end

add_eth_svc_to_cpe_port
    [Arguments]    ${device}    ${port_type}    ${port_id}    ${vlan_id}    ${policy_map_name}    ${class_map_type}=${EMPTY}
    ...    ${class_map_name}=${EMPTY}    ${flow_id}=${EMPTY}    ${multicast_profile}=${EMPTY}    &{dict_cmd}
    [Documentation]    add eth-svc to ont or dsl port
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port_type | port type: ont-ethernet |
    ...    | port_id |port id |
    ...    | vlan_id | vlan id |
    ...    | policy_map_name | policy-map name |
    ...    | class_map_type | class-map-ethernet or class-map-ip |
    ...    | class_map_name | class map name |
    ...    | flow_id | flow id |
    ...    | multicast_profile | multicast profile name |
    ...    | dict_cmd| more option |
    ...    Example:
    ...    | add_eth_svc_to_cpe_port | n1 | | ont-ethernet| 100/g1 |100 | anne | class-map-ethernet | anne | 1 |
    ...    | add_eth_svc_to_cpe_port | n1 | | ont-ethernet| 100/g1 | 100 | anne | class-map-ethernet | annne | 1 | ingress-meter cir=64 |
    [Tags]    @author=AnneLi
    ${cmd_str}    Set Variable    ${EMPTY}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port_type} ${port_id} vlan ${vlan_id}
    run keyword if    '${multicast_profile}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    igmp multicast-profile ${multicast_profile}
    Axos Cli With Error Check    ${device}    policy-map ${policy_map_name}
    ${cmd_str}    Set Variable If    '${class_map_name}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${class_map_type} ${class_map_name}
    ${cmd_str}    Set Variable If    '${flow_id}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} flow ${flow_id}
    Axos Cli With Error Check    ${device}    ${cmd_str}
    ${cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end

remove_eth_svc_to_cpe_port
    [Arguments]    ${device}    ${port_type}    ${port_id}    ${vlan_id}
    [Documentation]    remove eth-svc from ont or dsl port
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | port_type | port type: ont-ethernet |
    ...    | port_id | port id |
    ...    | vlan_id | vlan id |
    ...    Example:
    ...    | remove_eth_svc_to_cpe_port | n1 | ont-ethernet | 100/g1 |100 |
    [Tags]    @author=AnneLi
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port_type} ${port_id}
    Axos Cli With Error Check    ${device}    vlan ${vlan_id}
    Axos Cli With Error Check    ${device}    no policy-map
    Axos Cli With Error Check    ${device}    exit
    Axos Cli With Error Check    ${device}    no vlan ${vlan_id}
    [Teardown]    cli    ${device}    end

check_running_configure
    [Arguments]    ${device}    ${object}    ${object_value}=${EMPTY}    ${subview1}=${EMPTY}    ${subview1_value}=${EMPTY}    ${subview2}=${EMPTY}
    ...    ${subview2_value}=${EMPTY}    ${subview3}=${EMPTY}    ${subview3_value}=${EMPTY}    ${subview4}=${EMPTY}    ${subview4_value}=${EMPTY}    ${contain}=yes    &{dict_check_item}
    [Documentation]    show running-configure
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | object | all object by show running-configure ? |
    ...    | object_value | value of object |
    ...    | subview1 | the first subview of object |
    ...    | subview1_value | value of  subview1 |
    ...    | subview2 | the second subview of object |
    ...    | subview2_value | value of  subview2 |
    ...    | subview3 | the third subview of object |
    ...    | subview3_value | value of  subview3 |
    ...    | subview4 | the forth subview of object |
    ...    | subview4_value | value of  subview4 |
    ...    Example:
    ...    1. check if configure one l2-dhcp-profile named anne on device
    ...    | check_run_configure | n1 | l2-dhcp-profile | anne |
    ...    2. check  some confugure on l2-dhcp-profile view
    ...    | check_run_configure | n1 | l2-dhcp-profile | anne | lease-limit=10 |
    ...    3. check  some confugure on the view of intterface ont-ethernet 1/x1 vlan
    ...    | check_run_configure | n1 | object=interface | object_value=ont-ethernet 1/x1 | subview2=vlan | subview2_value=301 | policy-map=an1 | class-map-ethernet=an1 | flow=1 |
    [Tags]    @author=AnneLi
    ${cmd_str}    Set Variable    show running-config
    ${cmd_str}    Set Variable If    '${object}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${object}
    ${cmd_str}    Set Variable If    '${object_value}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${object_value}
    ${cmd_str}    Set Variable If    '${subview1}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${subview1}
    ${cmd_str}    Set Variable If    '${subview1_value}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${subview1_value}
    ${cmd_str}    Set Variable If    '${subview2}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${subview2}
    ${cmd_str}    Set Variable If    '${subview2_value}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${subview2_value}
    ${cmd_str}    Set Variable If    '${subview3}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${subview3}
    ${cmd_str}    Set Variable If    '${subview3_value}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${subview3_value}
    ${cmd_str}    Set Variable If    '${subview4}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${subview4}
    ${cmd_str}    Set Variable If   '${subview4_value}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ${subview4_value}
    Axos Cli With Error Check     ${device}    ${cmd_str}
    # modify by CindyGao for int item, start
    ${res}    CLI    ${device}    ${cmd_str}
    @{list_key}    Get Dictionary Keys    ${dict_check_item}
    : FOR    ${check_item}   IN    @{list_key}
    \    ${exp_value}    Get From Dictionary    ${dict_check_item}   ${check_item}
    \    ${pattern}    set variable    (?i)${check_item}\\s+${exp_value}
    \    Run Keyword If    "yes"=="${contain}"    Should Match Regexp    ${res}    ${pattern}
    \    ...    ELSE    Should Not Match Regexp    ${res}    ${pattern}
    # modify by CindyGao for int item, end
    [Return]    ${res}

check_bridge_table
    [Arguments]    ${device}        ${mac}     ${port}=${EMPTY}          ${vlan}=${EMPTY}      ${learn}=${EMPTY}
    [Documentation]    show bridge table
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | mac | mac address |
    ...    | port | eth-port or ont-port id |
    ...    | vlan | vlan id |
    ...    | learn | DYNAMIC or static |
    ...    Example:
    ...    | check_bridge_table | n1 | 00:02:5d:fc:fa:2e | 1/1/x2 | 11 | DYNAMIC |
    ...    | check_bridge_table | n1 | 00:02:5d:fc:fa:2e | 100/x1 | 100 |
    [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show bridge table
    ${res1}    Get Lines Containing String    ${result}    ${mac}
    ${temp}    get regexp matches    ${res1}    (\\d+)\\s*(\\d+)\\s*(\\d*/*\\w+\\d+)\\s*(\\d+)\\s*${mac}\\s*(\\d)+\\s*(\\w+)    1    2    3   4    5    6
    ${temp}    set Variable      ${temp[0]}
    ${port1}    set Variable if    '${temp[0]}'!='0'    ${temp[0]}/${temp[1]}/${temp[2]}    ${temp[2]}
    ${vlan1}    set Variable    ${temp[3]}
    ${age1}    set Variable    ${temp[4]}
    ${learn1}    set Variable    ${temp[5]}
    run keyword if    '${port}'!='${EMPTY}'    Should Be Equal    ${port1}    ${port}
    run keyword if    '${vlan}'!='${EMPTY}'    should be equal as integers    ${vlan1}    ${vlan}
    run keyword if    '${learn}'!='${EMPTY}'    Should Be Equal    ${learn1}    ${learn}

clear_bridge_table
    [Arguments]    ${device}
    [Documentation]    Description: clear bridge table
    [Tags]    @author=LincolnYu
    Axos Cli With Error Check    ${device}    clear bridge table
    [Teardown]    cli    ${device}    end
    
check_bridge_mac_count
    [Arguments]    ${device}
    [Tags]    @author=kpei
    ${output}    cli   ${device}   show bridge info
    ${temp}    get regexp matches    ${output}    (total-mac-addresses)\\s*(\\d+)    1    2
    ${maccount}    set Variable    ${temp[0][1]}
    [Return]    ${maccount}
    
set_bridge_aging_interval
    [Arguments]    ${device}    ${age}
    [Documentation]    Description: set bridge aging-interval
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | age | age interval for bridge table [60-600] |
    ...
    ...    Example:
    ...    | set_bridge_aging_interval | 300 |
    ...    [AT-5607] move from feature folder to common keyword
    [Tags]    @author=LincolnYu
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    bridge aging-interval ${age}
    [Teardown]    cli    ${device}    end

show_interface_counters
    [Arguments]       ${device}      ${port_type}       ${port_id}
    [Documentation]    show interface  counters
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | port_type | port type |
    ...    | port_id | port id |
    ...    Example:
    ...    | show_interface_counters | n1 | ethernet | 1/1/x1 |
    [Tags]    @author=AnneLi
    CLI    ${device}    show interface ${port_type} ${port_id} counters

clear_interface_counters
    [Arguments]       ${device}      ${port_type}       ${port_id}
    [Documentation]    show interface  counters
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | port_type | port type |
    ...    | port_id | port id |
    ...    Example:
    ...    | clear_interface_counters | n1 | ethernet | 1/1/x1 |
    [Tags]    @author=AnneLi
    CLI    ${device}    clear interface ${port_type} ${port_id} counters


prov_dscp_map
    [Arguments]    ${device}    ${dscp_map_name}    ${dscp_value}=${EMPTY}    ${p_value}=${EMPTY}
    [Documentation]    Description: provision dscp-map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | dscp_map_name | name for dscp-map |
    ...    | dscp_value | Valid Diffserv Codepoint value |
    ...    | p_value | Priority Code Point value |

    [Tags]    @author=WanlinSun
    cli    ${device}    configure
    cli    ${device}    dscp-map ${dscp_map_name}
    run keyword if    '${EMPTY}'!='${dscp_value}'    Axos Cli With Error Check    ${device}    dscp ${dscp_value} ${p_value}
    [Teardown]    cli    ${device}    end

dprov_dscp_map
    [Arguments]    ${device}    ${dscp_map_name}     ${dscp_value}=${EMPTY}    ${p_value}=${EMPTY}
    [Documentation]    Description:  deprovision dscp-map
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | dscp_map_name | name for dscp-map |
    ...    | dscp_value | Valid Diffserv Codepoint value |
    ...    | p_value | Priority Code Point value |

    [Tags]    @author=WanlinSun
    cli    ${device}    configure
    run keyword if    '${EMPTY}'!='${dscp_value}'    Axos Cli With Error Check    ${device}    no dscp ${dscp_value} ${p_value}
    cli    ${device}    no dscp-map ${dscp_map_name}
    [Teardown]    cli    ${device}    end


verify_dscp_mapping
    [Arguments]          ${device}     ${dscp_map_name}    ${dscp_value}    ${p_value}
    [Documentation]      Verify DSCP to PCP mapping correct
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | dscp_map_name | name for dscp-map |
    ...    | dscp_value | Valid Diffserv Codepoint value |
    ...    | p_value | Priority Code Point value |
    [Tags]               @author=WanlinSun
    ${res}    cli    ${device}    show dscp-map details ${dscp_map_name}
    ${res}    Should Match Regexp    ${res}    \\w+\\(${dscp_value}\\)\\s+${p_value}

prov_ipv4_l2host_on_sub_port
    [Arguments]          ${device}     ${subscriber_point}    ${service_vlan}    ${ip}    ${option}=${EMPTY}
    ${type}    set variable    ${service_model.${subscriber_point}.type}
    ${port_type}    set variable if    'ont_port'=='${type}'    ont-ethernet
    cli    ${device}    configure
    cli    ${device}    int ${port_type} ${service_model.${subscriber_point}.name}
    cli    ${device}    vlan ${service_vlan}
    Axos Cli With Error Check    ${device}    ipv4 l2host ${ip} ${option}
    [Teardown]    cli    ${device}    end
dprov_ipv4_l2host_on_sub_port
    [Arguments]          ${device}     ${subscriber_point}    ${service_vlan}    ${option}=${EMPTY}
    ${type}    set variable    ${service_model.${subscriber_point}.type}
    ${port_type}    set variable if    'ont_port'=='${type}'    ont-ethernet
    cli    ${device}    configure
    cli    ${device}    int ${port_type} ${service_model.${subscriber_point}.name}
    cli    ${device}    vlan ${service_vlan}
    Axos Cli With Error Check    ${device}    no ipv4 l2host ${option}
    [Teardown]    cli    ${device}    end

get_alarm_active_time
    [Arguments]    ${device}    ${alarm_name}    ${alarm_discription}=${EMPTY}
    [Documentation]   get alarm active time
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | alarm_name  | the alarm need to get the time |
    ...    | alarm_discription  | distinguish the same alarm with detailed object |
    ...
    ...    Example:
    ...    | get_alarm_active_time | AXOS | low-rx-opt-pwr-ne | ont-id='2' |
    [Tags]    @author=BlairWang

    ${cmd_str}    set variable if    "${alarm_discription}"=="${EMPTY}"    show alarm active    show alarm active | include ${alarm_discription}
    ${res}    cli    ${device}    ${cmd_str}
    ${result}    Get Regexp Matches    ${res}    ne-event-time\\s+(\\d+-\\d+-\\d+)T(\\d+:\\d+:\\d+).+${alarm_name}    1    2
    ${date}    set variable    ${result[0]}
    ${date1}    set variable    ${date[0]}
    ${time}    set variable    ${date[1]}
    ${newdate}    Catenate    ${date1}    ${time}
    [Return]    ${newdate}

get_erps_last_topo_change_time
    [Arguments]    ${device}    ${erps-ring}
    [Documentation]   get last topologe change time on erps-ring status
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...
    ...    Example:
    ...    | get_erps_last_topo_change_time | AXOS | 1 |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show erps-ring ${erps-ring} status
    ${result}    Get Regexp Matches    ${res}     "time :\\s+(\\d+-\\d+-\\d+\\s+\\d+:\\d+:\\d+).+    1
    ${date}    set variable    ${result[0]}
    [Return]    ${date}

check_erps_ring_up
    [Arguments]    ${device}    ${erps-ring}
    [Documentation]   check erps ring is up
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | master node |
    ...    | erps-ring | erps ring id |
    ...
    ...    Example:
    ...    | check_erps_ring_up | eutA | 6 |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show erps-ring ${erps-ring} status
    should Match Regexp    ${res}    state : complete|state : ports-up
    ${res1}     Get Lines Containing String    ${res}    configuration-state
    should contain    ${res1}    resolved

delete_dhcp_lease
    [Arguments]    ${device}    ${vlan}    ${ip}=${EMPTY}
    [Documentation]    this is the keyword used to delete dhcp lease belongs to certain vlan
    [Tags]        @author=llin
    ${cmd_str}    set variable       delete dhcp snoop lease vlan ${vlan}
    ${cmd_str}    Set Variable If    '${ip}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} ip ${ip}
    Axos Cli With Error Check    ${device}       ${cmd_str}

clear_dhcp_statistics
    [Arguments]    ${device}
    [Documentation]    this is the keyword used to delete dhcp statistics
    [Tags]        @author=llin
    Axos Cli With Error Check    ${device}    clear dhcp snoop statistics


show_dhcp_statistics
    [Arguments]    ${device}
    [Documentation]    this is the keyword used to show dhcp statistics
    [Tags]        @author=llin
    ${res}     cli   ${device}    show dhcp snoop statistics
    [Return]     ${res}

check_dhcp_statistics
    [Arguments]    ${device}     ${type}    ${condition}   ${value_expect}
    [Documentation]     this is the keyword used to check dhcp statistics certain packet satisfy certain condition
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | type   |  lease-acquisitions, lease-renewals, lease-timeouts, discovers, offers, requests, acks, nacks, releases, declines, informs, force-renews |
    ...    | condition |   equal, larger than, less than |
    ...    | value_expect | number you expected |
    ...
    ...    Example:
    ...    | check_dhcp_statistics | eutA | acks | equal | 10 |
    [Tags]        @author=llin
    ${regStr}  set variable     \\s+${type}\\s*(\\d*)
    ${res}      show_dhcp_statistics     ${device}
    ${result}    Get Regexp Matches    ${res}      ${regStr}     1
    ${real}    convert to integer    ${result[0]}
    ${expect}    convert to integer       ${value_expect}
    run keyword if     '${condition}'=='equal'    should be equal   ${real}    ${expect}
    ${status}=     evaluate    ${real}<${expect}
    run keyword if     '${condition}'=='larger than'     should be equal      ${status}    ${False}
    run keyword if     '${condition}'=='less than'     should be true      ${status}

get_chassis_mac
    [Arguments]    ${device}
    [Documentation]   get chassis mac
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...
    ...    Example:
    ...    | get_chassis_mac | AXOS |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show inventory chassis
    ${result}    Get Regexp Matches    ${res}    mac\\s+(\\w+:\\w+:\\w+:\\w+:\\w+:\\w+)    1
    ${mac}    set variable    ${result[0]}
    [Return]    ${mac}

get_chassis_serial_number
    [Arguments]    ${device}
    [Documentation]   get chassis serial number
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...
    ...    Example:
    ...    | get_chassis_serial_number | AXOS |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show inventory chassis
    ${result}    Get Regexp Matches    ${res}     serial-number\\s+0(\\d+)    1
    ${serial_num}    set variable    ${result[0]}
    [Return]     ${serial_num}

prov_id_profile
    [Arguments]    ${device}    ${id-profile-name}    ${circuit-id}=${EMPTY}    ${remote-id}=${EMPTY}  &{dict_cmd}
    [Documentation]    provision id-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | id-profile-name | id-profile name |
    ...    | circuit-id | circuit-id-name |
    ...    | remote-id | remote-id-name |
    ...    Example:
    ...    | prov_id_profile | n1 | josie|
   ...    | prov_id_profile | n1 | josie|josie1 |
    [Tags]    @author=joli
    ${cmd_str}    Set Variable    id-profile ${id-profile-name}
    ${cmd_str}    Set Variable If    '${circuit-id}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} circuit-id ${circuit-id}
    ${cmd_str}    Set Variable If    '${remote-id}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} remote-id ${remote-id}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${cmd_str}
    ${cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end
    
check_lag_up
    [Arguments]    ${device}    ${lag}
    [Documentation]   check lag is up
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | master node |
    ...    | lag | lag name |
    ...
    ...    Example:
    ...    | check_erps_ring_up | eutA | la1 |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show interface lag ${lag} status
    ${res1}     Get Lines Containing String    ${res}    admin-state
    ${res2}     Get Lines Containing String    ${res}    oper-state
    should contain    ${res1}    enable
    should contain    ${res2}    up

check_g8032_ring_up
    [Arguments]    ${device}    ${g8032-ring}
    [Documentation]   check g8032 ring is up
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | master node |
    ...    | g8032-ring | g8032 ring id |
    ...
    ...    Example:
    ...    | check_g8032_ring_up | eutA | 6 |
    [Tags]    @author=BlairWang
    # ${res}    cli    ${device}    perform g8032 clear ring-instance-id ${g8032-ring}
    ${res}    cli    ${device}    show g8032-ring ${g8032-ring} status
    ${res1}     Get Lines Containing String    ${res}    configuration-state
    ${res2}     Get Lines Containing String    ${res}    protocol-state
    should contain    ${res1}    resolved
    should contain    ${res2}    state-a-idle

check_g8032_ring
    [Arguments]    ${device}    ${ring_name}    ${query_cmd}=${EMPTY}    &{dict_check_item}
    [Documentation]    Description: check "show g8032-ring  ${ring_name} ${query_cmd}" information
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | ring_name | ring name |
    ...    | query_cmd | command key for "show g8032-ring  ${ring_name} ${query_cmd}" command, it also can be set to ${EMPTY} |
    ...    | dict_check_item | dictionary type check item, format as check_item=exp_value or check_item=${EMPTY} |
    ...    Example:
    ...    | check_g8032_ring | eutA | 1 | node-rpl-mode=owner | 
    ...    | check_g8032_ring | eutA | 1 | status | protocol-state=state-a-idle | configuration-state=resolved |
    ...    | check_g8032_ring | eutA | 1 | status port-0-status | fwd-state=forwarding |
    ...    | check_g8032_ring | eutA | 1 | configuration | control-vlan=44 |
    [Tags]    @author=CindyGao
    ${res}    Axos Cli With Error Check    ${device}    show g8032-ring ${ring_name} ${query_cmd}
    @{list_key}    Get Dictionary Keys    ${dict_check_item}
    : FOR    ${check_item}   IN    @{list_key}
    \    ${exp_value}    Get From Dictionary    ${dict_check_item}   ${check_item}
    \    Should Match Regexp    ${res}    ${check_item}\\s+${exp_value}
    [Return]    ${res}

    
get_lag_port_state
    [Arguments]    ${device}    ${lag}    ${interface}
    [Documentation]   get oper state and lacp status of lag
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | lag | lag name |
    ...    | interface | interface ethernet |    
    ...
    ...    Example:
    ...    | get_lag_port_state | eutA | la1 | 1/1/x1 |
    [Tags]    @author=BlairWang  
    ${res}    cli    ${device}    show interface lag ${lag} members
    ${result}    Get Regexp Matches    ${res}     ${interface}\\s+(\\w+)\\s+(\\w+)\\s+    1    2
    ${result_1}  set variable    ${result[0]}
    ${oper_state}    set variable    ${result_1[0]}
    ${lacp_status}    set variable    ${result_1[1]}
    [Return]    ${oper_state}    ${lacp_status}
    
prov_meg
    [Arguments]    ${device}    ${name}    ${mep_id}=${EMPTY}    ${mip_id}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description: provision meg
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | name | MEG name |
    ...    | mep_id | Unique identifier for MEP within the MEG (range: 1-8191) |
    ...    | mip_id | Unique identifier for MIP within the MEG (range: 1-8191) |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    1. configure view: meg
    ...    | prov_meg | eutA | meg1 | level=1 |
    ...    2. configure view: mep
    ...    | prov_meg | eutA | meg1 | 100 | direction=down | continuity-check=enable |
    ...    3. configure view: mip
    ...    | prov_meg | eutA | meg1 | mip_id=80 | admin-state=enable | description=mip80 |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    cli    ${device}    meg ${name}
    run keyword if    '${EMPTY}'!='${mep_id}'    Axos Cli With Error Check    ${device}    mep ${mep_id}
    run keyword if    '${EMPTY}'!='${mip_id}'    Axos Cli With Error Check    ${device}    mip ${mip_id}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

dprov_meg
    [Arguments]    ${device}    ${name}    ${mep_id}=${EMPTY}    ${mip_id}=${EMPTY}    &{dict_cmd}
    [Documentation]    Description:  deprovision meg
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | name | MEG name |
    ...    | mep_id | Unique identifier for MEP within the MEG (range: 1-8191) |
    ...    | mip_id | Unique identifier for MIP within the MEG (range: 1-8191) |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    1. deprovision meg parameter
    ...    | prov_meg | eutA | meg1 | level=${EMPTY} |
    ...    2. deprovision mep
    ...    | prov_meg | eutA | meg1 | mep=100 |
    ...    3. deprovision mip
    ...    | prov_meg | eutA | meg1 | mip=80 |
    ...    4. deprovision mep configure view parameter
    ...    | prov_meg | eutA | meg1 | 100 | direction=${EMPTY} | continuity-check=${EMPTY} |
    ...    5. deprovision mip configure view parameter
    ...    | prov_meg | eutA | meg1 | mip_id=80 | description=${EMPTY} |
    [Tags]    @author=CindyGao
    cli    ${device}    configure
    cli    ${device}    meg ${name}
    run keyword if    '${EMPTY}'!='${mep_id}'    Axos Cli With Error Check    ${device}    mep ${mep_id}
    run keyword if    '${EMPTY}'!='${mip_id}'    Axos Cli With Error Check    ${device}    mip ${mip_id}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    Axos Cli With Error Check    ${device}    no ${cmd_string}
    [Teardown]    cli    ${device}    end
    
check_meg
    [Arguments]    ${device}    ${name}    ${query_cmd}    ${check_item}    ${exp_value}=${EMPTY}
    [Documentation]    Description: check "show meg ${query_cmd}" information
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | name | meg name, it also can be set to ${EMPTY} |
    ...    | query_cmd | command key for "show meg ${query_cmd}" command, it also can be set to ${EMPTY} |
    ...    | check_item | check item in show command display |
    ...    | exp_value | expect value for check item |
    ...
    ...    Example:
    ...    1. check info for "show meg meg1 summary" command
    ...    | check_meg | eutA | meg1 | summary | level | 1 |
    ...    | check_meg | eutA | meg1 | summary | ccm-interval | 1sec |
    ...    2. check info for "show meg meg1 mep 100" command
    ...    | check_meg | eutA | meg1 | mep 100 | direction | down |
    ...    3. check no entry found
    ...    | check_meg | eutA | meg1 | mep | No entries |
    ...    | check_meg | eutA | ${EMPTY} | ${EMPTY} | No entries |
    [Tags]    @author=CindyGao
    ${res}    Axos Cli With Error Check    ${device}    show meg ${name} ${query_cmd}
    Should Match Regexp    ${res}    ${check_item}\\s+${exp_value}    
    [Return]    ${res}
    
prov_interface_rmon_session
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${duration}    ${count}    &{dict_cmd}
    [Documentation]    Description: add service to subscriber port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | subscriber_port type, {ethernet|ont-ethernet|dsl} |
    ...    | port_name | subscriber_port name |
    ...    | duration | PM Bin Duration |
    ...    | count | The requested bin count |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    | prov_interface_rmon_session | eutA | ont-ethernet | 1/x1 | five-minutes | 100 | bin-gos=enable | 
    ...    | prov_interface_rmon_session | eutA | ethernet | 1/1/x1 | fifteen-minutes | 100 | 
    [Tags]    @author=CindyGao
    log    ****** [${device}]provision interface ${port_type} ${port_name}: rmon-session ${duration} ${count}******
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port_type} ${port_name}
    Axos Cli With Error Check    ${device}    rmon-session ${duration} ${count}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end

dprov_interface_rmon_session
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${duration}=${EMPTY}    ${count}=${EMPTY}    @{cmd_list}
    [Documentation]    Description: add service to subscriber port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | subscriber_port type, {ethernet|ont-ethernet|dsl} |
    ...    | port_name | subscriber_port name |
    ...    | duration | PM Bin Duration |
    ...    | count | The requested bin count |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    1. deprovision all rmon-session
    ...    | dprov_interface_rmon_session | eutA | ont-ethernet | 1/x1 | rmon-session |
    ...    2. deprovision rmon-session fifteen-minutes 100
    ...    | dprov_interface_rmon_session | eutA | ethernet | 1/1/x1 | rmon-session fifteen-minutes 100 | 
    ...    3. deprovision bin-gos for rmon-session five-minutes 100
    ...    | dprov_interface_rmon_session | eutA | ont-ethernet | 1/x1 | five-minutes | 100 | bin-gos | 
    [Tags]    @author=CindyGao
    log    ****** [${device}]deprovision interface ${port_type} ${port_name}: rmon-session ${duration} ${count}******
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ${port_type} ${port_name}
    run keyword if    '${EMPTY}'!='${duration}'    Axos Cli With Error Check    ${device}    rmon-session ${duration} ${count}
    : FOR    ${element}    IN    @{cmd_list}
    \    Axos Cli With Error Check    ${device}    no ${element}
    [Teardown]    cli    ${device}    end
    
check_interface_pm
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${bin-duration}    ${bin-or-interval}    ${num-back}    &{dict_check_item}
    [Documentation]    Description: check "show interface ${port_type} ${port_name} performance-monitoring rmon-session" information
    ...    query item is: bin-duration ${bin-duration} bin-or-interval ${bin-or-interval} num-back ${num-back} num-show 1
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | bin-duration | Configured rmon-session bin-duration |
    ...    | bin-or-interval | Keyword bin or interval |
    ...    | num-back | Exact bin or interval which is num-back from current |
    ...    | num-show | How many bins or intervals to display |
    ...    | dict_check_item | dictionary type check item, format as check_item=exp_value or check_item=${EMPTY} |
    ...
    ...    Example:
    ...    | check_interface_pm | eutA | ont-ethernet | 100/x1 | five-minutes | bin | 0 | time-elapsed=300 Secs | upstream-packets-64-octets=100 |
    [Tags]    @author=CindyGao
    ${res}    Axos Cli With Error Check    ${device}
    ...    show interface ${port_type} ${port_name} performance-monitoring rmon-session bin-duration ${bin-duration} bin-or-interval ${bin-or-interval} num-back ${num-back} num-show 1
    @{list_key}    Get Dictionary Keys    ${dict_check_item}
    : FOR    ${check_item}   IN    @{list_key}
    \    ${exp_value}    Get From Dictionary    ${dict_check_item}   ${check_item}
    \    Should Match Regexp    ${res}    ${check_item}\\s+${exp_value}
    [Return]    ${res}

############################ keyword for PON and ONT ######################## 

perform_ont
    [Arguments]    ${device}    ${ont_id}    ${action}    ${option_string}=${EMPTY}
    [Documentation]    Description: perform ont related operations
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | ont_id | ont id |
    ...    | action | perform ont related operations: [reset|unlink|optical-test|power-inquiry|protection-switch] |
    ...    | option_string | option cmd string for perform ont ${action} ont-id ${ont_id} ${option_string} |
    ...
    ...    Example:
    ...    | perform_ont | eutA | 801 | unlink |
    ...    | perform_ont | eutA | 801 | reset |
    ...    | perform_ont | eutA | ont801 | optical-test |
    ...    | perform_ont | eutA | 100 | protection-switch | channel-termination |
    [Tags]    @author=CindyGao
    log    ******[${device}] perform ont ${action} ont-id ${ont_id} ${option_string}******
    Axos Cli With Error Check    ${device}    perform ont ${action} ont-id ${ont_id} ${option_string}    60

quarantine_ont
    [Arguments]    ${device}    ${vendor}    ${sn}    ${no_option}=${EMPTY}
    [Documentation]    Description: perform ont related operations
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | vendor | ont vendor id |
    ...    | sn | ont serial number |
    ...    | no_option | [no|${EMPTY}], default=${EMPTY} for quarantine-ont operation; set to no for no operation |
    ...
    ...    Example:
    ...    | quarantine_ont | eutA | CXNK | 123456 |
    ...    | quarantine_ont | eutA | CXNK | 123456 | no |
    [Tags]    @author=CindyGao
    log    ******[${device}] ${no_option} quarantine-ont ${vendor} ${sn}******
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${no_option} quarantine-ont ${vendor} ${sn}
    [Teardown]    cli    ${device}    end
    
check_quarantine_ont
    [Arguments]    ${device}    ${vendor}    ${sn}    ${type}    ${contain}=yes
    [Documentation]    Description: perform ont related operations
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | vendor | ont vendor id |
    ...    | sn | ont serial number |
    ...    | type | {maunal|auto} quarantine-ont type |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...
    ...    Example:
    ...    | check_quarantine_ont | eutA | CXNK | 123456 | manual |
    ...    | check_quarantine_ont | eutA | CXNK | 123456 | manual | no |
    [Tags]    @author=CindyGao
    ${result}    Axos Cli With Error Check    ${device}    show quarantined-ont
    ${pattern}    set variable    (?i)${vendor}\\s+${sn}\\s+${type}
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${result}    ${pattern}
    ...    ELSE    should not match regexp    ${result}    ${pattern}

perform_interface_pon
    [Arguments]    ${device}    ${port}    ${rogue-detection-override}=${EMPTY}
    [Documentation]    Description: perform ont related operations
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port | pon port name |
    ...    | rogue-detection-override | {start|stop} |
    ...
    ...    Example:
    ...    | perform_interface_pon | 1/1/xp1 | start |
    [Tags]    @author=CindyGao
    log    ******[${device}] perform interface pon ${port} rogue-detection-override ${rogue-detection-override}******
    Axos Cli With Error Check    ${device}    perform interface pon ${port} rogue-detection-override ${rogue-detection-override}    60

prov_gpon_behavior
    [Arguments]    ${device}    ${rogue-detection}=${EMPTY}    &{dict_cmd}    
    [Documentation]    Description: add service to subscriber port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | rogue-detection | [true|false] enable rogue detection |
    ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    ...
    ...    Example:
    ...    | prov_gpon_behavior | true | 
    ...    | prov_gpon_behavior | true | auto-migration=true | ont-esafe=false | ont-option60-format=calix |
    [Tags]    @author=CindyGao
    log    ******[${device}] provision gpon-behavior******
    cli    ${device}    configure
    ${cmd_str}    set variable    gpon-behavior
    ${cmd_str}    Set Variable If    '${EMPTY}'=='${rogue-detection}'    ${cmd_str}    ${cmd_str} rogue-detection ${rogue-detection}
    ${opt_cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${EMPTY}'=='${opt_cmd_str}'    Axos Cli With Error Check    ${device}    ${cmd_str}
    ...    ELSE    Axos Cli With Error Check    ${device}    ${cmd_str} ${opt_cmd_str}
    [Teardown]    cli    ${device}    end   

prov_interface_rg_ip
    [Arguments]    ${device}    ${port_name}    ${svlan}    ${ip}=${EMPTY}    ${mask}=${EMPTY}    ${gateway}=${EMPTY}
    [Documentation]    Description: add service to subscriber port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_name | rg interface name |
    ...    | svlan | rg interface svlan |
    ...    | ip | IP Address |
    ...    | mask | IP Mask |
    ...    | gateway | Default Gateway |
    ...
    ...    Example:
    ...    | prov_interface_rg_ip | eutA | 100/G1 | 400 | 10.10.10.100 | 24 | 10.10.10.1 | 
    ...    | prov_interface_rg_ip | eutA | 100/G1 | 400 | gateway=10.10.10.1 | 
    [Tags]    @author=CindyGao
    log    ******[${device}] provision interface rg ${port_name}:vlan ${svlan} ip ${ip} mask ${mask} gateway ${gateway}******
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface rg ${port_name}
    Axos Cli With Error Check    ${device}    vlan ${svlan}
    Axos Cli With Error Check    ${device}    default-wan-interface ENABLED
    ${mask_str}    Run Keyword If    '${mask}'!='${EMPTY}'    prov_interface_ip_adapter_mask    ${device}    ${mask}
    ...    ELSE    set variable    ${EMPTY}
    Run Keyword If    '${ip}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ip address ${ip}${mask_str}
    Run Keyword If    '${gateway}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ip gateway ${gateway}
    [Teardown]    cli    ${device}    end      

dprov_interface_rg_ip
    [Arguments]    ${device}    ${port_name}    ${svlan}
    [Documentation]    Description: add service to subscriber port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_name | rg interface name |
    ...    | svlan | rg interface svlan |
    ...    | ip | IP Address |
    ...    | mask | IP Mask |
    ...    | gateway | Default Gateway |
    ...
    ...    Example:
    ...    | dprov_interface_rg_ip | eutA | 100/G1 | 400 | 
    [Tags]    @author=CindyGao
    log    ******[${device}] deprovision interface rg ${port_name}:vlan ${svlan} ip ${ip} mask ${mask} gateway ${gateway}******
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface rg ${port_name}
    Axos Cli With Error Check    ${device}    vlan ${svlan}
    Axos Cli With Error Check    ${device}    no ip address
    Axos Cli With Error Check    ${device}    no default-wan-interface
    [Teardown]    cli    ${device}    end   
    
############################ keyword for DUAL CARD ########################
check_card_info
    [Arguments]    ${device}    ${card_num}    ${check_item}    ${contain}=yes
    [Documentation]    Description: check "show card" command information
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | vendor | ont vendor id |
    ...    | sn | ont serial number |
    ...    | type | {maunal|auto} quarantine-ont type |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...
    ...    Example:
    ...    | check_card_info | eutA | 1/1 | In Service |
    ...    | check_card_info | eutA | \\d | Active |
    [Tags]    @author=CindyGao
    log    ******[${device}] check card ${card_num} ${check_item}, contain=${contain}******
    ${res}    cli    ${device}    show card
    ${pattern}    Set Variable If
    ...    'Active'=='${check_item}' or 'Standby'=='${check_item}'    (?i)${card_num}\\s+.*\\(${check_item}\\)\\s+.*
    ...    (?i)${card_num}\\s+.*${check_item}\\s+.*
    # ${check_item}    Set Variable If    'Active'=='${check_item}' or 'Standby'=='${check_item}'    \\(${check_item}\\)    ${check_item}
    # ${pattern}    set variable    (?i)${card_num}\\s+.*${check_item}\\s+.*
    Run Keyword If    "yes"=="${contain}"    should match regexp    ${res}    ${pattern}
    ...    ELSE    should not match regexp    ${res}    ${pattern}
    [Return]    ${res}
    
check_system_equipment_info
    [Arguments]    ${device}    ${contain}=yes    &{dict_check_item}
    [Documentation]    Description: check "show system-equipment" command information
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    | dict_check_item | dictionary type check item, format as check_item=exp_value or check_item=${EMPTY} |
    ...
    ...    Example:
    ...    | check_system_equipment_info | eutA | active-controller=1/1 | standby-controller=1/2 |
    [Tags]    @author=CindyGao
    ${res}    cli    ${device}    show system-equipment
    : FOR    ${check_item}   IN    @{dict_check_item.keys()}
    \    ${pattern}    Set Variable    (?i)${check_item}\\s+.*${dict_check_item['${check_item}']}
    \    log    ******[${device}] check system-equipment:${pattern}, contain=${contain}******
    \    Run Keyword If    "yes"=="${contain}"    Should Match Regexp    ${res}    ${pattern}
    \    ...    ELSE    Should Not Match Regexp    ${res}    ${pattern}
    [Return]    ${res}

get_system_equipment_card_info
    [Arguments]    ${device}
    [Documentation]    Description: get "show system-equipment" command information,
    ...    Use &{return_inf}[active] and &{return_inf}[standby] to get active-controller and standby-controller number
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...
    ...    Example:
    ...    | &{dict_card_info} | get_system_equipment_card_info | eutA |
    ...    use &{dict_card_info}[active] and &{dict_card_info}[standby] to get active-controller and standby-controller number
    [Tags]    @author=CindyGao
    ${res}    cli    ${device}    show system-equipment
    ${match}    ${active_card}    should match regexp    ${res}    active-controller\\s+"card\\s+(\\d/\\d)\\s+.*"
    ${match}    ${standby_card}    should match regexp    ${res}    standby-controller\\s+"card\\s+(\\d/\\d)\\s+.*"
    log    ******[${device}] get system-equipment active-controller ${active_card}, standby-controller ${standby_card}******
    &{dict_info}    create dictionary    active=${active_card}    standby=${standby_card}
    [Return]    &{dict_info}

redundancy_switchover
    [Arguments]    ${device}    ${switch_type}=switchover    ${retry_time}=3min    ${retry_interval}=10s
    [Documentation]    redundancy switchover
    ...    
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | switch_type | {auto-switchover|force-switchover|switchover}, default=switchover |
    ...
    ...    Return Value:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | result_string | 'show switchover status' output string |
    [Tags]    @author=CindyGao
    Axos Cli With Error Check    ${device}    redundancy ${switch_type}
    Disconnect    ${device}
    Sleep    30s    Wait for redundancy ${switch_type}
    ${res}    Wait Until Keyword Succeeds    ${retry_time}    ${retry_interval}    Cli    ${device}    show switchover status
    [Return]    ${res}    
    
check_switchover_status
    [Arguments]    ${device}    ${contain}=yes    &{dict_check_item}
    [Documentation]    Description: perform ont related operations
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    | dict_check_item | dictionary type check item, format as check_item=exp_value or check_item=${EMPTY} |
    ...
    ...    Example:
    ...    | check_switchover_status | eutA | switchover-dm-in-sync-status="All DMs in sync" |
    [Tags]    @author=CindyGao
    ${res}    cli    ${device}    show switchover status
    : FOR    ${check_item}   IN    @{dict_check_item.keys()}
    \    ${pattern}    Set Variable    (?i)${check_item}\\s+.*${dict_check_item['${check_item}']}
    \    log    ******[${device}] check switchover status:${pattern}, contain=${contain}******
    \    Run Keyword If    "yes"=="${contain}"    Should Match Regexp    ${res}    ${pattern}
    \    ...    ELSE    Should Not Match Regexp    ${res}    ${pattern}
    [Return]    ${res}   
    
reload
    [Arguments]    ${device}    ${option}=${EMPTY}    ${retry_time}=${device_reload_time}    ${retry_interval}=30s
    [Documentation]    Description: reload operation
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | option | reload command option, default=${EMPTY} |
    ...
    ...    Example:
    ...    | reload | eutA |
    ...    | reload | eutA | all |
    [Tags]    @author=CindyGao
    ${reload_str}    release_cmd_adapter    ${device}    ${prov_reload_cmd}
    cli    ${device}    reload ${reload_str} ${option}    prompt=Proceed with reload\\? \\[y/N\\]
    sleep   2s
    cli    ${device}    y    timeout=60
    Disconnect    ${device}
    sleep    30s    Wait for device disconnect
    Wait Until Keyword Succeeds    ${retry_time}    ${retry_interval}     Run Keyword And Expect Error    *    Cli    ${device}    show version
    sleep    30s    Wait for reload ${reload_str} ${option} finish
    Wait Until Keyword Succeeds    ${retry_time}    ${retry_interval}   Verify Cmd Working After Reload    ${device}     show version
    
reload_card
    [Arguments]    ${device}    ${card}    ${retry_time}=${card_reload_time}    ${retry_interval}=30s
    [Documentation]    Description: reload operation
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | option | reload command option, default=${EMPTY} |
    ...
    ...    Example:
    ...    | reload | eutA |
    ...    | reload | eutA | all |
    [Tags]    @author=CindyGao
    cli    ${device}    reload ${card}    prompt=Proceed with reload\\? \\[y/N\\]
    cli    ${device}    y    timeout=120
    Disconnect    ${device}
    sleep    10s    Wait for card ${card} reload
    Wait Until Keyword Succeeds    120s    5s    check_card_info    ${device}    ${card}    Unequipped
    sleep    30s    Wait for reload ${card} finish
    Wait Until Keyword Succeeds    ${retry_time}    ${retry_interval}    check_card_info    ${device}    ${card}    In Service
    
prov_voice_policy_profile
    [Arguments]    ${device}    ${voice_prof}    ${vlan}=${EMPTY}    ${p_bit}=${EMPTY}    ${dscp}=${EMPTY}            
    [Documentation]    Description: provision voice-policy-profile parameters
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | voice_pro | voice-policy-profile id |
    ...    | vlan | voice-policy-profile vlan-id |
    ...    | p-bit | voice-policy-profile priority|
    ...    | dscp | voice-policy-profile dscp-value |
    ...    Example:
    ...    | mod_voice_policy_pro | eutA | vppro_test | 1 | 1 | 1 | 
    [Tags]    @author=YUE SUN  
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    voice-policy-profile ${voice_prof}
    run keyword if    '${vlan}'!="${EMPTY}"    Axos Cli With Error Check    ${device}    vlan-id ${vlan}
    run keyword if    '${p_bit}'!="${EMPTY}"    Axos Cli With Error Check    ${device}    priority ${p_bit}
    run keyword if    '${dscp}'!="${EMPTY}"    Axos Cli With Error Check    ${device}    dscp-value ${dscp}
    [Teardown]    cli    ${device}    end    
    
check_voice_policy_profile
    [Arguments]    ${device}    ${voice_prof}    ${vlan}=${EMPTY}    ${p_bit}=${EMPTY}    ${dscp}=${EMPTY}            
    [Documentation]    Description: modify voice-policy-profile parameters
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | voice_pro | voice-policy-profile id |
    ...    | vlan | voice-policy-profile vlan-id |
    ...    | p_bit | voice-policy-profile priority|
    ...    | dscp | voice-policy-profile dscp-value |
    ...    Example:
    ...    | mod_voice_policy_pro | eutA | vppro_test | 1 | 1 | 1 | 
    [Tags]    @author=YUE SUN  
    ${res}    Axos Cli With Error Check    ${device}    show running-config voice-policy-profile ${voice_prof} | details
    run keyword if    '${vlan}'!="${EMPTY}"    Should Match Regexp    ${res}    vlan-id\\s+${vlan}
    run keyword if    '${p_bit}'!="${EMPTY}"    Should Match Regexp    ${res}    priority\\s+${p_bit}
    run keyword if    '${dscp}'!="${EMPTY}"    Should Match Regexp    ${res}    dscp-value\\s+${dscp}

verify_cli_response_table_by_number
    [Arguments]    ${cli_res}    ${start_line}    ${row_num}    ${column_num}    ${exp_value}    ${delimiter}=\\s+
    [Documentation]    verify cli response as talbe, query by ${row_num} and ${column_num}
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | cli_res | cli response |
    ...    | start_line | start line for table in cli response, start from index 1 |
    ...    | row_num | row number for check item |
    ...    | column_num | column number for check item|
    ...    | exp_value | expect value for check item |
    ...    Example:
    ...    | verify_cli_response_table_by_number | ${res} | ${misc_poe_talbe.start_line} | 0 | 0 | poe_enable | 
    [Tags]    @author=CindyGao    @jira=AT-5498
    log    verify cli table start_line=${start_line}, delimiter=${delimiter}
    ${res_map}    Build Response Map    ${cli_res}
    ${table}    Table Match By Delimiter    ${res_map}    start_line=${start_line}    delimiter=${delimiter}
    log    check line=${row_num}, column=${column_num}, expect value=${exp_value}
    should be equal as strings    ${table[${row_num}][${column_num}]}    ${exp_value}

verify_cli_response_table_by_key
    [Arguments]    ${cli_res}    ${table_form}    ${row_key}    ${column_key}    ${exp_value}    ${delimiter}=\\s+
    [Documentation]    verify cli response as talbe, query by ${table_form}, ${row_key} and ${column_key}
    ...    use required format to set table info in paramater file:
    ...    table_form:
    ...      start_line: <line_number>     start line for table in cli response, start from index 1
    ...      row:
    ...        - row_key1        list row key in sequence
    ...        - row_key2 
    ...      column:
    ...        - column_key1     list column key in sequence
    ...        - column_key2 
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | cli_res | cli response |
    ...    | table_form | table form in paramater file |
    ...    | row_key | row key for check item |
    ...    | column_key | column key for check item|
    ...    | exp_value | expect value for check item |
    ...    Example:
    ...    | verify_cli_response_table_by_key | ${res} | ${misc_poe_talbe} | poe_enable | title | poe_enable | 
    ...    | verify_cli_response_table_by_key | ${res} | ${misc_poe_talbe} | poe_enable | uni1 | 0 | 
    [Tags]    @author=CindyGao    @jira=AT-5498
    log    verify cli response table "${table_form}", start_line=&{table_form}[start_line], delimiter=${delimiter}
    ${res_map}    Build Response Map    ${cli_res}
    ${table}    Table Match By Delimiter    ${res_map}    start_line=&{table_form}[start_line]    delimiter=${delimiter}
    log    check row_key=${row_key}, column_key=${column_key}, expect value=${exp_value}
    ${row_num}    Get Index From List    &{table_form}[row]    ${row_key}
    ${column_num}    Get Index From List    &{table_form}[column]    ${column_key}
    should be equal as strings    ${table[${row_num}][${column_num}]}    ${exp_value}    

verify_cli_response_table_by_defined_key
    [Arguments]    ${cli_res}    ${table_form}    ${row_key}    ${column_key}    ${exp_value}    ${delimiter}=\\s+
    [Documentation]    verify cli response as talbe, query by ${table_form}, ${row_key} and ${column_key}
    ...    Use user defined row/column key and number pair, in case there's a big table and you only need to check one line.
    ...    use required format to set table info in paramater file:
    ...    table_form:
    ...      start_line: <line_number>     start line for table in cli response, start from index 1
    ...      row:
    ...        row_key1: row_num1          row number start from index 0 in table
    ...        row_key2: row_num2
    ...      column:
    ...        column_key1: column_num1    column number start from index 0 in table
    ...        column_key2: column_num2
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | cli_res | cli response |
    ...    | table_form | table form in paramater file |
    ...    | row_key | row key for check item |
    ...    | column_key | column key for check item|
    ...    | exp_value | expect value for check item |
    ...    Example:
    ...    | verify_cli_response_table_by_defined_key | ${res} | ${misc_poe_talbe} | poe_enable | title | poe_enable | 
    ...    | verify_cli_response_table_by_defined_key | ${res} | ${misc_poe_talbe} | poe_enable | uni1 | 0 | 
    [Tags]    @author=CindyGao    @jira=AT-5498
    log    verify cli response table "${table_form}", start_line=&{table_form}[start_line], delimiter=${delimiter}
    ${res_map}    Build Response Map    ${cli_res}
    ${table}    Table Match By Delimiter    ${res_map}    start_line=&{table_form}[start_line]    delimiter=${delimiter}
    log    check row_key=${row_key}, column_key=${column_key}, expect value=${exp_value}
    ${row_num}    Get From Dictionary    &{table_form}[row]    ${row_key}
    ${column_num}    Get From Dictionary    &{table_form}[column]    ${column_key}
    should be equal as strings    ${table[${row_num}][${column_num}]}    ${exp_value}    


prov_vlan_egress
    [Arguments]    ${device}    ${vlan}    ${egress_type}    ${oper}
    [Documentation]    Description: vlan egress configure
    ...    
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | vlan | vlan number |
    ...    | egress_type | vlan egress type |
    ...    | oper | ENABLED OR DISABLED egress |
    ...
    ...    Example:
    ...    | prov_vlan_egress | eutA | 400 | unknown-unicast-flooding | DISABLE |
    [Tags]    @author=Jyichun&liwang   @jira=AT-5651
    ${egress_get}    release_cmd_adapter    ${device}    ${prov_vlan_egress}
    Return From Keyword If    '${egress_get}'=='${EMPTY}' 
    cli    ${device}    configure
    cli    ${device}    vlan ${vlan}       
    cli    ${device}    egress ${egress_type} ${oper}
    [Teardown]    cli    ${device}    end
      