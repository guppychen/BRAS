*** Settings ***
Documentation     This test suite is going to verify whether the alarms from category PORT can be triggered and cleared 
Suite Setup       alarm_setup       n1     ${DEVICES.n1_local_pc.ip}     n1_sh
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags


*** Test Cases ***

Active_Category_Port
    [Documentation]    Test case verifies alarms from category PORT can be triggered and cleared
    ...    (Alarms : module-fault, improper-removal, unsupported-equipment, dhcp-server-detected) loss-of-signal : This alarm is skipped since it is already verified on
    ...    test case  RLT-TC-1101
    ...    1. Perform actions to trigger the alarms above.   
    ...    2. Look at the details of the active alarms from the CLI. All information in the alarm is correct and matches the alarm definition.   
    ...    3. Verify the Netconf notification was sent to the logging host. All information in the alarm is shown in the notification.  
    ...    4. Trap should be sent to the trap host configured. PC (trap host) should receive the trap.  
    ...    5. Clear the condition used to trigger the alarms above.   
    ...    6. Alarm should clear and be shown in the alarm history. Alarm is no longer in active, and shows in alarm History.  
    ...    7. Verify the Netconf notification is sent to the server. Notification trap is sent to clear the alarm.  
    ...    8. Trap should be sent to the trap host configured. PC (trap host) should receive the clear trap. 
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=ssekar    @tcid=AXOS_E72_PARENT-TC-2824   @user=root     @functional    @priority=P1        @user_interface=netconf

    Log    ******* Verifying Alarm category PORT gets notified in Netconf *********
    : FOR    ${INDEX}    IN RANGE    0    3
    \    ${result}    Wait Until Keyword Succeeds      30 sec     10 sec     Run Keyword And Return Status      Verifying Alarm category PORT gets notified in Netconf 
    \    ...      ${DEVICES.n1_netconf.ip}        ${DEVICES.n1_netconf.user}     ${DEVICES.n1_netconf.password}    ${DEVICES.n1_netconf.port}      
    \    ...      ${DEVICES.n1_local_pc.ip}     n1_netconf      n1     n1_sh
    \    Exit For Loop If    '${result}' == 'True'

    Run Keyword If   '${result}' == 'False'      Fail     msg="Test case failed after attempting multiple times"

*** Keyword ***
alarm_setup
    [Arguments]        ${device1}    ${local_pc_ip}     ${linux}
    [Documentation]        Clearing alarms

    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm for dhcp server detected    ${device1}
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm for improper-removal       ${device1}      ${linux}
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm using dcli      ${device1}      ${linux}     module-fault
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm using dcli      ${device1}      ${linux}     unsupported-equipment

