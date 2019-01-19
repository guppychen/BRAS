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
...    Source object identifier for event -  specific component (chassis, shelf, slot/port, power supply, radio etc.)
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
...
...    CLI - Information is correct.
...    Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...    Trap/Inform - A trap/inform should be sent to the logging host.
...
...    Feature 	Events
...    PORT
Force Tags        @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=upandiri
Resource          ./base.robot

*** Variables ***
${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>
${get-event}      //status/system/event
${event_name}    db-change
${event_category}    DBCHANGE
${capture-notification}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter><status xmlns="http://www.calix.com/ns/exa/base"><system><instances><event><detail></detail></event> </instances></system></status></filter></get></rpc>
${res}    None

*** Test Cases ***
tc_Event_Category_PORT_Netconf
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.
    ...    2	Perform actions to trigger the events above.
    ...    3	Look at the details of the event from the CLI.	All information in the event is correct.
    ...    4	Verify the event is shown on the syslog server.	Information from the CLI is available in the syslog message.
    ...    5	Verify the Netconf notification was sent to the logging host.	All information in the alarm is shown in the notification.
    ...    6	Trap should be sent to the trap host configured.	PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-312    @globalid=2226233    @eut=NGPON2-4    @user_interface=Netconf
    [Setup]    RLT-TC-8837 setup

    ${port_id}   get regexp matches   ${DEVICES.n1_session1.ports.service_p1.port}    \\d\/\\d\/(\\S\\d)   1
    log    ${port_id}

    #Subscribe for DB change events
    ${subscription}    set variable    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream></create-subscription></rpc>

    Raw netconf configure    n1_session3    ${subscription}    ok

    # Perform actions to trigger the events above.

    #Triggering event
    # Trigger shutdown command to generate alarm
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}
    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}

    #verifying the event in netconf
#    ${detail}    Set Variable    /config/shelf[shelf-id='1']/slot[slot-id='1']/interface/ethernet[port=\'@{port_id}[0]\']/shutdown

    # AT-3915 change detail
    ${detail}    Set Variable    	/config/interface/ethernet[port='${DEVICES.n1_session1.ports.service_p1.port}']/shutdown
    @{name}    Raw netconf configure    n1_session3    ${capture-notification}    name
    @{category}    Raw netconf configure    n1_session3    ${capture-notification}    category
    @{event_detail}    Raw netconf configure    n1_session3    ${capture-notification}    address

    ${count}    get length    ${name}
    : FOR    ${i}    IN RANGE    0    ${count}
    \    log many    ${name[${i}].text}    ${category[${i}].text}    ${event_detail[${i}].text}
    \    log many    ${event_name}    ${event_category}    ${detail}
    \    ${res}    Run keyword if    "${event_name}" == "${name[${i}].text}" and "${event_category}" == "${category[${i}].text}" and "${detail}" == "${event_detail[${i}].text}"    Set Variable   True
    \    ...    ELSE    Continue FOR loop
    \    Exit For Loop

    Run Keyword If   "${res}" != "True"    Fail    Event ${event_category} not found


    [Teardown]   RLT-TC-8837 teardown

*** Keywords ***
RLT-TC-8837 setup
    [Documentation]    Enter RLT-TC-8837 setup
    [Arguments]
    log    Enter RLT-TC-8837 setup

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30

RLT-TC-8837 teardown
    [Documentation]    Enter RLT-TC-8837 teardown
    [Arguments]
    log    Enter RLT-TC-8837 teardown

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p1.type}    ${DEVICES.n1_session1.ports.service_p1.port}

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}
