*** Settings ***
Documentation    test_suite keyword lib

*** Variable ***


*** Keywords ***
snmpv3_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Philar Guo
    cli    ${eut}    config
    cli    ${eut}    snmp
    Axos Cli With Error Check    ${eut}    v3 admin-state ${admin}
    [Teardown]    cli    ${eut}    end

prov_snmpv3_user
    [Arguments]    ${eut}    ${username}    ${auth_prot}=${EMPTY}    ${auth_key}=${EMPTY}    ${priv_prot}=${EMPTY}    ${priv_key}=${EMPTY}   &{dict_cmd}
    [Tags]    @author=Philar Guo
    cli    ${eut}    configure
    Axos Cli With Error Check    ${eut}    snmp v3 user ${username}
    run keyword if    '${auth_prot}'!='${EMPTY}'    Axos Cli With Error Check    ${eut}    authentication protocol ${auth_prot} key ${auth_key}
    run keyword if    '${priv_prot}'!='${EMPTY}'    Axos Cli With Error Check    ${eut}    privacy protocol ${priv_prot} key ${priv_key}
    ${cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${eut}    ${cmd_str}
    [Teardown]    cli    ${eut}    end

delete_snmpv3_user
    [Arguments]    ${eut}    ${username}
    [Tags]    @author=Philar Guo
    cli    ${eut}    config
    cli    ${eut}    snmp
    Axos Cli With Error Check   ${eut}    no v3 user ${username}
    [Teardown]    cli    ${eut}    end

prov_snmpv3_trap_host
    [Arguments]    ${eut}    ${trap_host}    ${username}   ${secu_level}=${EMPTY}    ${trap_type}=${EMPTY}    ${retries}=${EMPTY}   ${timeout}=${EMPTY}    &{dict_cmd}
    [Tags]    @author=Philar Guo
    cli    ${eut}    config
    Axos Cli With Error Check    ${eut}    snmp v3 trap-host ${trap_host} ${username}
    run keyword if    '${secu_level}'!='${EMPTY}'    Axos Cli With Error Check    ${eut}    security-level ${secu_level}
    run keyword if    '${trap_type}'!='${EMPTY}'    Axos Cli With Error Check    ${eut}    trap-type ${trap_type}
    run keyword if    '${retries}'!='${EMPTY}'    Axos Cli With Error Check    ${eut}    retries ${retries}
    run keyword if    '${timeout}'!='${EMPTY}'    Axos Cli With Error Check    ${eut}    timeout ${timeout}
    ${cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${eut}    ${cmd_str}
    [Teardown]    cli    ${eut}    end

delete_snmpv3_trap_host
    [Arguments]    ${eut}    ${trap_host}   ${username}
    [Tags]    @author=Philar Guo
    cli    ${eut}    config
    cli    ${eut}    snmp
    Axos Cli With Error Check   ${eut}    no v3 trap-host ${trap_host} ${username}
    [Teardown]    cli    ${eut}    end

generate_pcap_name
    [Arguments]          ${case_name}
    [Documentation]      generate pcap file name with case name
    [Tags]               @author=WanlinSun
    ${pcap_name}    Set Variable    /tmp/${case_name}_pkt.pcap
    [Return]    ${pcap_name}