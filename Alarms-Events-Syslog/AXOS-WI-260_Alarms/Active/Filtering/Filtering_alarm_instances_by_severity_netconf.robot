*** Settings ***
Documentation     This test suite is going to verify whether the alarms can be filtered by severity.
Suite Setup       alarm_setup    n1_sh    n1_netconf    ${DEVICES.n1.ports.p1.port}
Suite Teardown    alarm_teardown    n1_sh    n1_netconf    ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support    @author=ssekar

*** Test Cases ***

Filtering_alarm_instances_by_severity
    [Documentation]    Test case verifies Active alarms filtered by severity
    ...                1.Trigger an alarm based on severity
    ...                2.Filter on severity MINOR and verify the active alarms shows all alarms with severity of MINOR and above. All MINOR and above alarms are shown using the filter.
    [Tags]        @user=root   @tcid=AXOS_E72_PARENT-TC-2844    @functional    @priority=P2      @user_interface=netconf

    Log    *** Verifying Active alarms filtered by each severity ***
    @{total_severities}     Create List     CRITICAL   MAJOR   MINOR   INFO    WARNING    CLEAR     INFO
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity using netconf    n1_netconf    active     ${severity}

*** Keyword ***
alarm_setup
    [Arguments]        ${device_linux}      ${device_netconf}      ${DEVICES.n1.ports.p1.port}
    [Documentation]    Triggering alarms on basis of severity

    Log    *** Trigerring one CRITICAL alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering CRITICAL alarm      ${device_linux}       ${device_netconf}      netconf

    Log    *** Trigerring one MINOR Alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering RMON MINOR alarm     ${device_linux}       ${device_netconf}     netconf
  
    Log    *** Triggering anyone INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO    ${device_netconf}      ${device_linux}      netconf

alarm_teardown
    [Arguments]       ${device_linux}    ${device_netconf}     ${DEVICES.n1.ports.p1.port}
    [Documentation]    Clearing alarms

    Log    *** Clearing CRITICAL alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing CRITICAL alarm     ${device_linux}       ${device_netconf}      netconf

    Log    *** Clearing the created RMON MINOR Alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing RMON MINOR alarm       ${device_linux}       ${device_netconf}     netconf

    Log    *** Clearing the created INFO Alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm       ${device_netconf}      ${device_linux}     netconf
