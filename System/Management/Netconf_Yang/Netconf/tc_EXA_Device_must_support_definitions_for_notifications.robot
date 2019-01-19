*** Settings ***
Documentation     he device must expose a meta model for alarms and event notifications addressing the native gaps in NETCONF's notification capabilities. EXA device must support mapping events and alarms definition and instances to netconf notifications (there are a number of SRs on event and alarm definition and instance here - http://contour.calix.local:8080/contour/perspective.req?projectId=215&docId=219821). Users/Managers must be able to interrogate the types of events and alarms a platform supports via notifications as well as via discovery of the schema.
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=rakrishn
Resource          ./base.robot
Resource          ../../keyword/syslog_kw.robot
Library           XML    use_lxml=True

*** Variables ***
${command}        //system/alarm
${alarm1}         <?xml version="1.0" encoding="utf-8"?> <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="9"> <show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"> <id> 1201 </id> </show-alarm-instances-active-subscope> </rpc>

${create_subscription_xpath}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream><filter type="xpath" select="/*[alarm='true' and perceived-severity='MAJOR']"/><startTime>2015-12-31T00:00:00Z</startTime><stopTime>2016-12-31T00:00:00Z</stopTime></create-subscription></rpc>

${alarm-type}     running-config-lock
${lock_command}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="115"><lock><target><running/></target></lock></rpc>
${unlock_command}    <rpc message-id="110" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><unlock><target><running/></target></unlock></rpc>
${val}    0
${val1}    0

*** Test Cases ***
tc_EXA_Device_must_support_definitions_for__notifications
    [Documentation]    1 Open netconf session: ssh < user >@< ip > -p 830 -s netconf. Connection establishes and displays capabilities list after entering password. Enter password
    ...    2 Retrieve alarm/ event information using netconf. Retrieves the information. Use - get status/system/[alarms events]
    ...    3 Subscribe to notifications accepts and displays notifications that are defined in event/alarm.
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1810       @globalid=2322341

    log    STEP:2 Retrieve alarm/ event information using netconf. Retrieves the information. Use - get status/system/[alarms events]
    @{alarm_desc}    Get attributes netconf    n1_session3    ${command}    name
    ${count}    get length    ${alarm_desc}
    : FOR    ${index}    IN RANGE    0    ${count}
    \    ${val}    Run keyword if    '''${alarm-type}''' not in '''${alarm_desc[${index}].text}'''    Continue For Loop
    \    ...    ELSE    Set Variable    1
    \    Exit For Loop

    log    STEP:3 Subscribe to notifications .accepts and displays notifications that are defined in event/alarm.
    #subscribe to alarm
    Raw netconf configure    n1_session3    ${create_subscription_xpath}    ok

    # Trigger a change that would result in notification
    Get attributes netconf    n1_session3    //system/user-sessions    session-login
    Raw netconf configure    n1_session3    ${lock_command}    ok

    # Check notificaiton
    @{elem}    Get attributes netconf    n1_session3    //system/alarm/active    name
    ${count}    Get Length    ${elem}
    : FOR    ${index}    IN RANGE    0    ${count}
    \    ${val1}    Run keyword if    '''${alarm-type}''' not in '''${elem[${index}].text}'''    Continue For Loop
    \    ...    ELSE    Set Variable    1
    \    Exit For Loop

    Run Keyword If    ${val} == 1 and ${val1} == 1    Log    ${alarm-type} is present in the Alarm List!!!!
    ...    ELSE    Fail    ${alarm-type} is not present in the Alarm List!!!!

    [Teardown]    AXOS_E72_PARENT-TC-1810 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-1810 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1810 teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1810 teardown
    Raw netconf configure    n1_session3    ${unlock_command}    ok
