*** Settings ***
Documentation     For the following test, it is advised to have a CLI session open to the device, Netconf session with subscription, logging configured with a syslog server, and have a trap host configured for capturing the traps. Once you have these set up for testing, trigger the alarm/event being tested.
...
...
...    ======================================================================================
...    The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, and an SNMP trap/inform is sent:
...    CLI - Information is correct.
...    Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...    Trap/Inform - A trap/inform should be sent to the logging host.
...
...    Feature 	Events
...    DBCHANGE 	Different Source based on configuration changes
Force Tags     @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=dzala
Resource          ./base.robot


*** Variables ***

*** Test Cases ***
tc_Event_Category_DBCHANGE_CLI
    [Documentation]    1 	Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host 	and set up a PC to capture traps.
    ...    2 	Perform actions to trigger the events above.
    ...    3 	Look at the details of the event from the CLI.
    ...    4 	Verify the event is shown on the syslog server.
    ...    5 	Verify the Netconf notification was sent to the logging host.
    ...    6 	Trap should be sent to the trap host configured.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-295    @globalid=2226216    @eut=NGPON2-4    @user_interface=CLI
    [Setup]    RLT-TC-4323 setup

#     Trigger shutdown command to generate alarm
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}
    ${port_id}   get regexp matches   ${DEVICES.n1_session1.ports.service_p2.port}    \\d\/\\d\/(\\S\\d)   1
    log    ${port_id}
    #Verifying the event in CLI
    ${event}    cli    n1_session1    show event detail|nomore
    Result should contain    name                   db-change
    Result should contain    @{port_id}[0]

    [Teardown]    RLT-TC-4323 teardown

*** Keywords ***
RLT-TC-4323 setup
    [Documentation]    RLT-TC-4323 setup
    [Arguments]
    log    Entering RLT-TC-4323 setup

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30
    cli    n1_session1    clear archive event-log    \\#    30
    cli    n1_session1    clear archive alarm-log    \\#    30

RLT-TC-4323 teardown
    [Documentation]    RLT-TC-4323 teardown
    [Arguments]
    log    Entering RLT-TC-4323 teardown

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30
    cli    n1_session1    clear archive event-log    \\#    30
    cli    n1_session1    clear archive alarm-log    \\#    30
