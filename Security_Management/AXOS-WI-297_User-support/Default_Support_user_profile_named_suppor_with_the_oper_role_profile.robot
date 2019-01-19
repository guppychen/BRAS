*** Settings ***
Documentation     Default Support user profile named "support" with the oper role profile
Test Setup        AXOS_E72_PARENT-TC-2687 setup
Test Teardown     AXOS_E72_PARENT-TC-2687 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
Default_Support_user_profile_named_suppor_with_the_oper_role_profile
    [Documentation]    1 login as sysadmin
    ...    2 check default user profile "support", role is oper
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2687    @EUT=E3-2 @priority=1
    Comment    Default Support user profile named "support" with the oper role profile
    cli    n1     end
    Cli    n1    show running-config aaa user support    prompt=${eutpmt}
    Result Should Contain    support
    Result Should Contain    role oper

*** Keywords ***
AXOS_E72_PARENT-TC-2687 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2687 setup

AXOS_E72_PARENT-TC-2687 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2687 teardown
    Command  n1    end
    Disconnect    n1
