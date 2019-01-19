*** Settings ***
Documentation     The EXA device must support SNMPv2c as defined in:
...
...        RFC 1901. Introduction to Community-based SNMPv2
...
...        RFC 3416. Version 2 of SNMP Protocol Operations
...
...        RFC 3417. Transport Mappings
...
...    =================================================================
...
...    SnmpTargetAddrTable
...
...    targe1 udpDomain(1) 192.168.1.100:162 5 0 tag1 param1 nonVolatile(3) active(1)
...
...
...
...    SnmpTargetParamsTable
...
...    param1 SNMPv3(3) USM(3) initial noAuthNoPriv(1) nonVolatile(3) active(1)
...
...
...
...    SnmpNotifyTable
...
...    notification1 tag1 trap(1) nonVolatile(3) active(1)
...
...
...
...    This means that the notification1 entry in snmpnotifytable means traps are sent to the target1 per corresponding tag match in snmptargetaddrtable which then says the notification will use param1 entry from snmptargetparamstable for sending the trap.
...
...
...    Purpose
...    ========
...
...    Verify the SNMP Target Addr Table is correct in the SNMPTarget MIB.
Force Tags     @author=sdas    @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot


*** Variables ***
${snmp_version}    v3
${testuser1}   testuser1
${test_protocol}    MD5
${test_priv}     AES
${key}      userkey1234
${trap_ip}    1.1.1.1
${trap_type_1}   trap
${security_level_1}   authNoPriv


*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_SNMPMIB_SNMPTargetMIB_SNMPTargetAddrTable
    [Documentation]    Action	Expected Result	Notes
    ...    1	Configure various snmp users and traphosts via the cli, and verify the information in the SNMPTargetAddrTable.	Informaiton in table is correct.
    [Tags]       @author=sdas     @TCID=AXOS_E72_PARENT-TC-1704
    [Teardown]   AXOS_E72_PARENT-TC-1704 teardown
    log    STEP:Action Expected Result Notes

    log    STEP:1 Configure various snmp users and traphosts via the cli, and verify the information in the SNMPTargetAddrTable. Informaiton in table is correct.

    # Configuring SNMPV3 user
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}  ${DEVICES.n_snmp_v3.authentication_protocol}
    ...         ${DEVICES.n_snmp_v3.password}  ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}

    # Configuring trap host
    Configure V3 trap    n1_session1    ${DEVICES.n1_session1.ip}    ${DEVICES.n_snmp_v3.username}    trap-type=${trap_type}    retries=${retries}    timeout=${timeout}    security-level=${security_level}

    # Configure snmpv3 user1  with trap-host
    Configure SNMPv3    n1_session1    ${admin_state}   ${testuser1}    ${test_protocol}    ${key}   ${test_priv}  ${key}

    # Configuring trap host for user1
    Configure V3 trap    n1_session1    ${trap_ip}    ${testuser1}    trap-type=${trap_type_1}   security-level=${security_level_1}

    # Get SNMP Trap info from MIB
    ${trap_type_tb}    Get SNMP table Element   n_snmp_v3     SNMP-NOTIFICATION-MIB::snmpNotifyTable    ${trap_type}
    ${timeout_tb}    Get SNMP table Element   n_snmp_v3     SNMP-TARGET-MIB::snmpTargetAddrTable    ${timeout}
    ${retries_tb}    Get SNMP table Element   n_snmp_v3     SNMP-TARGET-MIB::snmpTargetAddrTable    ${retries}
    ${security_level_tb}    Get SNMP table Element   n_snmp_v3     SNMP-TARGET-MIB::snmpTargetParamsTable    ${security_level}
    ${trap_ip_tb}    Get trap-host ip from SNMP table   n_snmp_v3     SNMP-NOTIFICATION-MIB::snmpNotifyTable    ${DEVICES.n1_session1.ip}

    # Get SNMP Trap info from MIB for user2
    ${trap_type_tb_1}    Get SNMP table Element   n_snmp_v3     SNMP-NOTIFICATION-MIB::snmpNotifyTable    ${trap_type_1}
    ${security_level_tb_1}    Get SNMP table Element   n_snmp_v3     SNMP-TARGET-MIB::snmpTargetParamsTable    ${security_level_1}
    ${trap_ip_tb_1}    Get trap-host ip from SNMP table   n_snmp_v3     SNMP-NOTIFICATION-MIB::snmpNotifyTable    ${trap_ip}

    # Get SNMP Trap info from CLI for 'snmptest' user
    ${security_level_cli}    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   security-level
    ${timeout_cli}    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   timeout
    ${retries_cli}    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   retries
    ${trap_type_cli}    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   trap-type
    @{trap_ip_cli}    Get Trap-host ip   n1_session1   ${snmp_version}  trap-host

    # Get SNMP Trap info from CLI for user2
    ${security_level_cli_1}    Get Trap-host Element   n1_session1   ${snmp_version}   ${trap_ip}    security-level

    # Verify if data from MIB and CLI are same for snmp test user
    Should Be true    '${security_level_tb}' == '${security_level_cli}'
    Should Be true    '${trap_type_tb}' == '${trap_type_cli}'
    Should Be true    '${timeout_tb}' == '${timeout_cli}'
    Should Be true    '${retries_tb}' == '${retries_cli}'
    List should contain value    ${trap_ip_cli}     ${trap_ip_tb}

    # Verify if data from MIB and CLI are same for user2
    Should Be true    '${security_level_tb_1}' == '${security_level_cli_1}'
    Should Be true    '${trap_type_tb_1}' == '${trap_type_1}'
    List should contain value    ${trap_ip_cli}     ${trap_ip_tb_1}


*** Keywords ***

AXOS_E72_PARENT-TC-1704 teardown
    [Documentation]    Entering teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1704 teardown

    #To remove snmp v3 user and its trap-host
    Remove V3 trap   n1_session1    ${DEVICES.n_snmp_v3.ip}     ${DEVICES.n_snmp_v3.username}
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}

    # To remove snmpV3 user1 and its trap-host
    Remove V3 trap   n1_session1    ${trap_ip}     ${testuser1}
    Remove SNMPv3    n1_session1    ${admin_state}    ${testuser1}


Get trap-host ip from SNMP table
    [Arguments]   ${conn}    ${table}    ${parameter}
    [Documentation]   Getting element
    ...    Example:
    ...    Get trap-host ip from SNMP table   n_snmp_v3     SNMP-NOTIFICATION-MIB::snmpNotifyTable    ${trap_ip}
    [Tags]    @author=sdas
    @{value_list}   Create List
    ${parameter}    convert to string    ${parameter}
    @{output}    snmp Walk   ${conn}     ${table}
    : FOR    ${arg}    IN    @{output}
    \    ${key}    ${value}=    Evaluate    "${arg}".split(",")
    \    ${value}=     Strip String    ${value}    mode=both    characters=)'\u
    \    ${value}=     Remove String Using Regexp    ${value}    [\\s\']    ${EMPTY}
    \    ${ip}=   Get regexp matches    ${value}   \\d+.([0-9\.]+)    1
    \    Run Keyword If   '${parameter}' == '${ip[0]}'   Exit For Loop
    \    ...     ELSE    Continue For Loop
    \    Exit For Loop
    [Return]    ${ip[0]}

Get Trap-host ip
    [Arguments]   ${conn}    ${snmp_version}    ${parameter}
    [Documentation]   Getting element from the cli output of  Show Running-config
    ...    Example:
    ...    Get Trap-host ip   n1_session1   ${snmp_version}  trap-host
    [Tags]    @author=sdas

    ${result}    cli    ${conn}   show running-config snmp ${snmp_version} trap-host
    ${res}    Build Response Map    ${result}
    ${resp}    Parse Nested Text    ${res}
    ${res}    Get Value List From Nested Text    ${resp}   snmp   ${snmp_version}  ${parameter}
    [Return]    @{res}
