*** Settings ***
Documentation     This test suite is going to verify whether the active alarms can be acknowledged.
Suite Setup       alarm_setup   n1_local_pc     n1     ${DEVICES.n1_local_pc.ip}      ${DEVICES.n1_local_pc.password}    n1_sh
Suite Teardown    alarm_teardown    n1     ${DEVICES.n1_local_pc.ip}    n1_sh
Library           String
Library           Collections
Library           OperatingSystem
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support    @author=ssekar

*** Test Cases ***

Alarm_acknowledged_status
    [Documentation]    Test case verifies Active alarms is acknowledgeable
    ...                1. Trigger an alarm and find the alarm instance id. show alarm active.
    ...                2. Manually acknowledge the alarm based on the instance id. manual acknowledge instance-id x.x
    ...                3. Verify acknowledged alarm indicates who acknowledged it, when it was acknowledged and why it was acknowledged (Not Supported)
    ...                4. Verify alarm can be unacknowledged.(Not Supported)
    [Tags]   @tcid=AXOS_E72_PARENT-TC-2891   @user=root    @functional    @priority=P2       @user_interface=syslog       @runtime=short

    Log         *** Verifying alarm got acknowledged and logged in syslog server ***
    ${instance-id}    Wait Until Keyword Succeeds      2 min     10 sec     Verify Alarms Get Acknowledged     n1
    #Sleep for 5s
    sleep    5s
    ${ack_time}    Wait Until Keyword Succeeds      2 min     10 sec      Getting Alarm or event time from DUT     n1       ${instance-id}
    Wait Until Keyword Succeeds      2 min     10 sec     Alarms_acknowledge_copy_registered_in_syslog_server      n1     n1_local_pc    ${DEVICES.n1_local_pc.ip}     ${DEVICES.n1_local_pc.password}     ${instance-id}       ${DEVICES.n1.user}      ${ack_time}


*** Keyword ***
alarm_setup
    [Arguments]    ${device_local_pc}    ${device1}    ${syslog_server_ip}     ${user_password}     ${linux}
    [Documentation]         Configure SYSLOG server and Triggering alarm for INFO severity

    Log         *** Configure SYSLOG server on DUT ***
    Wait Until Keyword Succeeds      2 min     10 sec     Configure SYSLOG server on DUT           ${device1}     ${syslog_server_ip}

    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm     ${device1}     ${linux}    user_interface=cli
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm history logs      ${device1}

    Wait Until Keyword Succeeds      2 min     10 sec       Syslog_server_configure_on_local_PC     ${device_local_pc}     ${syslog_server_ip}     ${user_password}

    Log         *** Triggering anyone INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering any one alarm for severity INFO     ${device1}      ${linux}      user_interface=cli

alarm_teardown
    [Arguments]    ${device1}    ${syslog_server_ip}      ${linux}
    [Documentation]        Clearing INFO alarm

    Log         *** Unconfigure SYSLOG server ***
    Wait Until Keyword Succeeds      2 min     10 sec     Unconfigure SYSLOG server on DUT           ${device1}     ${syslog_server_ip}

    Log         *** Clearing INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm     ${device1}     ${linux}      user_interface=cli
