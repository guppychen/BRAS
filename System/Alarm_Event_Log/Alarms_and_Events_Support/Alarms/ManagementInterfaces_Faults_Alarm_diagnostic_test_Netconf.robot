*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${alarm-his}      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> \ \ <get> \ \ \ \ <filter> \ \ \ \ \ \ <status xmlns="http://www.calix.com/ns/exa/base"> \ \ \ \ \ \ \ <system> \ \ \ \ \ \ \ \ \ \ <alarm> \ \ \ \ \ \ \ \ \ \ \ \ <history> \    \    \    </history> \ \ \ \ \ \ \ \ \ \ </alarm> \ \ \ \ \ \ \ \ </system> \ \ \ \ \ \ </status> \ \ \ \ </filter> \ \ </get> </rpc>

*** Test Cases ***
ManagementInterfaces_Faults_Alarm_diagnostic_test_Netconf
    [Documentation]    Testcase to verify the if the events are generated when config file is copied to running-config.
    [Tags]  @jira=AT-5002  dual_card_not_support    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-206    @globalid=2226115    @priority=P1    @user_interface=Netconf
    Command    n1_session1    clear active event
    command    n1_session1    show diagnostic test
    command    n1_session1    start diagnostic test name ${diagnostic.filename}
    : FOR    ${i}    IN RANGE    50
    \    ${alarms}=    command    n1_session1    show alarm history subscope count 1
    \    ${description}=    String.get lines containing string    ${alarms}    description
    \    ${string}=    String.Fetch From Right    ${description}    description${SPACE}
    \    Exit For Loop If    '${string}' == 'test ENDED - ${SPACE}${diagnostic.filename}'
    ${alarm}=    Netconf Raw    n1_session3    xml=${alarm-his}
    ${alarm}=    Convert to string    ${alarm}
    Log    ${alarm}
    Should contain    ${alarm}    diagnostic
    Should contain    ${alarm}    801
    Should contain    ${alarm}    INFO
    Should contain    ${alarm}    CLEAR
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarm_diagnostic_test_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarm_diagnostic_test_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
