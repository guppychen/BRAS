*** Settings ***
Documentation     The EXA Device must appear to perform the entire user authentication procedure, even if the user ID that is entered is not valid. This is to ensure that the appropriate logs, and notifications are properly emitted.  e.g. the device will post an entry to the security log whenever a login attempt occurs where the entry includes a field that identifies the success or failure of said attempt.
Force Tags        @author=ysnigdha    @feature=AXOS-WI-297 User Support    @subfeature=AXOS_WI_297_user_support
Resource          ./base.robot


*** Variables ***
${command}        //system/user-sessions
${invalid_usr}    nobody
${invalid_pwd}    nopassword


*** Test Cases ***
tc_Management_Security_Management_User_Access_Security_Entire_login_User_ID_Invalid
    [Documentation]    1	Enter a invalid User ID to login to the system	Should not display any error message
    ...    2	Enter an invalid password for the invalid user ID	Should deny access to login to the system , but should not display why the access failed (Example login failed due to wrong user ID or wrong password)
    ...    3	Enter a valid user ID to login to the System	Should not display any error message
    ...    4	Enter the password for the valid user ID	Should be able to successfully login to the system
    ...    5	Verify in audit/security log all unauthorized invalid login attempts and valid login attempts is logged
    ...    6	Verify that passwords are not logged during failed/successful login attempts
    [Tags]       @author=ysnigdha     @TCID=AXOS_E72_PARENT-TC-2694
    [Setup]      AXOS_E72_PARENT-TC-2694 setup
    [Teardown]   AXOS_E72_PARENT-TC-2694 teardown

    log    STEP:1 Enter a invalid User ID to login to the system Should not display any error message
    ${conn}=    Session copy info    n1_session3    user=${invalid_usr}    password=${operator_pwd}
    Session build local    n1_localsession1    ${conn}
    ${msg}    Run Keyword And Expect Error    *    Netconf Get    n1_localsession1    xpath    ${command}
    Should contain    ${msg}    AuthenticationError

    log    STEP:2 Enter an invalid password for the invalid user ID Should deny access to login to the system , but should not display why the access failed (Example login failed due to wrong user ID or wrong password)
    ${conn}=    Session copy info    n1_session3    user=${invalid_usr}    password=${invalid_pwd}
    Session build local    n1_localsession2    ${conn}
    ${msg}    Run Keyword And Expect Error    *    Netconf Get    n1_localsession2    xpath     ${command}
    Should contain    ${msg}    AuthenticationError

    log    STEP:3 Enter a valid user ID to login to the System Should not display any error message
    log    STEP:4 Enter the password for the valid user ID Should be able to successfully login to the system
    ${conn}=    Session copy info    n1_session3    user=${operator_usr}    password=${operator_pwd}
    Session build local    n1_localsession3    ${conn}
    @{elem}    Get attributes netconf    n1_localsession3    //system/version    distro  #description
    :For   ${elem}  in  @{elem}
    \     ${res}    XML.Get Element Text    ${elem}
    \      Should Not Be Empty    ${res}

    log    STEP:5 Verify in audit/security log all unauthorized invalid login attempts and valid login attempts is logged
    log    STEP:6 Verify that passwords are not logged during failed/successful login attempts
    # Cannot automate as Netconf does not support this command



*** Keywords ***
AXOS_E72_PARENT-TC-2694 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2694 setup
    ${add_config}    convert to string   <config><config xmlns="http://www.calix.com/ns/exa/base"><system><aaa><user operation="create"><name>${operator_usr}</name><password>${operator_pwd}</password><role>oper</role></user></aaa></system></config></config>
    Netconf Edit Config      n1_session3     ${add_config}    target=running
    cli    n1_session1    logout user sysadmin    timeout_exception=0

AXOS_E72_PARENT-TC-2694 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2694 teardown

    # Removing the local session
    Session destroy local    n1_localsession1
    Session destroy local    n1_localsession2
    Session destroy local    n1_localsession3

    # Removing the user
    ${delete_config}    convert to string    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><aaa><user operation="delete"><name>${operator_usr}</name></user></aaa></system></config></config>
    Netconf Edit Config      n1_session3    ${delete_config}    target=running
    cli    n1_session1    configure
    cli    n1_session1    end
    cli    n1_session1    logout user sysadmin     timeout_exception=0
    cli    n1_session1    show user-sessions