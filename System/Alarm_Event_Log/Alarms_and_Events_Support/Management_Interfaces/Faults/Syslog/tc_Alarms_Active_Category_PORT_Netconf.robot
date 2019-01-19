*** Settings ***
Documentation     The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, the alarm is sent to the syslog server, and an SNMP trap/inform is sent:
...
...        CLI - Information is correct.
...        Netconf- A netconf notification should be sent to the logging host.  This could be a ssh session, activate server, or CMS.
...        Trap/Inform - A trap/inform should be sent to the logging host.
...        Syslog - Alarm/alarm should be logged in the remote syslog.
Force Tags        @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=kshettar
Resource          ./base.robot


*** Variables ***
${notification}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream></create-subscription></rpc>
${capture-notification}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter><status xmlns="http://www.calix.com/ns/exa/base"><system><alarm><active></active></alarm></system></status></filter></get></rpc>
${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>
${event_name}    improper-removal
${event_category}    PORT
${event_id}    1203
${res}    None

*** Test Cases ***
tc_Alarms_Active_Category_PORT
    [Documentation]    1    Open a CLI session to the EUT, have it discovered by a CMS server, configure a trap host, and set up a PC to capture traps.
    ...    2    Perform actions to trigger the alarms above.
    ...    3    Look at the details of the active alarms from the CLI.  All information in the alarm is correct and matches the alarm definition.
    ...    4    Verify the Netconf notification was sent to the logging host.   All information in the alarm is shown in the notification.
    ...    5    Trap should be sent to the trap host configured.    PC (trap host) should receive the trap.
    ...    6    Clear the condition used to trigger the alarms above.
    ...    7    Alarm should clear and be shown in the alarm history.   Alarm is no longer in active, and shows in alarm History.
    ...    8    Verify the Netconf notification is sent to the server.  Notification trap is sent to clear the alarm.
    ...    9    Trap should be sent to the trap host configured.    PC (trap host) should receive the clear trap.
    [Tags]       @author=kshettar     @tcid=AXOS_E72_PARENT-TC-2899    @globalid=2226125    @eut=NGPON2-4    @user_interface=Netconf
    [Setup]      RLT-TC-4336 setup

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.subscriber_p3.type}    ${DEVICES.n1_session1.ports.subscriber_p3.port}
    # Wait added to capture the event
    Sleep    10

    # Trigger shutdown command to generate alarm
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.subscriber_p3.type}    ${DEVICES.n1_session1.ports.subscriber_p3.port}
    # Wait added to capture the event
    sleep    10

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.subscriber_p3.type}    ${DEVICES.n1_session1.ports.subscriber_p3.port}

    log    STEP:5 Verify the Netconf notification is sent to the server.Notification trap is sent to clear the alarm.
    #@{port}    Evaluate    "${DEVICES.n1_session1.ports.subscriber_p3.port}".split("/")
    ${detail}    Set Variable    /interfaces/interface[name=\'${DEVICES.n1_session1.ports.subscriber_p3.port}\']
    @{temp}    Raw netconf configure    n1_session3    ${capture-notification}    id
    @{name}    Raw netconf configure    n1_session3    ${capture-notification}    name
    @{category}    Raw netconf configure    n1_session3    ${capture-notification}    category
    @{event_detail}    Raw netconf configure    n1_session3    ${capture-notification}    address

    ${count}    get length    ${temp}
    : FOR    ${i}    IN RANGE    0    ${count}
    \    log many    ${temp[${i}].text}    ${name[${i}].text}    ${category[${i}].text}
    \    ${res}    Run keyword if    "${event_id}" == "${temp[${i}].text}" and "${event_name}" == "${name[${i}].text}" and "${event_category}" == "${category[${i}].text}" and "${detail}" == "${event_detail[${i}].text}"    Set Variable   True
    \    ...    ELSE    Continue FOR loop
    \    Exit For Loop

    Run Keyword If   "${res}" != "True"    Fail    Event ${event_category} not found


    [Teardown]   RLT-TC-4336 teardown

*** Keywords ***
RLT-TC-4336 setup
    [Documentation]    Setup
    [Arguments]
    log    Enter RLT-TC-4336 setup

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}

    # Netconf session creation
    wait until keyword succeeds  120s  30s  Netconf raw    n1_session3    xml=${notification}


RLT-TC-4336 teardown
    [Documentation]    Teardown
    [Arguments]
    log    Enter RLT-TC-4336 teardown

    #Unshut interface
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.subscriber_p3.type}    ${DEVICES.n1_session1.ports.subscriber_p3.port}

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}
