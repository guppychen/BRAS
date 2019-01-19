*** Settings ***
Documentation     Default Support user profile named "support" with the oper role profile
Resource          base.robot
Test Setup        AXOS_E72_PARENT-TC-2687 setup
Test Teardown     AXOS_E72_PARENT-TC-2687 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira 



*** Test Cases ***
tc_Management_Security_Management_Security_Management_Plane_Default_Support_user_profile_named_support_with_the_oper_role_profile
    [Documentation]    1        login as sysadmin       login successfully
    ...    2    check default user profile "support", role is oper      verify this user role is oper
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2687    @feature=AXOS-WI-297 User Support    @EUT=E3-2
    
	
    Log    Step1:check default user profile "support", role is oper
    Cli    n1    cli
    Cli    n1    conf
    cli    n1    aaa user support role    timeout_exception=0   
    Result Should Contain    oper
    
    

*** Keywords ***
AXOS_E72_PARENT-TC-2687 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2687 setup


AXOS_E72_PARENT-TC-2687 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2687 teardown
    cli    n1   ^03
    cli    n1   exit
    cli    n1   show version
