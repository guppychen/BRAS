*** Settings ***
Documentation     This subtree should contain a list of events that have occurred which may be retrieved chronologically
Resource          ./base.robot
Force tags       @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao      @author=ysnigdha

*** Variables ***
${vlan1}          111
${vlan2}          222
@{list}           <description>Database entity change</description>    <address>/config/system/vlan[vlan-id='${vlan1}']</address>    <address>/config/system/vlan[vlan-id='${vlan2}']</address>
${get-event}      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get> <filter><status xmlns="http://www.calix.com/ns/exa/base"><system><instances><event><detail></detail></event></instances></system></status></filter></get></rpc>
${eve}            /status/system/instances/event/detail
${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>
@{event_times}

*** Test Cases ***
tc_EXA_Device_must_support_a_subtree_of_notification_containing_events
    [Documentation]    1 Retrieve all prior events with a db change
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1808       @globalid=2322339

    #Get system time
    ${sys_time}    cli    n1_session1    show clock
    ${start-time}    Get formatted date time    ${sys_time}

    #Subscribe for DB change events
    ${subscription}    set variable    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"> <create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter><db-change xmlns="http://www.calix.com/ns/exa/base"/></filter><startTime>${start-time}</startTime></create-subscription></rpc>
    Raw netconf configure    n1_session3    ${subscription}    ok
   
    #Trigger DB-change event
    Add vlan    n1_session1    ${vlan1}
    Add vlan    n1_session1    ${vlan2}
    Remove vlan    n1_session1    ${vlan1}
    Remove vlan    n1_session1    ${vlan2}
    
    #Retrieve events and check for corresponding DB change event
    ${events}=    Netconf Raw    n1_session3    xml=${get-event}
    : FOR    ${value}    IN    @{list}
    \    Should Contain    ${events.xml}    ${value}
    
    #Get time for each event
    @{events_t}    Get attributes netconf    n1_session3    ${eve}    ne-event-time
  
    ${count}    Get Length    ${events_t}
    :FOR    ${index}    IN RANGE    1     15
    \    ${event-time}=    Convert Date    ${events_t[${index}-1].text}    result_format=%Y-%m-%d %H:%M:%S
    \    log    ${event-time}
    \    Append to list    ${event_times}    ${event-time}
    ${len}    Get Length    ${event_times}
    ${length}    evaluate    ${len}-1
    log list    ${event_times}

    #Check whether timestamps are in chronological order
    : FOR    ${index}    IN RANGE    1    ${length}
    \    ${in1}    Evaluate    ${index}+1
    \    log many    @{event_times}[${in1}]    @{event_times}[${index}]
    \    ${res}    Subtract Date From Date    @{event_times}[${index}]    @{event_times}[${in1}]
    \    should be true    ${res} >= -1
     [Teardown]    AXOS_E72_PARENT-TC-1808 teardown

  

*** Keywords ***
AXOS_E72_PARENT-TC-1808 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1808 teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1808 teardown
    Raw netconf configure    n1_session3    ${close-session}    ok

Get formatted date time
    [Arguments]    ${login_date_time}
    [Documentation]    Retrieve the time stamp value in particular format
    ...    Example:
    ...    Get formatted date time 2016-11-03 06:45:35 PDT
    ${date}    should match regexp    ${login_date_time}    \\d\\d\\d\\d-\\d\\d-\\d\\d
    ${time}    should match regexp    ${login_date_time}    \\d\\d:\\d\\d:\\d\\d
    ${format}    Catenate    SEPARATOR=T    ${date}    ${time}
    [Return]    ${format}

Add vlan
    [Arguments]    ${session}    ${vlanid}    ${l2-dhcp-profile}=${EMPTY}
    [Documentation]    Configure vlan
    ...    Example:
    ...    Add vlan   n1_session1   2
    [Tags]    @author=clakshma
    cli     ${session}    configure
    cli     ${session}    vlan ${vlanid}
    cli     ${session}    mode N2ONE
    Run Keyword If    '${l2-dhcp-profile}' != '${EMPTY}'    cli     ${session}    l3-service DISABLED
    Run Keyword If    '${l2-dhcp-profile}' != '${EMPTY}'    cli    ${session}    ${l2-dhcp-profile}
    cli     ${session}    end
    cli     ${session}    show running-config vlan | nomore    \\#    30
    Result should contain    vlan ${vlanid}

Remove vlan
    [Arguments]    ${session}    ${vlanid}
    [Documentation]    Remove vlan
    ...    Example:
    ...    Remove vlan   n1_session1   2
    [Tags]    @author=clakshma

    cli     ${session}    configure
    cli     ${session}    no vlan ${vlanid}
    cli     ${session}    end
    cli     ${session}    show running-config vlan | nomore    \\#    30
    Result should not contain    vlan ${vlanid}
