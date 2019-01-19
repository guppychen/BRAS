*** Settings ***
Documentation     The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, and an SNMP trap/inform is sent:
...    CLI - Information is correct.
...    Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...    Trap/Inform - A trap/inform should be sent to the logging host.
Resource          ./base.robot
Force Tags     @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=kshettar  @user=root


*** Variables ***
${event}    environment-aco-ua

*** Test Cases ***
tc_Event_Category_ENVIRONMENTAL
    [Documentation]    1    Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.
    ...    2    Perform actions to trigger the events above.
    ...    3    Look at the details of the event from the CLI.  All information in the event is correct.
    ...    4    Verify the event is shown on the syslog server. Information from the CLI is available in the syslog message.
    ...    5    Verify the Netconf notification was sent to the logging host.   All information in the alarm is shown in the notification.
    ...    6    Trap should be sent to the trap host configured.    PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-297    @globalid=2226218    @eut=NGPON2-4    @user_interface=CLI
    [Setup]      RLT-TC-4326 setup
    [Teardown]   RLT-TC-4326 teardown

    # trigger the event to generate alarm
    cli    n1_session2    dcli evtmgrd evtpost ${event} INFO
    # Wait till event is triggered
    sleep    10

    # verifying the event in CLI
    ${res}    cli    n1_session1    show event detail | nomore    \\#    30
    Result should contain    ${event}
    Result should contain    The ACO Push Button has been pressed
    Result should contain    ACO Push Button press detected
    
    
*** Keywords ***
RLT-TC-4326 setup
    [Documentation]    Setup
    [Arguments]
    log    Enter RLT-TC-4326 setup
    
    cli    n1_session1    clear active event-log    \\#    30


RLT-TC-4326 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter RLT-TC-4326 teardown
    
    cli    n1_session1    clear active event-log    \\#    30

