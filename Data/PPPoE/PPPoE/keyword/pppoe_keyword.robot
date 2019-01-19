*** Settings ***
Documentation    test_suite keyword lib

*** Variable ***


*** Keywords ***
delete_pppoe_session
    [Arguments]    ${device}    ${vlan}    ${mac}
    [Documentation]    delete pppoe session
    [Tags]    @author=joli
    Axos Cli With Error Check    ${device}    delete pppoeia-cli:pppoe-ia session vlan ${vlan} mac ${mac}

check_pppoe_sessions_summary
    [Arguments]    ${device}    ${vlan_id}    ${mac}
    [Documentation]   show pppoe-ia sessions summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan-id | service vlan |
    ...    Example:
    ...    | check_pppoe_sessions_summary | n1 | 666 |
    [Tags]    @author=joli
    ${result}    CLI    ${device}    show pppoe-ia sessions vlan ${vlan_id}
    should contain   ${result}    pppoe-ia sessions vlan ${vlan_id} mac ${mac}    #Updated by AT-5921



check_circuit_id
    [Arguments]    ${device}    ${rx_port}    ${circuit_id}
    [Documentation]   show pppoe-ia sessions summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | id_profile | id-profile |
    ...    | circuit_id | circuit-id |
    ...    Example:
    ...    | check_icircuit_id | n1 | subscriber_p1 | %Stag |
    [Tags]    @author=joli
    Tg Store Captured Packets    tg1    ${rx_port}    /tmp/${TEST NAME}.pcap
    Wsk Load File    /tmp/${TEST NAME}.pcap    pppoed.tags.circuit_id
    ${id}    WSK Get PPPoE Tags Circuit ID
    should be equal as strings    ${id}    ${circuit_id}

check_remote_id
    [Arguments]    ${device}    ${rx_port}    ${remote_id}
    [Documentation]   show pppoe-ia sessions summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | id_profile | id-profile |
    ...    | remote_id | remote_id |
    ...    Example:
    ...    | check_remote_id | n1 | subscriber_p1 | %Stag |
    [Tags]    @author=joli
    Tg Store Captured Packets    tg1    ${rx_port}    /tmp/data.pcap
    Wsk Load File    /tmp/data.pcap    pppoed.tags.remote_id
    ${id}    WSK Get PPPoE Tags Remote ID
    should be equal as strings    ${id}    ${remote_id}

# prov_interface_one2one
    # [Arguments]    ${device}    ${port_type}    ${port_name}    ${svc_vlan}=${EMPTY}    ${c_vlan}=${EMPTY}    ${policy_map_name}=${EMPTY}
    # ...    ${class_map_type}=${EMPTY}    ${class_map_name}=${EMPTY}    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    # [Documentation]    Description: interface provision, especially for add svc
    # ...
    # ...    Arguments:
    # ...    | =Argument Name= | \ =Argument Value= \ |
    # ...    | device | eut node in topo.yaml |
    # ...    | port_type | interface type |
    # ...    | port_name | interface name |
    # ...    | svc_vlan | Ethernet service vlan |
    # ...    | c_vlan | one2one c-vlan |
    # ...    | policy_map_name | name for policy-map |
    # ...    | class_map_type | type for class-map, {class-map-ethernet|class-map-ip} |
    # ...    | class_map_name | name for class-map |
    # ...    | sub_view_type | sub_view type depends on cli layer |
    # ...    | sub_view_value | sub_view name depends on cli layer |
    # ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    # ...
    # ...    Example:
    # ...    1. add policy-map to ethernet port
    # ...    | prov_interface | eutA | ethernet | 1/1/x1 | 200 | l2policymap |
    # ...    2. add policy-map with flow setting to ont-ethernet port
    # ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 100 | l2policymap | class-map-ethernet | l2classmap | flow | 1 | ingress-meter=cir 1000 |
    # ...    3. add igmp to ont-ethernet port
    # ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 300 | sub_view_type=igmp multicast-profile | sub_view_value=igmptest | igmp max-streams=64 |
    # ...    4. add ip host to ont-ethernet port
    # ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 400 | sub_view_type=ipv4 host | sub_view_value=192.1.1.1 | inner-vlan=100 | gateway1=192.1.1.1 |
    # ...    5. add no subview parameter to ethernet port
    # ...    | prov_interface | eutA | ethernet | 1/1/x1 | role=inni | transport-service-profile=test | speed=10Gbs |
    # ...    6. add policy-map to ont-ethernet port for one2one service
    # ...    | prov_interface | eutA | ont-ethernet | 100/x1 | 500 | 10 | l2policymap |
    # [Tags]    @author=LincolnYu
    # log    ****** [${device}] provision interface ${port_type} ${port_name}: svlan=${svc_vlan}, cvlan=${c_vlan}, policy-map=${policy_map_name} ******
    # cli    ${device}    configure
    # Axos Cli With Error Check    ${device}    interface ${port_type} ${port_name}
    # run keyword if    '${EMPTY}'!='${svc_vlan}'    Axos Cli With Error Check    ${device}    vlan ${svc_vlan}
    # run keyword if    '${EMPTY}'!='${c_vlan}'    Axos Cli With Error Check    ${device}    c-vlan ${c_vlan}
    # run keyword if    '${EMPTY}'!='${policy_map_name}'    Axos Cli With Error Check    ${device}    policy-map ${policy_map_name}
    # run keyword if    '${EMPTY}'!='${class_map_type}'    Axos Cli With Error Check    ${device}    ${class_map_type} ${class_map_name}
    # run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    # ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    # run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    ${cmd_string}
    # [Teardown]    cli    ${device}    end

# dprov_interface_one2one
    # [Arguments]    ${device}    ${port_type}    ${port_name}    ${svc_vlan}=${EMPTY}    ${c_vlan}=${EMPTY}    ${policy_map_name}=${EMPTY}    ${class_map_type}=${EMPTY}    ${class_map_name}=${EMPTY}
    # ...    ${sub_view_type}=${EMPTY}    ${sub_view_value}=${EMPTY}    &{dict_cmd}
    # [Documentation]    Description: interface deprovision, especially for remove svc
    # ...
    # ...    Arguments:
    # ...    | =Argument Name= | \ =Argument Value= \ |
    # ...    | device | eut node in topo.yaml |
    # ...    | port_type | interface type |
    # ...    | port_name | interface name |
    # ...    | svc_vlan | Ethernet service vlan |
    # ...    | c_vlan | one2one c-vlan |
    # ...    | policy_map_name | name for policy-map |
    # ...    | class_map_type | type for class-map, {class-map-ethernet|class-map-ip} |
    # ...    | class_map_name | name for class-map |
    # ...    | sub_view_type | sub_view type depends on cli layer |
    # ...    | sub_view_value | sub_view name depends on cli layer |
    # ...    | dict_cmd | dictionary type command, format as cli_key=cli_value or cli_key=${EMPTY} |
    # ...
    # ...    Example:
    # ...    1. remove vlan service from ont-ethernet port
    # ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | vlan=100 |
    # ...    2. remove policy-map from ethernet port
    # ...    | dprov_interface | eutA | ethernet | 1/1/x1 | 200 | policy-map=l2policymap |
    # ...    3. remove policy-map flow 1 parameter ingress-meter from ont-ethernet port
    # ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 100 | l2policymap | class-map-ethernet | l2classmap | flow | 1 | ingress-meter=cir 1000 |
    # ...    4. remove igmp from ont-ethernet port
    # ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 300 | igmp multicast-profile=igmptest |
    # ...    5. remove ip host from ont-ethernet port
    # ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 400 | ipv4 host=192.1.1.1 |
    # ...    6. remove policy-map from one2one service
    # ...    | dprov_interface | eutA | ont-ethernet | 100/x1 | 500 | 10 | policy-map=l2policymap |
    # [Tags]    @author=LincolnYu
    # cli    ${device}    configure
    # Axos Cli With Error Check    ${device}    interface ${port_type} ${port_name}
    # run keyword if    '${EMPTY}'!='${svc_vlan}'    Axos Cli With Error Check    ${device}    vlan ${svc_vlan}
    # run keyword if    '${EMPTY}'!='${c_vlan}'    Axos Cli With Error Check    ${device}    c-vlan ${c_vlan}
    # run keyword if    '${EMPTY}'!='${policy_map_name}'    Axos Cli With Error Check    ${device}    policy-map ${policy_map_name}
    # run keyword if    '${EMPTY}'!='${class_map_type}'    Axos Cli With Error Check    ${device}    ${class_map_type} ${class_map_name}
    # run keyword if    '${EMPTY}'!='${sub_view_type}'    Axos Cli With Error Check    ${device}    ${sub_view_type} ${sub_view_value}
    # ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    # run keyword if    '${EMPTY}'!='${cmd_string}'    Axos Cli With Error Check    ${device}    no ${cmd_string}
    # [Teardown]    cli    ${device}    end

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

check_remote_id_substring
    [Arguments]    ${device}    ${rx_port}    ${sub_num}    ${string}
    [Documentation]
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | rx_port | rx_port |
    ...    | sub_num | the number of the substring from the last|
    ...    | string | string needs to be compared |
    ...    Example:
    ...    | check_remote_id_substring | n1 | subscriber_p1 | -6 | 1EC0AB |
    [Tags]    @author=LincolnYu
    Tg Store Captured Packets    tg1    ${rx_port}    /tmp/data.pcap
    Wsk Load File    /tmp/data.pcap    pppoed.tags.remote_id
    ${id}    WSK Get PPPoE Tags Remote ID
    ${res}    Get Substring    ${id}    ${sub_num}
    should be equal as strings    ${res}    ${string}

check_remote_id_portnumber
    [Arguments]    ${device}    ${rx_port}
    [Documentation]
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | rx_port | rx_port |
    ...    Example:
    ...    | check_remote_id_portnumber | n1 | subscriber_p1 |
    [Tags]    @author=LincolnYu
    Tg Store Captured Packets    tg1    ${rx_port}    /tmp/data.pcap
    Wsk Load File    /tmp/data.pcap    pppoed.tags.remote_id
    ${id}    WSK Get PPPoE Tags Remote ID
    Should Match Regexp    ${id}    \\d0\\d+

check_remote_id_labelportnum
    [Arguments]    ${device}    ${rx_port}
    [Documentation]
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | rx_port | rx_port |
    ...    Example:
    ...    | check_remote_id_portnumber | n1 | subscriber_p1 |
    [Tags]    @author=LincolnYu
    Tg Store Captured Packets    tg1    ${rx_port}    /tmp/data.pcap
    Wsk Load File    /tmp/data.pcap    pppoed.tags.remote_id
    ${id}    WSK Get PPPoE Tags Remote ID
    Should Match Regexp    ${id}    0\\d+

check_remote_id_bmac
    [Arguments]    ${device}    ${rx_port}
    [Documentation]    Just non-empty is OK for %BinaryMAC
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | rx_port | rx_port |
    ...    Example:
    ...    | check_remote_id_portnumber | n1 | subscriber_p1 |
    [Tags]    @author=LincolnYu
    Tg Store Captured Packets    tg1    ${rx_port}    /tmp/data.pcap
    Wsk Load File    /tmp/data.pcap    pppoed.tags.remote_id
    ${id}    WSK Get PPPoE Tags Remote ID
    Should Match Regexp    ${id}    \\S+

prov_subscriber_id
    [Arguments]    ${subscriber_point}    ${desc}
    [Documentation]    Description: get subscriber_id of the ont, that is %Desc in remote-id.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | desc | subscriber_id in the subscriber interface |
    ...
    ...    Example:
    ...    | prov_subscriber_id | ${subscriber_point} | ${desc} |
    [Tags]    @author=LincolnYu
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    Axos Cli With Error Check     ${device}    configure
    Axos Cli With Error Check     ${device}    interface ${service_model.${subscriber_point}.attribute.interface_type} ${service_model.${subscriber_point}.member.interface1}
    Axos Cli With Error Check     ${device}    subscriber-id ${desc}
    Axos Cli With Error Check     ${device}    end

get_onu_mac
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: get onu mac of the ont, that is %MAC in remote-id.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | ont_id | ont name in service_model.yaml |
    ...
    ...    Example:
    ...    | get_subscriber_id | ${subscriber_point}
    [Tags]    @author=LincolnYu
    ${mac}    set variable    onu-mac-addr
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    ${result}    Axos Cli With Error Check    ${device}    show ont ${service_model.${subscriber_point}.attribute.ont_id} status
    ${res1}    Get Lines Containing String    ${result}    ${mac}
    ${temp}    get regexp matches    ${res1}    ${mac}\\s*(\\w\\w:\\w\\w:\\w\\w:\\w\\w:\\w\\w:\\w\\w)    1
    ${onu_mac}    Convert To Uppercase      ${temp[0]}
    [Return]    ${onu_mac}

get_subscriber_id
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: get subscriber_id of the ont, that is %Desc in remote-id.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | ont_id | ont name in service_model.yaml |
    ...
    ...    Example:
    ...    | get_subscriber_id | ${subscriber_point}
    [Tags]    @author=LincolnYu
    ${sub-id}    set variable    subscriber-id
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    ${result}    Axos Cli With Error Check    ${device}    show run interface ${service_model.${subscriber_point}.attribute.interface_type} ${service_model.${subscriber_point}.member.interface1}
    ${res1}    Get Lines Containing String    ${result}    ${sub-id}
    ${temp}    get regexp matches    ${res1}    ${sub-id}\\s*(\\S+)    1
    [Return]    ${temp[0]}

get_ont_serial
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: get serial num of the ont, that is %Serial in remote-id.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | ont_id | ont name in service_model.yaml |
    ...
    ...    Example:
    ...    | get_subscriber_id | ${subscriber_point}
    [Tags]    @author=LincolnYu
    ${serial}    set variable    serial-number
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    ${result}    Axos Cli With Error Check    ${device}    show ont ${service_model.${subscriber_point}.attribute.ont_id} status
    ${res1}    Get Lines Containing String    ${result}    ${serial}
    ${temp}    get regexp matches    ${res1}    ${serial}\\s*(\\S+)    1
    [Return]    ${temp[0]}

get_mgmt_ip
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: get managment_ip of the device, that is %ManagementIP in remote-id.
    [Tags]    @author=LincolnYu
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    ${result}    Axos Cli With Error Check    ${device}    show running-config interface craft 1
    ${res1}    Get Lines Containing String    ${result}    ip address
    ${temp}    get regexp matches    ${res1}    ip address\\s*(\\S+)/\\d    1
    [Return]    ${temp[0]}

get_ont_port
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: get ont_port of the ont, that is %OntPort in remote-id.
    [Tags]    @author=LincolnYu
    ${temp}    get regexp matches    ${service_model.${subscriber_point}.member.interface1}    \\w+/(\\w+)    1
    [Return]    ${temp[0]}

get_pon_port
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: get pon_port of the ont, that is %Port in remote-id.
    [Tags]    @author=LincolnYu
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    ${result}    Axos Cli With Error Check    ${device}    show ont ${service_model.${subscriber_point}.attribute.ont_id} status
    ${res1}    Get Lines Containing String    ${result}    linked-pon
    ${temp}    get regexp matches    ${res1}    \\d+/\\d+/(\\w+)    1
    [Return]    ${temp[0]}

get_host_name
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: get hostname, that is %Hostname and %SystemId in remote-id.
    [Tags]    @author=LincolnYu
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    ${result}    Axos Cli With Error Check    ${device}    show run hostname
    ${res1}    Get Lines Containing String    ${result}    hostname
    ${temp}    get regexp matches    ${res1}    hostname (\\S+)    1
    [Return]    ${temp[0]}









