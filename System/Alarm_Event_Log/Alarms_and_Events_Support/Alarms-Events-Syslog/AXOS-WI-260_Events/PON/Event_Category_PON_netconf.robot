*** Settings ***
Documentation     This test suite is going to verify whether the following PON events can be triggered.
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags


*** Test Cases ***

Event_Category_PON
    [Documentation]    Test case verifies whether the following PON events can be triggered
    ...    (Events : ont-arrival, ont-departure, ont-link, ont-unlink)
    ...    1. Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.   
    ...    2. Perform actions to trigger the events above.   
    ...    3. Look at the details of the event from the CLI. All information in the event is correct.  
    ...    4. Verify the event is shown on the syslog server. Information from the CLI is available in the syslog message.  
    ...    5. Verify the Netconf notification was sent to the logging host. All information in the alarm is shown in the notification.  
    ...    6. Trap should be sent to the trap host configured. PC (trap host) should receive the trap. 
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang    @author=ssekar  @tcid=AXOS_E72_PARENT-TC-2877   @user=root     @functional    @priority=P1        @user_interface=netconf


    Log    ******* Verifying ONT events gets notified in Netconf *********
    Wait Until Keyword Succeeds      2 min     10 sec      Verifying ONT arrival event gets notified in Netconf     ${DEVICES.n1_netconf.ip}        ${DEVICES.n1_netconf.user}     ${DEVICES.n1_netconf.password}    ${DEVICES.n1_netconf.port}       ${DEVICES.n1_local_pc.ip}     n1_netconf      n1     n1_sh
