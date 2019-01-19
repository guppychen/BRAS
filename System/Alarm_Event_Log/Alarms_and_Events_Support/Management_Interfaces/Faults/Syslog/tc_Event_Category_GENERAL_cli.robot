*** Settings ***
Documentation     For the following test, it is advised to have a CLI session open to the device, Netconf session with subscription, logging configured with a syslog server, and have a trap host configured for capturing the traps. Once you have these set up for testing, trigger the alarm/event being tested.
...
...
...
...    Id
...
...
...    Unique id of event type. Statically defined
...
...    Name
...
...
...    Display name of event type
...
...    Description
...
...
...    Static description of event type. Defines purpose of the event.
...
...    Source
...
...
...    Source object identifier for event -  specific component (chassis, shelf, slot/port, power supply, radio etc.?)
...    Category 	Category of event identifying some logic group of events significant from an external usage perspective
...
...    Additional text
...
...
...    May contain a default message format. The intent is to include Instance specific detailed information augmenting  description. These details may also be encoded in additional info
...
...    Sequence number
...
...
...    Whether or not this event supports sequence numbers
...
...    Module
...
...
...    Module generating the event (may include file and line # when available)
...
...    ======================================================================================
...    The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, and an SNMP trap/inform is sent:
...    CLI - Information is correct.
...    Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...    Trap/Inform - A trap/inform should be sent to the logging host.
...
...    Feature 	Events
...    ARC 	core-file-generated
...    lldp-neighbor-activity
...    log-clear
...    system-restart
...    test-primitive
...    reload_canceled
...    reload_scheduled
...    reload_system
...    time-set
Resource          ./base.robot
Force Tags    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=sdas


*** Variables ***
${event_name}    system-restart
${event_id}    2604

*** Test Cases ***
tc_Event_Category_GENERAL
    [Documentation]    Action	Expected Result	Notes
    ...    1	Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.
    ...    2	Perform actions to trigger the events above.
    ...    3	Look at the details of the event from the CLI.	All information in the event is correct.
    ...    4	Verify the event is shown on the syslog server.	Information from the CLI is available in the syslog message.
    ...    5	Verify the Netconf notification was sent to the logging host.	All information in the alarm is shown in the notification.
    ...    6	Trap should be sent to the trap host configured.	PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-300    @globalid=2226221    @eut=NGPON2-4    @user_interface=CLI
    [Setup]      RLT-TC-4322 setup
    [Teardown]   RLT-TC-4322 teardown

    log    STEP:1 Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.
    #Connection handle takes care of CLI session

    log    STEP:2 Perform actions to trigger the events above.
    #Trigger an general Event through cli(system restart/reload)

    cli    n1_session1    reload   [y/N]    60
    cli    n1_session1    y    \\#    60

    #Wait until system reloads
    sleep  30
    wait until keyword succeeds    10 min    30s    ping_dpu    h1    ${DEVICES.n1_session1.ip}
    wait until keyword succeeds    5 min    30s    cli    n1_session1    show version    \\#    30

    log    STEP:3 Look at the details of the event from the CLI. All information in the event is correct.

    cli    n1_session1    show event | include GENERAL
    result should contain    ${event_name}
    result should contain    ${event_id}

*** Keywords ***
RLT-TC-4322 setup
    [Documentation]    Enter RLT-TC-4322 setup
    [Arguments]
    log    Enter RLT-TC-4322 setup

    cli    n1_session1    clear active event-log    \\#    30

RLT-TC-4322 teardown
    [Documentation]    Enter RLT-TC-4322 teardown
    [Arguments]
    log    Enter RLT-TC-4322 teardown
    cli    n1_session1    clear active event-log    \\#    30	
