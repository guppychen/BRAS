*** Settings ***
Documentation
Force Tags     @author=bswamina    @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support
Resource          ./base.robot


*** Test Cases ***
tc_verify_EXA_device_logging_of_alarms_and_events_to_a_terminal_session_is_disabled_by_default
    [Documentation]    1. SSH into the system on the management port and issue the command "show session notifications" and
    ...             Verify the "Session is not registered for notifications" message is displayed.
    [Tags]       @author=bswamina     @TCID=AXOS_E72_PARENT-TC-2426
    reset all sessions
    log    STEP:1. SSH into the system on the management port and issue the command "show session notifications" and Verify the "Session is not registered for notifications" message is displayed.
    # modify by llin for ticket AT-2854 2017.9.11
    wait until keyword succeeds    1 min    10 sec    check notification

*** Keywords ***
check notification
	[Arguments]
	[Documentation]     [Author:chxu] Description: check show session notifications
    cli  n1_session1  show session notifications
    result should contain   no severity sessions
    result should contain   no category sessions