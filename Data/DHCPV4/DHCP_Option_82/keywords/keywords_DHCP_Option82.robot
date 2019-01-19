*** Settings ***
Resource    ../base.robot

*** Keywords ***


dprov_id_profile
    [Arguments]    ${device}    ${name}    ${option}=${EMPTY}
    [Documentation]    Description:get rx counter on stc port with filter. if use this keyword ,must use keyword "start_capture"  before start
    ...    traffic and "stop_capture" after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device to run command |
    ...    | name | id-profile name |
    ...    | circuit_id | option82 circuit-id|
    ...    | remote_id | option82 remote-id|
    ...
    ...    Example:
    ...    |dprov_id_profile| | eutA | auto |%QTag | |
    [Tags]    @author=Ronnie_Yi
    cli    ${device}    configure
    run keyword if    '${option}'=='${EMPTY}'    cli    ${device}    no id-profile ${name}
    run keyword if    '${option}'!='${EMPTY}'    cli    ${device}    id-profile ${name}
    run keyword if    '${option}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    no ${option}
    [Teardown]    cli    ${device}    end


check_dhcp_option82_circuit_id
    [Arguments]    ${tg}    ${rx_port}    ${option}
    [Documentation]    Description:get rx counter on stc port with filter. if use this keyword ,must use keyword "start_capture"  before start
    ...    traffic and "stop_capture" after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | rx_port | tg port |
    ...    | option | option82 |
    ...
    ...    Example:
    ...    | check_dhcp_optin82_circuit_id | tg1 | p1 | 1 |
    [Tags]    @author=Ronnie_Yi
    remove_saved_file_on_VM    /tmp/${TEST NAME}.pcap
    Tg Store Captured Packets    ${tg}    ${rx_port}    /tmp/${TEST NAME}.pcap
    Wsk Load File    /tmp/${TEST NAME}.pcap    bootp
    ${circuit_id}    Wsk Get Dhcpv4 Agent Circuit Id
    should be equal as strings    ${circuit_id}    ${option}


check_dhcp_option82_remote_id
    [Arguments]    ${tg}    ${rx_port}    ${option}
    [Documentation]    Description:get rx counter on stc port with filter. if use this keyword ,must use keyword "start_capture"  before start
    ...    traffic and "stop_capture" after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | rx_port | tg port |
    ...    | option | option82 |
    ...
    ...    Example:
    ...    | check_dhcp_optin82_remote_id | tg1 | p1 | 1 |
    [Tags]    @author=Ronnie_Yi
    remove_saved_file_on_VM    /tmp/${TEST NAME}.pcap
    Tg Store Captured Packets    ${tg}    ${rx_port}    /tmp/${TEST NAME}.pcap
    Wsk Load File    /tmp/${TEST NAME}.pcap    bootp
    ${remote_id}    Wsk Get Dhcpv4 Agent Remote Id
    should be equal as strings     ${remote_id}    ${option}

remove_saved_file_on_VM
    [Arguments]    ${file}
    [Documentation]    Description:get rx counter on stc port with filter. if use this keyword ,must use keyword "start_capture"  before start
    ...    traffic and "stop_capture" after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | rx_port | tg port |
    ...    | option | option82 |
    ...
    ...    Example:
    ...    | check_dhcp_optin82_remote_id | tg1 | p1 | 1 |
    [Tags]    @author=Ronnie_Yi
    cli    h1    rm -f ${file}
    ${tmp}    cli    h1    find ${file}
    should contain    ${tmp}    No such file

check_no_dhcp_option82
    [Arguments]    ${tg}    ${rx_port}
    [Documentation]    Description:get rx counter on stc port with filter. if use this keyword ,must use keyword "start_capture"  before start
    ...    traffic and "stop_capture" after stop traffic
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg | tg name in topo.yaml |
    ...    | rx_port | tg port |
    ...    | option | option82 |
    ...
    ...    Example:
    ...    | check_dhcp_optin82_remote_id | tg1 | p1 | 1 |
    [Tags]    @author=Ronnie_Yi
    remove_saved_file_on_VM    /tmp/${TEST NAME}.pcap
    Tg Store Captured Packets    ${tg}    ${rx_port}    /tmp/${TEST NAME}.pcap
    Wsk Load File    /tmp/${TEST NAME}.pcap    bootp
    wsk should not contain dhcp option82


configure_interface_ont_ethernet
    [Arguments]    ${device}    ${port}    &{dict_cmd}
    [Documentation]    configure ont-ethenet parameter
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device to run command |
    ...    | port | ont-ethernet port |
    ...    | dic_cmd | command |
    ...
    ...    Example:
    ...    | configura_interface_ont_ethernet | eutA | 801/x1 | description=aaaa |
    [Tags]    @author=Ronnie_Yi
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ont-ethernet ${port}
    ${cmd_string}    convert_dictionary_to_string    &{dict_cmd}
    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end


delete_interface_ont_ethernet_configuration
    [Arguments]    ${device}    ${port}    ${obj_name}
    [Documentation]    Delete configuration on ont-ethernet port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | deut |
    ...    | port | interface ont-ethenet|
    ...    | obj_name | config object name |
    ...
    ...    Example:
    ...    | delete_interface_ont_ethernet_configuration | eutA | 801/x1 | description |
    [Tags]    @author=Ronnie_Yi
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    interface ont-ethernet ${port}
    Axos Cli With Error Check    ${device}    no ${obj_name}
    [Teardown]    cli    ${device}    end

get_ont_param
    [Arguments]    ${device}    ${ont}    ${option}
    [Documentation]    get ont paramater value
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | deut |
    ...    | ont | ont number|
    ...    | option | parameter  name |
    ...
    ...    Example:
    ...    | get_ont_param | eutA | 801 | status |
    [Tags]    @author=Ronnie_Yi
    ${tmp}    Axos Cli With Error Check    ${device}    show ont ${ont} status
    ${list}    should match regexp    ${tmp}    ${option}\\s+(\\S+)    1
   [Return]    ${list[1]}

get_dhcp_option82_expected_port_type
    [Arguments]    ${port}
    [Documentation]    get %IFtype for option82, this is to be continue, such as dsl/dsl-bonding port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | port | subscriber port|
    ...
    ...    Example:
    ...    | get_dhcp_option82_expected_port_type | subscriber_point1
    [Tags]    @author=Ronnie_Yi
     ${result}    run keyword if    'ont_port'=='${service_model.${port}.type}'    Set Variable   ont
     ...    ELSE IF    'dsl_port'=='${service_model.${port}.type}'    set variable    dsl
    [Return]    ${result}

get_dhcp_option82_expected_port_number
    [Arguments]    ${port}
    [Documentation]    get %portNumber for option82, this is to be continue, such as dsl/dsl-bonding port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | port | subscriber port|
    ...
    ...    Example:
    ...    | get_dhcp_option82_expected_port_number | subscriber_point1
    [Tags]    @author=Ronnie_Yi
     ${tmp}    run keyword if    'ont_port'=='${service_model.${port}.type}'    should match regexp    ${service_model.${port}.attribute.pon_port}[0]    \\S+(\\w)p(\\d+)
#     ...    ELSE IF    'dsl_port'=='${service_model.${port}.type}'    should match regexp    ${service_model.${port}.attribute.dsl_port}[0]    \\S+(v)(\\d+)
     ${port}    run keyword if    'ont_port'=='${service_model.${port}.type}' and '${tmp[1]}'=='x'   Set Variable    600
     ...    ELSE IF    'ont_port'=='${service_model.${port}.type}' and '${tmp[1]}'=='g'   Set Variable    500
#     ...    ELSE IF    'dsl_port'=='${service_model.${port}.type}'    set variable    700
#     ...    ELSE IF    'dsl_bonding'=='${service_model.${port}.type}'    set variable    400
     ${port_number}    convert to integer    ${port}
     ${type_number}    convert to integer    ${tmp[2]}
     ${result}    evaluate    ${port_number}+${type_number}
    [Return]    ${result}

get_dhcp_option82_exported_port
    [Arguments]    ${port}
    [Documentation]    get %port for option82, this is to be continue, such as dsl/dsl-bonding port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | port | subscriber port|
    ...
    ...    Example:
    ...    | get_dhcp_option82_exported_port | subscriber_point1
    [Tags]    @author=Ronnie_Yi
     ${result}    run keyword if    'ont_port'=='${service_model.${port}.type}'    should match regexp    ${service_model.${port}.attribute.pon_port}[0]    \\S+(\\wp\\d+)
#     ...    ELSE IF    'dsl_port'=='${service_model.${port}.type}'    should match regexp    ${service_model.${port}.attribute.dsl_port}[0]    \\S+(v\\d+)
    [Return]    ${result[1]}

get_dhcp_option82_expected_label_port_number
    [Arguments]    ${port}
    [Documentation]    get %LabelportNum for option82, this is to be continue, such as dsl/dsl-bonding port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | port | subscriber port|
    ...
    ...    Example:
    ...    | get_dhcp_option82_expected_label_port_number | subscriber_point1
    [Tags]    @author=Ronnie_Yi
     ${tmp}    run keyword if    'ont_port'=='${service_model.${port}.type}'    should match regexp    ${service_model.${port}.attribute.pon_port}[0]    \\S+p(\\d+)
#     ...    ELSE IF    'dsl_port'=='${service_model.${port}.type}'    should match regexp    ${service_model.${port}.attribute.dsl_port}[0]    \\S+v(\\d+)
     ${result}    set variable    0${tmp[1]}
    [Return]    ${result}

get_dhcp_option82_expected_ont_port_number
    [Arguments]    ${port}
    [Documentation]    get %OntPort for option82, this is to be continue, such as dsl/dsl-bonding port
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | port | subscriber port|
    ...
    ...    Example:
    ...    | get_dhcp_option82_expected_ont_port_number | subscriber_point1
    [Tags]    @author=Ronnie_Yi
     ${tmp}    run keyword if    'ont_port'=='${service_model.${port}.type}'    should match regexp    ${service_model.${port}.member.interface1}    \\S+/(\\S+)
#     ...    ELSE IF    'dsl_port'=='${service_model.${port}.type}'    should match regexp    ${service_model.${port}.member.interface1}    \\S+/(\\S+)
     ${result}    set variable    ${tmp[1]}
    [Return]    ${result}



cli_show_default_enable
    [Arguments]    ${device}
    [Documentation]    enable cli show default
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut|
    ...
    ...    Example:
    ...    | cli_show_default_enable | eutA
    [Tags]    @author=Ronnie_Yi
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    cli show-defaults enable
   [Teardown]    cli    ${device}   end

cli_show_default_disable
    [Arguments]    ${device}
    [Documentation]    enable cli show default
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut|
    ...
    ...    Example:
    ...    | cli_show_default_disable | eutA
    [Tags]    @author=Ronnie_Yi
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    cli show-defaults disable
   [Teardown]    cli    ${device}   end
