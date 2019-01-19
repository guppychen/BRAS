*** Settings ***
Documentation     This test suite is going to verify alarm history can be filtered by each option.
Suite Setup       alarm_setup    n1      n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Library           OperatingSystem
Resource          base.robot
Force Tags        @FEATURE=AXOS-WI-260 Alarms    @author=ssekar

*** Test Cases ***
Alarms_History_Filters
    [Documentation]    Test case verifies alarm history can be filtered by each option.
    ...                1. Generate various alarms and clear conditions. Show alarm history. Default display is to paginate, but pagination can be removed.
    ...                2. Verify the alarm history can be filtered by each option. All alarm history filters show the correct alarms.
    [Tags]   @tcid=AXOS_E72_PARENT-TC-2857   @functional    @priority=P2    @user_interface=CLI      @skip=step_skipped


    Log    *** Alarm history subscope filtering via count, category, severity, and instance-id ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history subscope count          n1         ${total_count}
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history subscope category          n1          ${total_count}
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history subscope severity          n1
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history subscope instance-id              n1         ${total_count}

    Log    *** Alarm history range ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history range        n1         ${total_count}

    Log    *** Alarm history time ***
    #Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history time        n1         ${total_count}
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Verifying alarms filtered by time      n1       ${total_count}      alarm_type=history

    #Log    *** Alarm history source ***
    #Run Keyword And Continue On Failure       Alarm history source       n1        ${portid}

    Log    *** Alarm history filter by id, name, time, instance-id ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history filter using ID       n1         ${total_count}
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history filter using name        n1         ${total_count}
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history filter using instance-id       n1         ${total_count}
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history filter using time     n1         ${total_count}

    Log    *** Alarm history log filter by category and perceived-severity ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history log using category start-value and end-value        n1         ${total_count}
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history log using perceived-severity between time-range and value      n1         ${total_count}

*** Keyword ***
alarm_setup
    [Arguments]    ${device1}    ${device1_linux_mode}      ${DEVICES.n1.ports.p1.port}
    [Documentation]    Triggering alarms on basis of severity

    Log    *** Clearing alarm history logs ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm history logs      ${device1}

    Log    *** Trigerring Alarms ***
    ${portid}    Wait Until Keyword Succeeds      2 min     10 sec     Triggering Loss of Signal MAJOR alarm    device=${device1}      user_interface=cli
    Set Suite Variable    ${portid}     ${portid}
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO    device=${device1}      user_interface=cli
    Wait Until Keyword Succeeds      2 min     10 sec     Trigerring NTP prov alarm     ${device1}
    ${total_count}    Getting Alarm history total count    ${device1}
    Set Suite Variable    ${total_count}    ${total_count}

    Log    *** Clearing Alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing NTP prov alarm     ${device1}
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing Loss of Signal MAJOR alarm     device=${device1}      user_interface=cli
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm     device=${device1}      user_interface=cli



