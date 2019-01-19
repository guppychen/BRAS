*** Settings ***
Documentation     Suite description
Resource          ../base.robot

*** Keywords ***

#prov_interface_one2one
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

#dprov_interface_one2one
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

subscriber_point_add_svc_one2one
    [Arguments]    ${subscriber_point}    ${svlan}    ${cvlan}    ${policy_map}
    [Documentation]    Description: add 1:1 service to subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | svlan | interface svlan |
    ...    | cvlan | interface cvlan |
    ...    | policy_map | policy-map name, need to create it before |
    ...
    ...    Example:
    ...    | subscriber_point_add_svc_one2one | subscriber_point1 | 100 | 10 | ${policy_map} |
    [Tags]    @author=LincolnYu
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ****** [${device}] add 1:1 service to ${subscriber_point} ******
    ${type}    set variable    ${service_model.${subscriber_point}.type}
    ${port_type}    set variable if    'eth'=='${type}'    ethernet    'ont_port'=='${type}'    ont-ethernet
    log    add policy-map to interface
    prov_interface_one2one    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}    ${svlan}    ${cvlan}    ${policy_map}

subscriber_point_remove_svc_one2one
    [Arguments]    ${subscriber_point}    ${svlan}    ${cvlan}    ${policy_map}
    [Documentation]    Description: remove user-defined policy-map from subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | svlan | interface svlan |
    ...    | cvlan | interface cvlan |
    ...    | policy_map | policy-map name, need to create it before |
    ...
    ...    Example:
    ...    | subscriber_point_remove_svc_user_defined | subscriber_point1 | 100 | 10 | ${policy_map} |
    [Tags]    @author=LincolnYu
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ****** [${device}] remove user-defined service from ${subscriber_point} ******
    ${type}    set variable    ${service_model.${subscriber_point}.type}
    ${port_type}    set variable if    'eth'=='${type}'    ethernet    'ont_port'=='${type}'    ont-ethernet
    log    remove policy-map from interface
    dprov_interface_one2one    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}    ${svlan}    ${cvlan}    policy-map=${policy_map}
    log    remove cvlan from interface
    dprov_interface_one2one    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}    ${svlan}    c-vlan=${cvlan}
    log    remove svlan from interface
    dprov_interface_one2one    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}    vlan=${svlan}

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
    [Tags]    @author=LincolnYu
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    bridge aging-interval ${age}
    [Teardown]    cli    ${device}    end

