*** Settings ***
Documentation     This test suite is going to verify whether the alarms can be filtered using key and value in netconf
Suite Setup       alarm_setup    n1_sh     n1_netconf
Suite Teardown    alarm_teardown    n1_sh    n1_netconf
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support   @author=ssekar

*** Test Cases ***
Filtering_alarm_instances_by_address
    [Documentation]    Test case verifies Active alarms filtered by address using key and value
    ...                1.Create active alarms. Alarm should be shown in active alarms log. show alarms active
    ...                2 Filter the alarm using the address key. Only those alarm should be displayed. show alarm active address key
    ...                3 Repeat 1& 2 using value instead of key Only the alarms with the correct value should be shown. show alarm active address
    [Tags]           @tcid=AXOS_E72_PARENT-TC-2840    @functional    @priority=P2    @user_interface=netconf

    Log         *** Filtering the alarms by address using key and value ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify alarms filtered by address netconf     n1_netconf      ${port_id}


*** Keyword ***
alarm_setup
    [Arguments]    ${device1_linux_mode}     ${device1}
    [Documentation]     Triggering Loss of Signal MAJOR alarm

    Log    *** Trigerring Loss of Signal MAJOR alarm ***
    ${port_id}     Wait Until Keyword Succeeds      2 min     10 sec     Triggering Loss of Signal MAJOR alarm      device=${device1}      user_interface=netconf
    Set Suite Variable    ${port_id}     ${port_id}

alarm_teardown
    [Arguments]    ${device1_linux_mode}     ${device1}
    [Documentation]      Clearing Loss of Signal MAJOR alarm

    Log    *** Clearing Loss of Signal MAJOR alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing Loss of Signal MAJOR alarm       device=${device1}      user_interface=netconf

