*** Settings ***
Documentation     For the following test, it is advised to have a CLI session open to the device, Netconf session with subscription, logging configured with a syslog server, and have a trap host configured for capturing the traps. Once you have these set up for testing, trigger the alarm/event being tested.
Resource          ./base.robot
Force Tags  @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=gpalanis
 
*** Variables ***

*** Test Cases ***
tc_Event_Category_CONFIGURATION_CLI
    [Documentation]    1	Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.		
    ...    2	Perform actions to trigger the events above.		
    ...    3	Look at the details of the event from the CLI.	All information in the event is correct.	
    ...    4	Verify the event is shown on the syslog server.	Information from the CLI is available in the syslog message.	
    ...    5	Verify the Netconf notification was sent to the logging host.	All information in the alarm is shown in the notification.	
    ...    6	Trap should be sent to the trap host configured.	PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-290    @globalid=2226211    @eut=NGPON2-4    @user_interface=CLI
    [Setup]      RLT-TC-4320 setup
    [Teardown]   RLT-TC-4320 teardown
    
    # Event - copy-to-running-config
    log    copy-to-running-config
    cli    n1_session1    copy config from startup-config to running-config
    Result should contain    Copy completed.

    #Verifying the event in CLI
    ${current_event}    cli    n1_session1    show event | nomore    \\#    30
    Should Not Be Empty    ${current_event}

    cli    n1_session1    show event | nomore | include CONFIGURATION    \\#    30
    Result Should Contain    name copy-to-running-config category CONFIGURATION
    Result Match Regexp    id[\\s]+703

*** Keywords ***
RLT-TC-4320 setup
    [Documentation]     RLT-TC-4320 setup
    [Arguments]
    log    Enter RLT-TC-4320 setup

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30


RLT-TC-4320 teardown
    [Documentation]     RLT-TC-4320 teardown
    [Arguments]
    log    Enter RLT-TC-4320 teardown

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30

