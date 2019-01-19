*** Settings ***
Documentation     Never be able to retrieve a user password in its original form
Test Setup        RLT-TC-13736 setup
Test Teardown     RLT-TC-13736 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
Never_be_able_to_retrieve_user_password_in_its_original_form
    [Documentation]    1Create a user using the user access interfacesa
    ...    2 Login to the system using the user account
    ...    3 Verify that the login passwords are never displayed using clear text
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2690    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    Make User in the Device    n1    ${user1.name}    ${user1.password}    ${user1.role}
    disconnect    n1
    Make a Connection and Login    n2    ${user1.name}    ${user1.password}
    ${output}    cli    n2    show running-config aaa user ${user1.name}   prompt=${eutpmt}
    Result Should Contain    ${output}
    Result Should Not Contain    ${user1.password}

*** Keywords ***
RLT-TC-13736 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2690 setup

RLT-TC-13736 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2690 teardown
    Session Destroy Local    n2
    Delete User in the Device    n1    ${user1.name}
