*** Settings ***
Documentation     The sequence number is the temporal position of this alarm relative to all alarm notifications originated from the EXA device. Each alarm instance gets a unique sequence number  associated with its position in the chronological order of events as they occur starting from device boot. The sequence number starts at 0 at boot time and increases from there. The sequence number is not unique across reboots.
...
...    The primary purpose of the sequence number is to enable consumers of alarms to know if they missed any alarm notifications and take action to retrieve missed alarms.
...
...    Purpose
...    =======
...    EXA device MUST support at the alarm instance the sequence number of the alarm wrt to the EXA device
Force Tags     @author=gpalanis    @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support
Resource          ./base.robot


*** Variables ***
${create_subscription}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream></create-subscription></rpc>

${capture-notification}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter><status xmlns="http://www.calix.com/ns/exa/base"><system><alarm><active></active></alarm></system></status></filter></get></rpc>
${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>
${event_name}    loss-of-signal
${event_category}    PORT
${event_address}    /interfaces/interface[name='${DEVICES.n1_session1.ports.service_p2.port}']
${event_id}    1201
${res}    None

*** Test Cases ***
tc_Alarm_sequence_number
    [Documentation]    1        Trigger alarm by pulling cable and causing a LOS alarm.         Active alarm is generated.      Show alarms active detail
    [Tags]       @tcid=AXOS_E72_PARENT-TC-28891
    [Setup]      RLT-TC-1029 setup
    [Teardown]   RLT-TC-1029 teardown
    log    STEP:1 Trigger alarm by pulling cable and causing a LOS alarm. Active alarm is generated. Show alarms active detail

    # Net config part - successful login
        ${version_detail}    release_cmd_adapter    n1_session1    ${detail_version}

    #@{elem}    Get attributes netconf    n1_session3    //system/version    description
    @{elem}    Get attributes netconf    n1_session3    //system/version    ${version_detail}       #AT-4711
    :For   ${items}  in  @{elem}
    \     ${result}    XML.Get Element Text    ${items}
    \      Should Not Be Empty    ${result}

    # Create subscription to alarm and events
    Raw netconf configure    n1_session3    ${create_subscription}    ok

    # Trigger unshut command to generate alarm
    Unshut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}
    # Sleep provided so that alarm is seen
    sleep    30

    # Capturing notification messages
    @{temp}    Raw netconf configure    n1_session3    ${capture-notification}    id
    @{name}    Raw netconf configure    n1_session3    ${capture-notification}    name
    @{category}    Raw netconf configure    n1_session3    ${capture-notification}    category
    @{address}    Raw netconf configure    n1_session3    ${capture-notification}    address

    ${count}    get length    ${temp}
    : FOR    ${i}    IN RANGE    0    ${count}
    \    log many    ${temp[${i}].text}    ${name[${i}].text}    ${category[${i}].text}      ${address[${i}].text}
    \    ${res}    Run keyword if    "${event_id}" == "${temp[${i}].text}" and "${event_name}" == "${name[${i}].text}" and "${event_category}" == "${category[${i}].text}" and "${event_address}" == "${address[${i}].text}"    Set Variable   True
    \    ...    ELSE    Continue FOR loop
    \    Exit For Loop

    Run Keyword If   "${res}" != "True"    Fail    Event ${event_category} not found


*** Keywords ***
RLT-TC-1029 setup
    [Documentation]    Entering setup
    [Arguments]
    log    Enter RLT-TC-1029 setup

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}
    Shut Interface    n1_session1    ${DEVICES.n1_session1.ports.service_p2.type}    ${DEVICES.n1_session1.ports.service_p2.port}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30


RLT-TC-1029 teardown
    [Documentation]    Entering Teardown
    [Arguments]

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30
    Disconnect    n1_session1
