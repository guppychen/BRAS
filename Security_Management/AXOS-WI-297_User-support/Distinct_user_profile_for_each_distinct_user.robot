*** Settings ***
Documentation     Distinct user profile for each distinct user
Test Setup        AXOS_E72_PARENT-TC-2695 setup
Test Teardown     AXOS_E72_PARENT-TC-2695 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
Distinct_user_profile_for_each_distinct_user
    [Documentation]    1 Verify that the passwords are stored in a nin-volatile store
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2695    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    Make User in the Device    n1    ${user1.name}    ${user1.password}    ${user1.role}
    Make User in the Device    n1    ${user2.name}    ${user2.password}    ${user2.role}
    cli    n1    configure
    cli    n1    exit
    ${output}    cli    n1    show running-config aaa user   prompt=${eutpmt}
    Result Should Contain    ${output}

*** Keywords ***
AXOS_E72_PARENT-TC-2695 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2695 setup

AXOS_E72_PARENT-TC-2695 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2695 teardown
    Delete User in the Device    n1    ${user1.name}
    Delete User in the Device    n1    ${user2.name}
    Disconnect    n1
