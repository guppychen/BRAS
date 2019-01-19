*** Settings ***
Documentation     For the following test, it is advised to have a CLI session open to the device, Netconf session with subscription, logging configured with a syslog server, and have a trap host configured for capturing the traps. Once you have these set up for testing, trigger the alarm/event being tested.
Resource          ./base.robot
Force Tags  @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=cindy gao    @author=gpalanis

 
*** Variables ***
${create_subscription}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream></create-subscription></rpc>

${copy_config}  <?xml version="1.0" encoding="UTF-8"?><rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><copy-configuration xmlns="http://www.calix.com/ns/exa/base"><to>running-config</to><from>startup-config</from></copy-configuration></rpc>

#${get-event}      //status/system/event

${capture-notification}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter><status xmlns="http://www.calix.com/ns/exa/base"><system><instances><event><detail></detail></event> </instances></system></status></filter></get></rpc>

${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>
${event_name}    copy-to-running-config
${event_category}    CONFIGURATION
${detail}    Copy into running configuration was done
${event_id}    703
${res}    None

*** Test Cases ***
tc_Event_Category_CONFIGURATION_Netconf
    [Documentation]    1    Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.        
    ...    2    Perform actions to trigger the events above.        
    ...    3    Look at the details of the event from the CLI.  All information in the event is correct.    
    ...    4    Verify the event is shown on the syslog server. Information from the CLI is available in the syslog message.    
    ...    5    Verify the Netconf notification was sent to the logging host.   All information in the alarm is shown in the notification.  
    ...    6    Trap should be sent to the trap host configured.    PC (trap host) should receive the trap.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-290    @globalid=2226211    @eut=NGPON2-4    @user_interface=Netconf
    [Setup]      RLT-TC-4320 setup
    [Teardown]   RLT-TC-4320 teardown
    
    #Subscribe to notifications for CONFIGURATION events
    Raw netconf configure    n1_session3    ${create_subscription}    ok

    #Running to startup config 
    ${elem}    Raw netconf configure    n1_session3    ${copy_config}   status
    Element Text Should Match    @{elem}    Copy completed.

    #Verify event in netconf
    @{temp}    Raw netconf configure    n1_session3    ${capture-notification}    id
    @{name}    Raw netconf configure    n1_session3    ${capture-notification}    name
    @{category}    Raw netconf configure    n1_session3    ${capture-notification}    category
    @{event_detail}    Raw netconf configure    n1_session3    ${capture-notification}    description

    ${count}    get length    ${temp}
    : FOR    ${i}    IN RANGE    0    ${count}
    \    log many    ${temp[${i}].text}    ${name[${i}].text}    ${category[${i}].text}
    \    log many    ${event_name}    ${event_category}    ${detail}    ${event_id}
    \    ${res}    Run keyword if    "${event_id}" == "${temp[${i}].text}" and "${event_name}" == "${name[${i}].text}" and "${event_category}" == "${category[${i}].text}" and "${detail}" == "${event_detail[${i}].text}"    Set Variable   True
    \    ...    ELSE    Continue FOR loop
    \    Exit For Loop

    Run Keyword If   "${res}" != "True"    Fail    Event ${event_name} not found


*** Keywords ***
RLT-TC-4320 setup
    [Documentation]    Entering RLT-TC-4320 setup
    [Arguments]
    log    Enter RLT-TC-4320 setup

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}

    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30
    

RLT-TC-4320 teardown
    [Documentation]    Entering RLT-TC-4320 teardown
    [Arguments]
    log    Enter RLT-TC-4320 teardown
  
    cli    n1_session1    clear active event-log    \\#    30
    cli    n1_session1    clear active alarm-log    \\#    30

    #Close netconf session
    Netconf Raw    n1_session3    ${close-session}
 
