*** Settings ***
Documentation     An empty password is not considered valid.
Force Tags        @author=clakshma    @feature=AXOS-WI-297 User Support    @subfeature=AXOS_WI_297_user_support
Resource          ./base.robot


*** Variables ***
${usr_alphanumeric}    AlphaNumeric123


*** Test Cases ***
tc_Management_Security_Management_User_Access_Security_Password_Policy_Not_allow_passwords_to_be_empty_blank_or_null
    [Documentation]    1	Create a user using the user agent interfaces that consists of Capital and small alpabets and some alphanumeric characters.	Should be able to create a user	
    ...    2	Leave the password blank	Should not allow creating a blank or empty password	
    ...    3	Create a user using the user agent interfaces that consists of Capital and small alpabets and some alphanumeric characters.		
    ...    4	Create password using space bar	should be able to create passwords using spare bar
    [Tags]       @author=clakshma     @TCID=AXOS_E72_PARENT-TC-2691
    [Setup]      AXOS_E72_PARENT-TC-2691 setup
    [Teardown]   AXOS_E72_PARENT-TC-2691 teardown
    log    STEP:1 Create a user using the user agent interfaces that consists of Capital and small alpabets and some alphanumeric characters. Should be able to create a user
    log    STEP:2 Leave the password blank Should not allow creating a blank or empty password
    cli    n1_session1    conf
    cli    n1_session1    aaa user ${usr_alphanumeric} role oper    Value for 'password'    30
    cli    n1_session1    \x1b    \\#    30
    Result Should contain    failed to apply modifications
    cli    n1_session1    exit    \\#    30
    cli    n1_session1    show running aaa | nomore
    Result should not contain    ${usr_alphanumeric}

    log    STEP:3 Create a user using the user agent interfaces that consists of Capital and small alpabets and some alphanumeric characters.
    log    STEP:4 Create password using space bar should be able to create passwords using spare bar
    cli    n1_session1    conf
    cli    n1_session1    aaa user ${usr_alphanumeric} role oper    Value for 'password'    30
    cli    n1_session1    \x1b \x1b \x1b \x1b     \\#    30
    cli    n1_session1    end
    cli    n1_session1    show running aaa| nomore    \\#    30
    Result should contain    ${usr_alphanumeric}


*** Keywords ***
AXOS_E72_PARENT-TC-2691 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2691 setup


AXOS_E72_PARENT-TC-2691 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2691 teardown

    # Remove configured user
    cli    n1_session1    conf
    cli    n1_session1    no aaa user ${usr_alphanumeric}
    cli    n1_session1    end
    cli    n1_session1    show running aaa| nomore
    Result should not contain    ${usr_alphanumeric}
