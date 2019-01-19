*** Settings ***
Documentation     EXA device MUST support a default Network Administrator user profile named "networkdmin" with the Network Administrator role profile
Resource          base.robot
Test Setup        AXOS_E72_PARENT-TC-2685 setup
Test Teardown     AXOS_E72_PARENT-TC-2685 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira 


*** Variables ***


*** Test Cases ***
tc_EXA_device_MUST_support_a_default_Network_Administrator_user_profile_named_networkdmin_with_the_Network_Administrator_role_profile
    [Documentation]    1        login as sysadmin       login successfully
    ...    2    check default user profile "networkadmin", role is Network Administrator        verify this user role is network administrator
    [Tags]       @author=vduraira     @TCID=AXOS_E72_PARENT-TC-2685    @feature=AXOS-WI-297 User Support    @EUT=E3-2
   

    log    STEP:1 login as sysadmin 
    Cli    n1    cli
    Cli    n1   configure
    
    log    STEP:2 check default user profile "networkadmin", role is Network Administrator verify this user role is network administrator
    ${checkingvar}=    Command    n1   aaa user networkadmin role    timeout_exception=0
    Comment    Fails if the networkadmin profile is not present
    Result Should Contain    admin
    
   

*** Keywords ***
AXOS_E72_PARENT-TC-2685 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2685 setup


AXOS_E72_PARENT-TC-2685 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2685 teardown
    Command   n1    end

