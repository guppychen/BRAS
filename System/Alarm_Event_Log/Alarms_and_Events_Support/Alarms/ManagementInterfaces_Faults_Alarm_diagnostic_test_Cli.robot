*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarm_diagnostic_test_Cli
    [Documentation]    Testcase to verify the events are generated when the image is succesfully activated.
    [Tags]  @jira=AT-5002  dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-206    @globalid=2226115    @priority=P1    @user_interface=Cli
    command    n1_session1    show diagnostic test
    command    n1_session1    start diagnostic test name ${diagnostic.filename}
    #Wait till the diagnostic test ends
    : FOR    ${i}    IN RANGE    50
    \    ${alarms}=    command    n1_session1    show alarm history subscope count 1
    \    ${description}=    String.get lines containing string    ${alarms}    description
    \    ${string}=    String.Fetch From Right    ${description}    description${SPACE}
    \    Exit For Loop If    '${string}' == 'test ENDED - ${SPACE}${diagnostic.filename}'
    ${alarm}=    command    n1_session1    show alarm history detail
    Should contain    ${alarm}    diagnostic
    Should contain    ${alarm}    801
    Should contain    ${alarm}    test ENDED - ${SPACE}${diagnostic.filename}
    Should contain    ${alarm}    Test STARTED -    ${diagnostic.filename}
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarm_diagnostic_test_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarm_diagnostic_test_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Disconnect    ${DUT}
