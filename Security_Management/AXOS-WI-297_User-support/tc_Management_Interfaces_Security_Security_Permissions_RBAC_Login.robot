*** Settings ***
Documentation     EXA device MUST support a consistent use of RBAC across all use agents
Resource          base.robot
Test Setup        AXOS_E72_PARENT-TC-2675 setup
Test Teardown     AXOS_E72_PARENT-TC-2675 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira 

*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Security_Security_Permissions_RBAC_Login
    [Documentation]    1	Login as Sysadmin create a user(Tester) through CLI	show to verify the user is created	
    ...    2	Login as Tester from CLI 	log in successfully	
    ...    3	show user -sessions	show the active user sessions 
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2675    @feature=AXOS-WI-297 User Support    @EUT=E3-2

	
    Make User in the Device    n1    ${user1.name}    ${user1.password}    ${user1.role}
	
    Make a Connection and Login    n2    ${user1.name}    ${user1.password}
	
    Log    Step3:show user -sessions
    ${main}=    Command    n2    show user-sessions session
    Should Contain    ${main}    ${user1.name}


*** Keywords ***
AXOS_E72_PARENT-TC-2675 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2675 setup


AXOS_E72_PARENT-TC-2675 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2675 teardown
    Session Destroy Local    n2
