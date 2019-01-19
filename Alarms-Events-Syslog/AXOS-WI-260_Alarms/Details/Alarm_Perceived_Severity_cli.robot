*** Settings ***
Documentation     This test suite is going to verify whether the alarm severity is displayed correctly in various alarms.
Suite Setup       alarm_setup      n1_sh        n1        ${DEVICES.n1.ports.p1.port}
Suite Teardown    alarm_teardown      n1_sh      n1        ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar    @reload

*** Test Cases ***

Alarm_Perceived_Severity
    [Documentation]    Test case verifies alarm severity is displayed correctly in various alarms.
    ...                1.Verify the field is correct in the alarm definition. show alarm definition subscope perceived-severity X
    ...                2.Verify the field is correct in the active alarm. show alarm active subscope perceived-severity X
    ...                3.Verify the field is correct in the alarm history. show alarm history subscope perceived-severity X
    ...                4.Verify the field is correct in the suppressed alarm. show alarm suppressed subscope perceived-severity X
    ...                5.Verify the field is correct in the shelved alarm. show alarm shelved subscope perceived-severity X
    ...                6.Verify the field is correct in the archive alarm. show alarm archive subscope perceived-severity X
    ...                7.Verify the field is correct in the acknowledged alarm. show alarm acknowledged subscope perceived-severity X
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2829    @functional    @priority=P2      @user_interface=CLI      @runtime=long

    @{total_severities}     Create List     CRITICAL   MAJOR   MINOR   INFO    WARNING    CLEAR     INFO

    Clearing alarm history logs      n1

    Log    *** Verifying Alarm severity is displayed correctly in Active Alarms ***
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity    n1     active     ${severity}

    Log    *** Verifying Alarm severity is displayed correctly in Alarm definitions ***
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity    n1     definition     ${severity}

    Log    *** Verifying Alarm severity is displayed correctly in Alarm history ***
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity    n1     history     ${severity}

    Log    *** Verifying Alarm severity is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure       Suppressing Active alarms      n1
    #: FOR    ${severity}    IN    @{total_severities}
    #\    Run Keyword And Continue On Failure       Verify Alarm filtered by severity    n1     suppress     ${severity}
    #Run Keyword And Continue On Failure     Unsuppressing Active alarms    n1

    Log    *** Verifying Alarm severity is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms    n1       severity      shelved_runningconfig_unsaved

    Log    *** Verifying Alarm severity is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged     n1       severity

    Log    *** Verifying Alarm severity is displayed correctly in Archived alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing CRITICAL alarm      n1_sh      n1      user_interface=cli
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing Archive alarm      n1
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload     n1
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity    n1     archive      ${severity}

*** Keyword ***
alarm_setup
    [Arguments]        ${device_linux}      ${device}       ${port}
    [Documentation]    Triggering alarms on basis of severity

    Log    *** Trigerring one CRITICAL alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering CRITICAL alarm      ${device_linux}       ${device}      user_interface=cli

    Log    *** Trigerring one MINOR Alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering RMON MINOR alarm     ${device_linux}       ${device}      user_interface=cli

    Log    *** Triggering Loss of Signal MAJOR alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering Loss of Signal MAJOR alarm       ${device}    ${device_linux}     user_interface=cli

    Log    *** Trigerring one INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO    ${device}     ${device_linux}      user_interface=cli

alarm_teardown
    [Arguments]       ${device_linux}    ${device}     ${port}
    [Documentation]    Clearing alarms

    Log    *** Clearing the created RMON MINOR Alarm ***
    Run Keyword And Continue On Failure      Clearing RMON MINOR alarm    ${device_linux}    ${device}      user_interface=cli

    Log    *** Clearing Loss of Signal MAJOR alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing Loss of Signal MAJOR alarm       device=${device}      linux=${device_linux}     user_interface=cli

    Log    *** Clearing the created INFO Alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm    ${device}    ${device_linux}     user_interface=cli

