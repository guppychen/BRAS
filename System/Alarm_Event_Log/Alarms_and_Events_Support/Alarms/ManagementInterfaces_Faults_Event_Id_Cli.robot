*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_Id_Cli
    [Documentation]    To verify if the event-id matches it's definition.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-337    @globalid=2226259    @priority=P1    @user_interface=Cli
    cli    n1_session1    clear active event
    Disconnect    n1_session1
    ${events}=    Cli    n1_session1    show event detail
    Should contain    ${events}    101
    #Verify the scenario from CLI
    ${definition}=    cli    n1_session1    show event definition subscope id 101
    ${description}=    String.Get Lines Containing String    ${definition}    description
    ${description}=    Remove string    ${description}    ${SPACE}${SPACE}${SPACE}${SPACE}description${SPACE}
    ${details}=    String.Get Lines Containing String    ${definition}    details
    ${details}=    Remove string    ${details}    ${SPACE}${SPACE}${SPACE}${SPACE}details${SPACE}
    ${name}=    String.Get Lines Containing String    ${definition}    ${SPACE}name
    ${name}=    Remove string    ${name}    ${SPACE}${SPACE}${SPACE}${SPACE}name${SPACE}
    ${category}=    String.Get Lines Containing String    ${definition}    category
    ${category}=    Remove string    ${category}    ${SPACE}${SPACE}${SPACE}${SPACE}category${SPACE}
    Should contain    ${events}    ${description}
    Should contain    ${events}    ${details}
    Should contain    ${events}    ${category}
    Should contain    ${events}    ${name}
    Cli    n1_session1    clear active event
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_Id_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_Id_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
