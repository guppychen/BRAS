*** Settings ***
Documentation     The EXA device must support SNMPv2c as defined in:
...        RFC 1901. Introduction to Community-based SNMPv2
...        RFC 3416. Version 2 of SNMP Protocol Operations
...        RFC 3417. Transport Mappings
...    Purpose
...    ========
...    Verify the SNMPEngine table information.
...    snmpEngineID.0
...    snmpEngineBoots.0
...    snmpEngineTime.0
...    snmpEngineMaxMessageSize.0
Force Tags    @author=lpaul    @feature=SNMP   @subfeature=SNMP Support    @reload
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_SNMPv2_SNMPMIB_SNMPFrameworkMIB_SNMPEngine
    [Documentation]    1	Configure SNMPv2 user and enable.	show running snmp	
    ...    2	Connect to agent from SNMP manager tool.	Connection is successful.	
    ...    3	Walk the SNMPv2/SNMPModules/SNMPFrameworkMIB/SNMPEngine table.	Verify the information retrieved is correct for each OID.
    [Tags]       @author=lpaul     @TCID=AXOS_E72_PARENT-TC-1702  @user=root
    [Setup]      AXOS_E72_PARENT-TC-1702 setup
    [Teardown]   AXOS_E72_PARENT-TC-1702 teardown

    log    STEP:3 Walk the SNMPv2/SNMPModules/SNMPFrameworkMIB/SNMPEngine table. Verify the information retrieved is correct for each OID.
    # Verify the SNMPEngine table information snmpEngineID.0
    ${result}    snmp walk    n_snmp_v2    snmpEngine
    ${result}    Snmp Get Display String    n_snmp_v2    snmpEngineID

    # Retrieve the SNMPEngine ID from cli
    ${engine}    cli    n1_session2    cat /etc/snmp/snmpd.conf | grep -i oldEngineID    \\~#    30
    @{engine}    Should Match Regexp    ${engine}     oldEngineID ([0-9a-fx]+)
    should contain    ${result}    @{engine}[1]

    # Verify the SNMPEngine table information snmpEngineMaxMessageSize.0
    ${result}    snmp get    n_snmp_v2    snmpEngineMaxMessageSize
    should contain    ${result}    1500

    # reload system
    reload    n1_session1 
    # cli    n1_session1    reload   y\/N    60
    # cli    n1_session1    y    \\#    60
    sleep    30
    wait until keyword succeeds    10 min    1 min    ping_dpu   h1    ${DEVICES.n1_session1.ip}
    wait until keyword succeeds    5 min    1 min    cli    n1_session1    show version     prompt=#      timeout=30

    # Verify the SNMPEngine table information snmpEngineID.0 after reload
    Configure SNMPv2   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}
    ${result}    snmp walk    n_snmp_v2    snmpEngine
    ${result}    Snmp Get Display String    n_snmp_v2    snmpEngineID

    # Retrieve the SNMPEngine ID from cli
    ${engine}    cli    n1_session2    cat /etc/snmp/snmpd.conf | grep -i oldEngineID    \\~#    30
    @{engine}    Should Match Regexp    ${engine}     oldEngineID ([0-9a-fx]+)
    should contain    ${result}    @{engine}[1]

    # Verify the SNMPEngine table information snmpEngineMaxMessageSize.0
    ${result}    snmp get    n_snmp_v2    snmpEngineMaxMessageSize
    should contain    ${result}    1500


*** Keywords ***
AXOS_E72_PARENT-TC-1702 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1702 setup

    log    STEP:1 Configure SNMPv2 user and enable. show running snmp
    log    STEP:2 Connect to agent from SNMP manager tool. Connection is successful.

    Configure SNMPv2   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}


AXOS_E72_PARENT-TC-1702 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1702 teardown
    Remove SNMPv2   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}
