   
*** Settings ***
Documentation     Verify that the capability is available and can be enabled. 
...    Verify that the RPCs use the xpath as intended. 
...     Refer to http://www.w3.org/TR/1999/REC-xpath-19991116
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=gpalanis
Resource          ./base.robot


*** Variables ***
${create_subscription}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><create-subscription xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0"><stream>exa-events</stream></create-subscription></rpc>

${get_config_int}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get-config xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><source><running/></source><filter type="xpath" select="/*/interface[name='1/1/x1']"/></get-config></rpc>

${vca_rpc}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get><filter xmlns:t="http://www.calix.com/ns/exa/vca" type="xpath" select="/status/system/vca"/></get></rpc>

${get_config_aaa}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get-config><source><running/></source><filter type="xpath" select="/* /system/aaa"/></get-config></rpc>

${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>

@{alarm_list}

${val}    0

*** Test Cases ***
tc_EXA_Device_must_support_full_XPATH_1_0_capabilities_as_part_of_the_NETCONF_specification_for_XPath_for_identifying_the_target_of_a_management_operation_as_part_of_the_filter_elemen
    [Documentation]    1	Open netconf session: ssh < user >@< ip > -p 830 -s netconf. 	Connection establishes and displays capabilities list after entering password. 	Enter password
    ...    2	Send "hello" rpc enabling "urn:ietf:params:netconf:base:1.0" and "urn:ietf:params:netconf:capability:xpath:1.0" capabilities 	Does not reject 	
    ...    3	send "get-config" rpc with an XPATH	Returns requested item.
    [Tags]       @TCID=AXOS_E72_PARENT-TC-1789        @globalid=2322320
    
    log    STEP:1 Open netconf session: ssh < user >@< ip > -p 830 -s netconf. Connection establishes and displays capabilities list after entering password. Enter password
    # Net config part - successful login
    @{elem}    Get attributes netconf    n1_session3    //system/user-sessions    session-login
    ${count}    Get Length    ${elem}
    : FOR    ${index}    IN RANGE    0     ${count}
    \    ${val}    Run Keyword If   "${elem[${index}].text}" != "${DEVICES.n1_session3.user}"    Continue For Loop
    \    ...    ELSE    Set Variable    1
    \    Exit For Loop

    Run Keyword If   "${val}" == "1"  log   user ${DEVICES.n1_session3.user} is logged in     ELSE    Fail    ERROR:user ${DEVICES.n1_session3.user} is not logged in

    log    STEP:2 Send "hello" rpc enabling "urn:ietf:params:netconf:base:1.0" and "urn:ietf:params:netconf:capability:xpath:1.0" capabilities Does not reject
    Raw netconf configure    n1_session3    ${create_subscription}    ok

    log    STEP:3 send "get-config" rpc with an XPATH Returns requested item.
    # Check the aaa user
    ${elem}    Raw netconf configure    n1_session3    ${get_config_aaa}    name
    ${count}    Get Length    ${elem}
    : FOR    ${index}    IN RANGE    0     ${count}
    \      Append To List       ${alarm_list}   ${elem[${index}].text}
    Should Contain  ${alarm_list}    ${DEVICES.n1_session1.user}

    # Check aaa user in xpath
    @{elem}    Get attributes netconf    n1_session3    //user    name
    ${count}    Get Length    ${elem}
    : FOR    ${index}    IN RANGE    0     ${count}
    \      Append To List       ${alarm_list}   ${elem[${index}].text}
    Should Contain  ${alarm_list}    ${DEVICES.n1_session1.user}

    # Check VCA user
    @{elem}    Raw netconf configure    n1_session3    ${vca_rpc}    mpeg-analysis
    Should Contain    ${elem[0].text}    TS Headers per pkt

    # close the netconf session
    Raw netconf configure    n1_session3    ${close-session}    ok
