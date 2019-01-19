*** Settings ***
Documentation     The EXA device MUST be able to enable and disable SNMPv2c support
Force Tags    @author=nramalin      @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_Interface_snmpv2_enable_disable
    [Documentation]    1	Configure SNMPv2 user and enable.		
    ...    2	Connect to agent from SNMP manager tool.	Connection is successful.	
    ...    3	Disable SNMPv2 and verify the agent no longer responds to manager.	Agent no longer responds.	
    ...    4	Try to connect the agent again while snmpv2 is disabled.	Connection is not successful.	
    [Tags]       @author=nramalin     @TCID=AXOS_E72_PARENT-TC-1720
    [Setup]      AXOS_E72_PARENT-TC-1720 setup
    [Teardown]   AXOS_E72_PARENT-TC-1720 teardown

    log    STEP:3 Disable SNMPv2 and verify the agent no longer responds to manager. Agent no longer responds.
    cli    n1_session1    conf
    cli    n1_session1    snmp v2 admin-state disable
    cli    n1_session1    end

    log    STEP:4 Try to connect the agent again while snmpv2 is disabled. Connection is not successful.
    ${msg} =  Run Keyword And Expect Error     *   Snmp Walk  n_snmp_v2   .1.3.6.1.2.1.1.1.0 is disabled. Connection is not successful.
    ${match}    Evaluate   "SnmpError: Could not connect to SNMP host ${DEVICES.n1_session1.ip}:161" in '''${msg}''' or "Connection is not successful" in '''${msg}'''
    Should Be True     ${match}

*** Keywords ***
AXOS_E72_PARENT-TC-1720 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1720 setup

    log    STEP:1 Configure SNMPv2 user and enable.
    log    STEP:2 Connect to agent from SNMP manager tool. Connection is successful.
    Configure SNMPv2   n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}


AXOS_E72_PARENT-TC-1720 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1720 teardown

    Remove SNMPv2    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v2.community}
