*** Settings ***
Documentation     The EXA device must support the <create-subscription> operation, filter (XPATH) and both the notification and interleave capabilities as well as a stream with at a minimum events, and alarms
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=gpalanis
Resource          ./base.robot


*** Variables ***

${create_subscription}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"> <create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"> <stream>exa-events</stream> <filter> <running-config-unsaved xmlns="http://www.calix.com/ns/exa/base"/> <db-change xmlns="http://www.calix.com/ns/exa/base"/> <running-config-lock xmlns="http://www.calix.com/ns/exa/base"/> <config-file-copied xmlns="http://www.calix.com/ns/exa/base"/> </filter> </create-subscription> </rpc>

${capture-notification}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><get><filter><status xmlns="http://www.calix.com/ns/exa/base"><system><alarm><active></active></alarm></system></status></filter></get></rpc>

@{list}    <id>718</id>    <name>running-config-lock</name>    <category>CONFIGURATION</category>    <perceived-severity>INFO</perceived-severity>
@{alarm_list}

${create_subscription_xpath}   <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter type="xpath" select="/*[alarm='true' and perceived-severity='MAJOR']"/><startTime>2015-12-31T00:00:00Z</startTime><stopTime>2016-12-31T00:00:00Z</stopTime></create-subscription></rpc>

${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>

${lock_command}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="115"><lock><target><running/></target></lock></rpc> 
${unlock_command}    <rpc message-id="110" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><unlock><target><running/></target></unlock></rpc>

${command}        //system/user-sessions
${val}    0

*** Test Cases ***
tc_EXA_Device_must_support_asynchronous_notification_mechanism_per_RFC_5277
    [Documentation]    1	Open netconf session: ssh < user >@< ip > -p 830 -s netconf. 	Connection establishes and displays capabilities list after entering password. 	Enter password
    ...    2	Send "hello" rpc. 	Does not reject 	Enable "urn:ietf:params:netconf:base:1.0" and "urn:ietf:params:netconf:capability:xpath:1.0" capabilities
    ...    3	Send a < create-subscription > rpc to initiate subscription.	accepts	
    ...    4	Trigger a change that would result in notification	notification is sent	
    ...    5	repeat 3, 4 using an XPATH filer	correct notification is received when changes are made.	
    ...    6	exa-events 2015-12-31T00:00:00Z 2016-12-31T00:00:00Z 
    [Tags]       @TCID=AXOS_E72_PARENT-TC-1785     @globalid=2322316
    [Setup]      AXOS_E72_PARENT-TC-1785 setup
    [Teardown]   AXOS_E72_PARENT-TC-1785 teardown
    log    STEP:1 Open netconf session: ssh < user >@< ip > -p 830 -s netconf. Connection establishes and displays capabilities list after entering password. Enter password

    # Net config part - successful login
    @{elem}    Get attributes netconf    n1_session3    ${command}    session-login
    ${count}    Get Length    ${elem}
    : FOR    ${index}    IN RANGE    0     ${count}
    \    ${val}    Run Keyword If    "${elem[${index}].text}" != "${DEVICES.n1_session3.user}"    Continue For Loop
    \    ...    ELSE    Set Variable    1
    \    Exit For Loop
    Run Keyword If   "${val}" == "1"  log   user ${DEVICES.n1_session3.user} is logged in     ELSE    Fail    ERROR:user ${DEVICES.n1_session3.user} is not logged in

 
    log    STEP:2 Send "hello" rpc. Does not reject Enable "urn:ietf:params:netconf:base:1.0" and "urn:ietf:params:netconf:capability:xpath:1.0" capabilities

    log    STEP:3 Send a < create-subscription > rpc to initiate subscription. accepts
    Raw netconf configure    n1_session3    ${create_subscription}    ok 

    log    STEP:4 Trigger a change that would result in notification notification is sent
    Raw netconf configure    n1_session3    ${lock_command}    ok

    #Capture the notification sent
    ${notification_msgs}=    Netconf Raw    n1_session3    xml=${capture-notification}
    log     ${notification_msgs}
    : FOR    ${value}    IN    @{list}
    \    Should Contain    ${notification_msgs.xml}    ${value}

    # unlocking the data store running
    Raw netconf configure    n1_session3    ${unlock_command}    ok

    # close the netconf session
    Raw netconf configure    n1_session3    ${close-session}    ok

    log    STEP:5 repeat 3, 4 using an XPATH filer correct notification is received when changes are made.
    # Create subscription using  xpath
    wait until keyword succeeds  3x  10s   Raw netconf configure    n1_session3    ${create_subscription_xpath}  ok

    # Trigger a change that would result in notification
    Raw netconf configure    n1_session3    ${lock_command}    ok

    # Check notificaiton - if the data store is locked
    @{elem}    Get attributes netconf    n1_session3   //system/alarm/active   name
    ${count}    Get Length    ${elem}
    : FOR    ${index}    IN RANGE    0     ${count}
    \      Append To List       ${alarm_list}   ${elem[${index}].text}
    Should Contain  ${alarm_list}    running-config-lock

    # unlocking the data store running
    Raw netconf configure    n1_session3    ${unlock_command}    ok

    # close the netconf session
    Raw netconf configure    n1_session3    ${close-session}    ok


*** Keywords ***
AXOS_E72_PARENT-TC-1785 setup
    [Documentation]    AXOS_E72_PARENT-TC-1785 setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1785 setup

    cli    n1_session1    unlock datastore running

AXOS_E72_PARENT-TC-1785 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1785 teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1785 teardown

    cli    n1_session1    unlock datastore running
    Disconnect    n1_session1
