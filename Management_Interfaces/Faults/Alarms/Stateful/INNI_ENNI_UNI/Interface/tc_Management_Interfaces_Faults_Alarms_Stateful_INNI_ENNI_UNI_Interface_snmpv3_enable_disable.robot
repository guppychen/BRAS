*** Settings ***
Documentation     The EXA device MUST be able to enable and disable SNMPv3 support.
Force Tags        @author=nphilip    @feature=SNMP   @subfeature=SNMP Support
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Faults_Alarms_Stateful_INNI_ENNI_UNI_Interface_snmpv3_enable_disable
    [Documentation]    1	Configure SNMPv3 user and enable.		
    ...    2	Connect to agent from SNMP manager tool.	Connection is successful.	
    ...    3	Disable SNMPv3 and verify the agent no longer responds to manager.	Agent no longer responds.	
    ...    4	Try to connect the agent again while snmpv3 is disabled.	Connection is not successful.
    [Tags]       @author=nphilip     @tcid=AXOS_E72_PARENT-TC-2886
    [Setup]      RLT-TC-702 setup
    [Teardown]   RLT-TC-702 teardown


    log    STEP:2 Connect to agent from SNMP manager tool. Connection is successful.
    cli   n1_session1  show running-config snmp
    ${result}    snmp get    n_snmp_v3    sysName

    log    STEP:3 Disable SNMPv3 and verify the agent no longer responds to manager. Agent no longer responds.
    cli    n1_session1    conf
    cli    n1_session1    snmp v3 admin-state disable user ${DEVICES.n_snmp_v3.username}
    cli    n1_session1    end

    cli   n1_session1  show running-config snmp v3
    Result Should Not Contain    v3 admin-state enable

    log    STEP:4 Try to connect the agent again while snmpv3 is disabled. Connection is not successful.
    Run Keyword And Expect Error   SNMP GET failed: No SNMP response received before timeout    snmp get    n_snmp_v3    sysName


*** Keywords ***
RLT-TC-702 setup
    [Documentation]
    [Arguments]
    log    Enter RLT-TC-702 setup

    log    STEP:1 Configure SNMPv3 user and enable.
    Configure SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}    ${DEVICES.n_snmp_v3.authentication_protocol}
    ...    ${DEVICES.n_snmp_v3.password}    ${DEVICES.n_snmp_v3.encryption_protocol}    ${DEVICES.n_snmp_v3.encryption_password}


RLT-TC-702 teardown
    [Documentation]
    [Arguments]
    log    Enter RLT-TC-702 teardown

    Remove SNMPv3    n1_session1    ${admin_state}    ${DEVICES.n_snmp_v3.username}
