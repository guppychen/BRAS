*** Settings ***
Resource          caferobot/cafebase.robot
Library           Collections
Library           String
Library           DateTime
Library           OperatingSystem

*** Keywords ***
Configure SNMPv2
    [Arguments]    ${conn}    ${admin_state}    ${community}
    [Documentation]    To configure SNMP on device
    ...    Example:
    ...    Configure SNMPv2   n1_session1   enable   public
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v2 admin-state ${admin_state}
    cli    ${conn}    snmp v2 community ${community} ro
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v2|nomore    \\#    30
    Result should contain    v2 community ${community} ro

Remove SNMPv2
    [Arguments]    ${conn}    ${admin_state}    ${community}
    [Documentation]    To remove SNMP on device
    ...    Example:
    ...    Remove SNMPv2   n1_session1   disable   public
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v2 admin-state ${admin_state}
    cli    ${conn}    no v2 community ${community} ro
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v2|nomore    \\#    30
    Result should not contain    v2 community ${community} ro

Configure SNMPv3
    [Arguments]    ${conn}    ${admin_state}    ${user}    ${auth}=NONE    ${auth_key}=${EMPTY}    ${priv}=NONE    ${priv_key}=${EMPTY}
    [Documentation]    To configure SNMPv3 on device
    ...    Example:
    ...    Configure SNMPv3   n1_session1   enable   snmptest
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v3 admin-state ${admin_state} user ${user}
    
    Run Keyword If    '${auth_key}' != '${EMPTY}'   cli    ${conn}    authentication protocol ${auth} key ${auth_key}
    ...    ELSE IF    '${auth}' != 'NONE'   cli    ${conn}    authentication protocol ${auth}
    ...    ELSE    cli    ${conn}    authentication protocol ${auth}

    Run Keyword If    '${priv_key}' != '${EMPTY}'   cli    ${conn}    privacy protocol ${priv} key ${priv_key}
    ...    ELSE IF    '${priv}' != 'NONE'   cli    ${conn}   privacy protocol ${priv} 
    #...    ELSE    cli    ${conn}    privacy protocol ${priv}

    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v3|nomore    \\#    30
    Result should contain    v3 user ${user}

Configure V3 trap
    [Arguments]    ${conn}    ${server_ip}     ${user}     @{items}
    [Documentation]    To configure SNMPv3 trap on device
    ...    Example:
    ...    Configure V3 trap    n1_session1    10.243.83.111    snmptest    security-level=authPriv
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v3 trap-host ${server_ip} ${user}
    : FOR    ${arg}    IN    @{items}
    \    ${key}    ${value}=    Evaluate    "${arg}".split("=")
    \    Log    ${key}, ${value}
    \    cli    ${conn}    ${key} ${value}     \\#    30
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v3 trap-host|nomore    \\#    30
    Result should contain    v3 trap-host ${server_ip} ${user}

Get SNMP table Element
    [Arguments]   ${conn}    ${table}    ${parameter}
    [Documentation]   Getting element
    ...    Example:
    ...    Get SNMP table Element    n_snmp_v3     SNMP-NOTIFICATION-MIB::snmpNotifyTable    ${trap_type}
    [Tags]    @author=clakshma
    @{value_list}   Create List
    ${parameter}    convert to string    ${parameter}
    @{output}    snmp Walk   ${conn}     ${table}
    : FOR    ${arg}    IN    @{output}
    \    ${key}    ${value}=    Evaluate    "${arg}".split(",")
    \    ${value}=     Strip String    ${value}    mode=both    characters=)'\u
    \    ${value}=     Remove String Using Regexp    ${value}    [\\s\']    ${EMPTY}
    \    ${val}    Get Count    ${value}    ${parameter}
    \    Run Keyword If   '${parameter}' == '${value}'    Exit For Loop
    \    ...    ELSE    Continue For Loop
    \    Exit For Loop
    [Return]    ${value}

Get Trap-host Element
    [Arguments]   ${conn}    ${snmp_version}   ${trap_host_ip}    ${parameter}
    [Documentation]   Getting element from the cli output of  Show Running-config
    ...    Example:
    ...    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   timeout
    [Tags]    @author=clakshma

    ${result}    cli    ${conn}   show running-config snmp ${snmp_version} trap-host ${trap_host_ip}
    ${res}    Build Response Map    ${result}
    ${resp}    Parse Nested Text    ${res}    start_line=3
    ${res}    Get Value From Nested Text    ${resp}    ${parameter}
    [Return]    ${res}

Remove SNMPv3
    [Arguments]    ${conn}    ${admin_state}    ${user}
    [Documentation]    To remove SNMPv3 on device
    ...    Example:
    ...    Remove SNMPv3   n1_session1   disable   snmptest
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v3 admin-state ${admin_state}
    cli    ${conn}    no v3 user ${user}
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v3|nomore    \\#    30
    Result should not contain    v3 user ${user}

Remove V3 trap
    [Arguments]    ${conn}    ${server_ip}     ${user}
    [Documentation]    To remove SNMPv3 trap on device
    ...    Example:
    ...    Remove V3 trap    n1_session1    10.243.83.111    snmptest
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v3 admin-state enable
    cli    ${conn}    no v3 trap-host ${server_ip} ${user}
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v3 trap-host|nomore    \\#    30
    Result should not contain    v3 trap-host ${server_ip} ${user}

ping_dpu
    [Arguments]    ${session}    ${device_ip}    ${timeout}=30
    [Documentation]  Check if DPU is reachable
    ...    Example:
    ...    ping_dpu    n1_session1    10.243.83.111
    [Tags]    @author=clakshma
    ${ret}    Session Command    h1    ${SPACE}
    ${prompt}    get last command prompt    h1
    ${prompt}    regexp escape  ${prompt}
    ${res}    cli    ${session}    ping ${device_ip} -c 4    ${prompt}    ${timeout}
    should Match Regexp      ${res}    ,\\s0% packet loss

Validate MIB Result
    [Arguments]    ${output}    ${parameter}
    [Documentation]   Verify the alarm is present in the MIB result
    ...    Example:
    ...    Validate MIB Result    ${output}    ONT has arrived on PON port
    [Tags]    @author=lpaul
    : FOR    ${var}    IN    @{output}
    \    ${var}    Convert To String    ${var}
    \    ${verify}    Run Keyword If    "${var}" == "${parameter}"    Set Variable    True
    \    Run Keyword If    "${verify}" == "True"    Exit For Loop
    \    ...    ELSE    Continue For Loop
    Log    ${verify}
    [Return]    ${verify}

Configure V2 Trap
    [Arguments]    ${conn}    ${server}    ${community_string}    @{items}
    [Documentation]    Keyword for configuring a V2 trap-host
    ...    Example:
    ...    Configure V2 Trap   n1_session1  10.243.245.23  public  trap-type=inform  timeout=100  retries=6
    [Tags]    @author=ysnigdha
    cli    ${conn}    configure    \\#    30
    cli    ${conn}    snmp v2 trap-host ${server} ${community_string}
    : FOR    ${arg}    IN    @{items}
    \    ${key}    ${value}=    Evaluate    "${arg}".split("=")
    \    Log    ${key}, ${value}
    \    cli    ${conn}    ${key} ${value}     \\#    30
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v2 trap-host | nomore    \\#    30
    Result should contain    v2 trap-host ${server} ${community_string}

Remove V2 trap
    [Arguments]    ${conn}    ${server}     ${community_string}
    [Documentation]    To remove SNMPv3 trap on device
    ...    Example:
    ...    Remove V3 trap    n1_session1    10.243.245.23    public
    [Tags]    @author=ysnigdha
    cli    ${conn}    conf
    cli    ${conn}    snmp v2 admin-state enable
    cli    ${conn}    no v2 trap-host ${server} ${community_string}
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v2 trap-host| nomore    \\#    30
    Result should not contain    v2 trap-host ${server} ${community_string}
