*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarm_diagnostic_test_Snmp
    [Documentation]    Testcase to verify the if the events are generated when config file is copied to running-config.
    [Tags]  @jira=AT-5002  dual_card_not_support    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-206    @globalid=2226115    @priority=P1    @user_interface=SNMP
    command    n1_session1    show diagnostic test
    #configure the SNMP v2
    SNMP_v2_setup    n1_session2
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    command    n1_session1    start diagnostic test name ${diagnostic.filename}
    : FOR    ${i}    IN RANGE    50
    \    ${alarms}=    command    n1_session1    show alarm history subscope count 1
    \    ${description}=    String.get lines containing string    ${alarms}    description
    \    ${string}=    String.Fetch From Right    ${description}    description${SPACE}
    \    Exit For Loop If    '${string}' == 'test ENDED - ${SPACE}${diagnostic.filename}'
    #Stop the SNMP trap host.
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    diagnostic
    Should contain    ${snmp_trap}    test ENDED - ${SPACE}${diagnostic.filename}
    Should contain    ${snmp_trap}    Test STARTED -    ${diagnostic.filename}
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarm_diagnostic_test_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarm_diagnostic_test_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session1
    Disconnect    ${DUT}
