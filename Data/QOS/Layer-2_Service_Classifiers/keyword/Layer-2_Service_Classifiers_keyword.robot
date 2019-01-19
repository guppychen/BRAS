*** Settings ***
Documentation    test_suite keyword lib

*** Variable ***


*** Keywords ***
check_ont_profile
    [Arguments]    ${device}    ${ont_profile}    &{dict}
    [Documentation]    show run ont-profile 801XGS
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_profile | ont_profile |
    ...    | dict | more option |
    ...    Example:
    ...    | check_ont_profile | n1 | 801XGS | ont-profile=801XGS | ont-ethernet=x1 | ont-ethernet=x1model=801XGS |
    [Tags]    @author=Yuanwu
    ${result}    CLI    ${device}    show run ont-profile ${ont_profile}
    @{list_key}    Get Dictionary Keys    ${dict}
    : FOR    ${key}    IN    @{list_key}
    \    ${value}    Get From Dictionary    ${dict}    ${key}
    \    ${res1}    Get Lines Containing String    ${result}    ${key}
    \    Should contain    ${res1}    ${value}
      [Return]    ${result}


generate_pcap_name
    [Arguments]          ${case_name}
    [Documentation]      generate pcap file name with case name
    [Tags]               @author=WanlinSun
#    ${pcap_name}    Set Variable    /tmp/${case_name}_pkt.pcap
    log    ${TEST NAME}
    ${pcap_name}    Set Variable    /tmp/${TEST NAME}_pkt.pcap
    [Return]    ${pcap_name}


verify_traffic_all_loss_for_stream
    [Arguments]    ${tg}    ${stream_name}
    [Documentation]      verify traffic rx.taotal_pkts is 0 for certain stream
    [Tags]    @author=Molly Yang
    ${res}    Tg Get Traffic Stats By Key On Stream    ${tg}    ${stream_name}    rx.total_pkts
    @{rx_pkts}    Get Dictionary Values    ${res}
    should be true    @{rx_pkts}[0]==0



check_classmap_ethternet
    [Arguments]    ${device}    ${class_map_name}    ${flow_index}=${EMPTY}    ${rule_index}=${EMPTY}    &{dict_rule}
    [Documentation]    show classmap content
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | class_map_name | class map name|
    ...    | rule_index | rule number  |
    ...    | rule_content | Serial-Number, reg-id |
    ...    Example:
    ...    | check_classmap_ethternet | n1 | classmap1|
    ...    | check_classmap_ethternet | n1 | classmap1 | flow 1 | rule 1|
    ...    | check_classmap_ethternet | n1 | classmap1 | flow 2 | rule 2| vlan=100| pcp=3 |
    ...    | check_classmap_ethternet | n1 | classmap1 | flow 3 | rule 1| priority-tagged=${EMPTY} |
    [Tags]    @author=Yuanwu
    ${cmd_str}    set variable    show running-config class-map ethernet ${class_map_name}
    ${cmd_str}    Set Variable If    '${flow_index}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} flow ${flow_index}
    ${cmd_str}    Set Variable If    '${rule_index}'=='${EMPTY}'    ${cmd_str}    ${cmd_str} rule ${rule_index}
    log    ${cmd_str}
    ${class_map_result}    Axos Cli With Error Check    ${device}    ${cmd_str}
    log    ${class_map_result}
    ${result_string}    create list    ${EMPTY}
    @{list_key}    Get Dictionary Keys    ${dict_rule}
    : FOR    ${key}   IN    @{list_key}
    \    ${value}    Get From Dictionary    ${dict_rule}   ${key}
    \    ${result_string}    set variable if    '${value}'=='${EMPTY}'    ${key}    ${key} ${value}
    \    ${flow_content}    Get Lines Containing String    ${class_map_result}    ${result_string}
    \    should contain    ${flow_content}    ${result_string}
    [Return]    ${class_map_result}




convert_dictionary_to_list
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
    ${result_string}    create list    ${EMPTY}
    @{list_key}    Get Dictionary Keys    ${dict}
    : FOR    ${key}   IN    @{list_key}
    \    ${value}    Get From Dictionary    ${dict}   ${key}
    \    @{result_string}    create list    ${key} ${value}
    [Return]    @{result_string}



prov_class_map_without_error_check
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
    [Tags]    @author=YuanWu
    cli    ${device}    configure
    cli    ${device}    class-map ${class_map_type} ${class_map_name}
    Axos Cli With Error Check    ${device}    ${flow_type} ${flow_index}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    ${result}    cli    ${device}    rule ${rule_index} match ${cmd_string}
    [Teardown]    cli    ${device}    end
    [Return]    ${result}


prov_policy_map_without_error_check
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
    cli    ${device}    ${class_map_type} ${class_map_name}
    ${result}    run keyword if    '${EMPTY}'!='${sub_view_type}'    cli    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    ${result}    run keyword if    '${EMPTY}'!='${cmd_string}'    cli    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end
    [Return]    ${result}


delete_config_object_without_error_check
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
    [Tags]    @author=yuanwu
    cli    ${device}    configure
    ${result}    cli    ${device}    no ${obj_type} ${obj_name}
    [Teardown]    cli    ${device}    end
    [Return]    ${result}


dprov_class_map_without_error_check
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
    [Tags]    @author=Yuan wu
    cli    ${device}    configure
    cli    ${device}    class-map ${class_map_type} ${class_map_name}
    run keyword if    '${EMPTY}'!='${flow_type}'    Axos Cli With Error Check    ${device}    ${flow_type} ${flow_index}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    ${result}    cli    ${device}    no ${cmd_string}
    [Teardown]    cli    ${device}    end
    [Return]    ${result}



dprov_policy_map_without_error_check
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
    ${result}    run keyword if    '${EMPTY}'!='${class_map_type}'    cli    ${device}    ${class_map_type} ${class_map_name}
    ${result}    run keyword if    '${EMPTY}'!='${sub_view_type}'    cli    ${device}    ${sub_view_type} ${sub_view_value}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    ${result}    cli    ${device}    no ${cmd_string}
    [Teardown]    cli    ${device}    end
    [Return]    ${result}



Prov_l3_vlan_l3_enable
    [Arguments]    ${device}    ${vlan_name}
    [Documentation]  Enters the CLI commands  to provision vlan 100
    ...    Example:
    ...    | Prov_l3_vlan | eutA | 300 |
    cli    ${device}    config
    cli    ${device}    vlan ${vlan_name}
    cli    ${device}    L3-service ENABLED
    cli    ${device}    end

Prov_l3_vlan_ip
    [Arguments]    ${device}    ${vlan_name}    ${ip}    ${mask}    ${ip_type}=v4
    [Documentation]  Assign ip addresss to vlan 100
    cli    ${device}    config
    cli    ${device}    interface vlan ${vlan_name}
    run keyword if    '${ip_type}'=='v4'    cli    ${device}    ip address ${ip}/${mask}
    run keyword if    '${ip_type}'=='v6'    cli    ${device}    ipv6 address ${ip}/${mask}
    cli    ${device}    end


deprov_l3_vlan
    [Arguments]    ${device}    ${vlan_name}
    [Documentation]  Enters the CLI commands  to provision vlan 100
    ...    Example:
    ...    | deprov_l3_vlan | eutA | 300 |
    cli    ${device}    config
    cli    ${device}    no interface vlan ${vlan_name}
    cli    ${device}    top
    cli    ${device}    no vlan ${vlan_name}
    cli    ${device}    end