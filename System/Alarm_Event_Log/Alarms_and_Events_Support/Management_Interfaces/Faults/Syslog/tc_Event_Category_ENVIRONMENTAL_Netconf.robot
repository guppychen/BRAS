*** Settings ***
Documentation     The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, and an SNMP trap/inform is sent:
...    CLI - Information is correct.
...    Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...    Trap/Inform - A trap/inform should be sent to the logging host.
Resource          ./base.robot
Force Tags     @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=kshettar  @user=root


*** Variables ***
${notification}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream></create-subscription></rpc>
${capture-notification}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter><status xmlns="http://www.calix.com/ns/exa/base"><system><instances><event><detail></detail></event> </instances></system></status></filter></get></rpc>
${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>
${event_name}    environment-aco-ua
${event_category}    ENVIRONMENTAL
${detail}    The ACO Push Button has been pressed
${event_id}    2602
${res}    None


*** Test Cases ***
tc_Event_Category_ENVIRONMENTAL
    [Documentation]    1    Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.
    ...    2    Perform actions to trigger the events above.
    ...    3    Look at the details of the event from the CLI.  All information in the event is correct.
    ...    4    Verify the event is shown on the syslog server. Information from the CLI is available in the syslog message.
    ...    5    Verify the Netconf notification was sent to the logging host.   All information in the alarm is shown in the notification.
    ...    6    Trap should be sent to the trap host configured.    PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-297    @globalid=2226218    @eut=NGPON2-4    @user_interface=Netconf
    [Setup]      RLT-TC-4326 setup
    [Teardown]   RLT-TC-4326 teardown

    # Trigger the event to generate log
    cli    n1_session2    dcli evtmgrd evtpost ${event_name} INFO
    # Sleep added for the event to be generated
    sleep    10

    log    STEP:3 Verify the Netconf notification was sent to the logging host. All information in the alarm is shown in the notification.
    @{temp}    Raw netconf configure    n1_session3    ${capture-notification}    id
    @{name}    Raw netconf configure    n1_session3    ${capture-notification}    name
    @{category}    Raw netconf configure    n1_session3    ${capture-notification}    category
    @{event_detail}    Raw netconf configure    n1_session3    ${capture-notification}    details

    ${count}    get length    ${temp}
    : FOR    ${i}    IN RANGE    0    ${count}
    \    log many    ${temp[${i}].text}    ${name[${i}].text}    ${category[${i}].text}
    \    ${res}    Run keyword if    "${event_id}" == "${temp[${i}].text}" and "${event_name}" == "${name[${i}].text}" and "${event_category}" == "${category[${i}].text}" and "${detail}" == "${event_detail[${i}].text}"    Set Variable   True
    \    ...    ELSE    Continue FOR loop
    \    Exit For Loop

    Run Keyword If   "${res}" != "True"    Fail    Event ${event_category} not found


*** Keywords ***
RLT-TC-4326 setup
    [Documentation]    Setup
    [Arguments]
    log    Enter RLT-TC-4326 setup

    #Close netconf session
#    Netconf Raw    n1_session3    ${close-session}

    # Netconf session creation
    ${var}=    Netconf raw    n1_session3    xml=${notification}

    # Clear active and archive logs
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30
    cli    n1_session1    clear archive event-log    \\#    30
    cli    n1_session1    clear archive alarm-log    \\#    30

RLT-TC-4326 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter RLT-TC-4326 teardown

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}

    # Clear active and archive logs
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30
    cli    n1_session1    clear archive event-log    \\#    30
    cli    n1_session1    clear archive alarm-log    \\#    30
