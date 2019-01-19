*** Settings ***
Documentation     The EXA device MUST not support SNMPv1
...    Purpose
...    =======
...    The EXA device MUST not support SNMPv1
Force Tags        @author=nphilip        @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_INNI_ENNI_UNI_Interface_snmpv1_Notsupported
    [Documentation]    1	Verify you can't configure an SNMPv1 user.	No configuration options for SNMPv1.	
    ...    2	Verify you can't connect to the agent using SNMPv1.	Can not connect with SNMPv1.	
    ...    3	Verify when receiving an SNMPv1 request, the SNMP agent discards as unsupported pdu and increments the SNMP MIB snmpInBadVersions Counter.	Counter is incremented.
    [Tags]       @author=nphilip     @TCID=AXOS_E72_PARENT-TC-1724
    [Setup]      AXOS_E72_PARENT-TC-1724 setup
    [Teardown]   AXOS_E72_PARENT-TC-1724 teardown
    log    STEP:1 Verify you can't configure an SNMPv1 user. No configuration options for SNMPv1.

    cli    n1_session1    conf
    cli    n1_session1    SNMP ?
    Result should not contain    v1

    log    STEP:2 Verify you can't connect to the agent using SNMPv1. Can not connect with SNMPv1.

    ${conn}=    Session copy info     n_snmp_v2    version=v1
    Run Keyword And Expect Error    SnmpError: Unknown SNMP version: 'v1'. Supported versions: '2c', '3'    Session build local   n_snmp_v1    ${conn}

    log    STEP:3 Verify when receiving an SNMPv1 request, the SNMP agent discards as unsupported pdu and increments the SNMP MIB snmpInBadVersions Counter. Counter is incremented.


*** Keywords ***
AXOS_E72_PARENT-TC-1724 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1724 setup
    Configure SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}


AXOS_E72_PARENT-TC-1724 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1724 teardown
    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}
