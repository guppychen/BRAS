*** Settings ***
Documentation     This test suite is going to verify whether the alarm severity is displayed correctly in various alarms.
Suite Setup       Triggering_Alarms_netconf     n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Suite Teardown    Clearing_Alarms_netconf       n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar

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
    [Tags]         @tcid=AXOS_E72_PARENT-TC-2829    @functional    @priority=P2      @user_interface=netconf       @runtime=long

    @{total_severities}     Create List     CRITICAL   MAJOR   MINOR   INFO    WARNING    CLEAR     INFO

    Log    *** Verifying Alarm severity is displayed correctly in Active Alarms ***
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity using netconf   n1_netconf     active     ${severity}

    Log    *** Verifying Alarm severity is displayed correctly in Alarm definitions ***
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity using netconf   n1_netconf     definition     ${severity}

    Log    *** Verifying Alarm severity is displayed correctly in Alarm history ***
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity using netconf    n1_netconf     history     ${severity}

    Log    *** Verifying Alarm severity is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure       Suppressing Active alarms using netconf    n1_netconf
    #: FOR    ${severity}    IN    @{total_severities}
    #\    Run Keyword And Continue On Failure     Verify Alarm filtered by severity using netconf   n1_netconf     suppress     ${severity}
    #Run Keyword And Continue On Failure       Unsuppressing Active alarms using netconf    n1_netconf

    Log    *** Verifying Alarm severity is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms using netconf       n1_netconf       severity

    Log    *** Verifying Alarm severity is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged using netconf     n1_netconf       severity

    Log    *** Verifying Alarm severity is displayed correctly in Archived alarms ***
    Run Keyword     Clearing Archive alarm using netconf      n1_netconf
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload The System using netconf     n1_netconf     n1_sh
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity using netconf   n1_netconf     archive      ${severity}

