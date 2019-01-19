*** Settings ***
Documentation     The EXA device must support SNMPv2c as defined in:
...        RFC 1901. Introduction to Community-based SNMPv2
...        RFC 3416. Version 2 of SNMP Protocol Operations
...        RFC 3417. Transport Mappings
...     ========================================================
...    SnmpTargetAddrTable
...    targe1 udpDomain(1) 192.168.1.100:162 5 0 tag1 param1 nonVolatile(3) active(1)
...    SnmpTargetParamsTable
...    param1 SNMPv3(3) USM(3) initial noAuthNoPriv(1) nonVolatile(3) active(1)
...    SnmpNotifyTable
...    notification1 tag1 trap(1) nonVolatile(3) active(1)
...    This means that the notification1 entry in snmpnotifytable means traps are sent to the target1 per corresponding tag match in snmptargetaddrtable which then says the notification will use param1 entry from snmptargetparamstable for sending the trap. 
...    Purpose
...    ========
...    Verify the SNMPNotifyTable information is correct in the SNMP Notification MIB.
Resource          ./base.robot
Force Tags    @author=lpaul    @feature=SNMP   @subfeature=SNMP Support


*** Variables ***
${snmp_version}    v${DEVICES.n_snmp_v3.version}


*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_SNMPMIB_SNMPNotificationMIB_SNMPNotifyTable
    [Documentation]    1	Configure various snmp users and traphosts via the cli, and verify the information in the SNMPNotifyTable.	Information in SNMPNotifyTable is correct.	
    [Tags]       @author=lpaul     @TCID=AXOS_E72_PARENT-TC-1706
    [Setup]      AXOS_E72_PARENT-TC-1706 setup
    [Teardown]   AXOS_E72_PARENT-TC-1706 teardown

    # Configuring trap host
    Configure V3 trap    n1_session1    ${DEVICES.n1_session1.ip}    ${DEVICES.n_snmp_v3.username}
    ...    trap-type=${trap_type}    retries=${retries}    timeout=${timeout}    security-level=${security_level}

    # Get SNMP Trap info from MIB
    ${trap_type_tb}    Get SNMP table Element   n_snmp_v3     SNMP-NOTIFICATION-MIB::snmpNotifyTable    ${trap_type}
    ${timeout_tb}    Get SNMP table Element   n_snmp_v3     SNMP-TARGET-MIB::snmpTargetAddrTable    ${timeout}
    ${retries_tb}    Get SNMP table Element   n_snmp_v3     SNMP-TARGET-MIB::snmpTargetAddrTable    ${retries}
    ${security_level_tb}    Get SNMP table Element   n_snmp_v3     SNMP-TARGET-MIB::snmpTargetParamsTable    ${security_level}

    # Get SNMP Trap info from CLI
    ${security_level_cli}    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   security-level
    ${timeout_cli}    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   timeout
    ${retries_cli}    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   retries
    ${trap_type_cli}    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   trap-type

    # Verify if data from MIB and CLI are same
    Should Be true    '${security_level_tb}' == '${security_level_cli}'
    Should Be true    '${trap_type_tb}' == '${trap_type_cli}'
    Should Be true    '${timeout_tb}' == '${timeout_cli}'
    Should Be true    '${retries_tb}' == '${retries_cli}'


*** Keywords ***
AXOS_E72_PARENT-TC-1706 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1706 setup
    log    STEP:1 Configure various snmp users and traphosts via the cli, and verify the information in the SNMPNotifyTable. Information in SNMPNotifyTable is correct.
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}    ${DEVICES.n_snmp_v3.authentication_protocol}   ${DEVICES.n_snmp_v3.password}   ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}

Get SNMP table Element
    [Arguments]   ${conn}    ${table}    ${parameter}
    [Documentation]   Getting element
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
    [Documentation]   Getting element from the cli output of  Show Running-config
    [Arguments]   ${conn}    ${snmp_version}   ${trap_host_ip}   ${parameter}

    ${result}    cli    ${conn}   show running-config snmp ${snmp_version} trap-host ${trap_host_ip}
    ${res}    Build Response Map    ${result}
    ${resp}    Parse Nested Text    ${res}    start_line=3
    ${res}    Get Value From Nested Text    ${resp}    ${parameter}
    [Return]    ${res}


AXOS_E72_PARENT-TC-1706 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1706 teardown

    Remove V3 trap    n1_session1    ${DEVICES.n1_session1.ip}    ${DEVICES.n_snmp_v3.username}
    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}
