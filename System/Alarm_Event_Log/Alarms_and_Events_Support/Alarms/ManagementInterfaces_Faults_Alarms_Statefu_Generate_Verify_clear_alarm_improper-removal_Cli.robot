*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Statefu_Generate_Verify_clear_alarm_improper-removal_Cli
    [Documentation]    Testcase to verify if the alarm is generated when SFP/SFP+/XFP pluggable device has been improperly removed
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-217    @globalid=2226126    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    # if the admin-state of the pon port is bought up without any connection we can see the improper-removal alarm generated.
    ${pon}=    command    n1_session1    show interface pon status
    #get the details of all the pon port to check which port is disabled
    ${pon}=    String.Get Lines Containing String    ${pon}    interface pon
    ${count}=    get line count    ${pon}
    : FOR    ${i}    IN RANGE    3    ${count}
    \    ${status}=    command    n1_session1    show interface pon ${ethernet.ponport}${i} status
    \    command    n1_session1    config
    \    ${port}=    command    n1_session1    interface pon ${ethernet.ponport}${i}
    \    ${status}=    String.Get Lines Containing String    ${status}    admin-state
    \    ${status}=    String.Fetch From Right    ${status}    ${SPACE}
    \    Run Keyword If    '${status}' == 'disable'    command    n1_session1    no shutdown
    \    command    n1_session1    end
    \    Exit For Loop If    '${status}' == 'disable'
    ${alarm}=    command    n1_session1    show alarm active detail
    Should Contain    ${alarm}    improper-removal
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Statefu_Generate_Verify_clear_alarm_improper-removal_Cli    n1_session1    ${port}

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Statefu_Generate_Verify_clear_alarm_improper-removal_Cli
    [Arguments]    ${DUT}    ${PORT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    config
    Command    ${DUT}    ${port}
    Command    ${DUT}    shutdown
    Command    ${DUT}    end
    Disconnect    ${DUT}
