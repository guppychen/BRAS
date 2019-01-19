*** Settings ***
Documentation     This test suite is going to verify alarm history can be filtered by each option.
Suite Setup       alarm_setup    n1_netconf      n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Library           OperatingSystem
Resource          base.robot
Force Tags

*** Test Cases ***
Alarms_History_Filters
    [Documentation]    Test case verifies alarm history can be filtered by each option.
    ...                1. Generate various alarms and clear conditions. Show alarm history. Default display is to paginate, but pagination can be removed.
    ...                2. Verify the alarm history can be filtered by each option. All alarm history filters show the correct alarms.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2858    @functional    @priority=P2    @user_interface=netconf     @skip=step_skipped


    Log    *** Alarm history subscope filtering via count, category, severity, and instance-id ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history subscope count using netconf         n1_netconf         ${total_count}
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history subscope category using netconf         n1_netconf          ${total_count}

    Log    *** Verifying Active alarms filtered by each severity ***
    @{total_severities}     Create List     CRITICAL   MAJOR   MINOR   INFO    WARNING    CLEAR     INFO
    : FOR    ${severity}    IN    @{total_severities}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarm filtered by severity using netconf    n1_netconf    history     ${severity}

    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history subscope instance-id using netconf       n1_netconf         ${total_count}

    Log    *** Alarm history range ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history range using netconf       n1_netconf         ${total_count}

    Log    *** Alarm history time ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Verifying alarms filtered by time using netconf        n1_netconf         ${total_count}    history

    #Log    *** Alarm history source ***
    #Run Keyword And Continue On Failure       Alarm history source using netconf       n1_netconf        ${portid}

    Log    *** Alarm history filter by id, name, time, instance-id ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history filter netconf      n1_netconf         ${total_count}    parameter=id
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history filter netconf      n1_netconf         ${total_count}    parameter=name
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history filter netconf      n1_netconf         ${total_count}    parameter=instance-id
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history filter netconf      n1_netconf         ${total_count}    parameter=time

    Log    *** Alarm history log filter by category and perceived-severity ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history log using category start-value and end-value in netconf        n1_netconf         ${total_count}
    Wait Until Keyword Succeeds    30 seconds    5 seconds       Alarm history log using perceived-severity start-value and end-value in netconf      n1_netconf         ${total_count}

*** Keyword ***
alarm_setup
    [Arguments]    ${device1}    ${device1_linux_mode}      ${DEVICES.n1.ports.p1.port}
    [Documentation]    Triggering alarms on basis of severity

    Log    *** Clearing alarm history logs ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm history logs using netconf      ${device1}

    Log    *** Trigerring Alarms ***
    ${portid}    Wait Until Keyword Succeeds      2 min     10 sec     Triggering Loss of Signal MAJOR alarm    device=${device1}      user_interface=netconf
    Set Suite Variable    ${portid}     ${portid} 
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO    device=${device1}      user_interface=netconf
    Wait Until Keyword Succeeds      2 min     10 sec     Trigerring NTP prov alarm netconf       device=${device1}
    ${total_count}    Getting Alarm history total count using netconf   ${device1}
    Set Suite Variable    ${total_count}    ${total_count}

    Log    *** Clearing Alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing NTP prov alarm netconf     ${device1}
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing Loss of Signal MAJOR alarm     device=${device1}      user_interface=netconf
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm     device=${device1}      user_interface=netconf


