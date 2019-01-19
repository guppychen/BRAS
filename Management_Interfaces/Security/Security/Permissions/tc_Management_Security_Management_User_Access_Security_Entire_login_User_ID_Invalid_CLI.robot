*** Settings ***
Documentation     The EXA Device must appear to perform the entire user authentication procedure, even if the user ID that is entered is not valid. This is to ensure that the appropriate logs, and notifications are properly emitted.  e.g. the device will post an entry to the security log whenever a login attempt occurs where the entry includes a field that identifies the success or failure of said attempt.
Force Tags        @author=ysnigdha    @feature=AXOS-WI-297 User Support    @subfeature=AXOS_WI_297_user_support
Resource          ./base.robot


*** Variables ***
${verify1}    session opened for user ${operator_usr}
${verify2}    audit user: ${operator_usr}
${verify3}    Failed password for ${invalid_usr}
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

    ${login_date_time}    cli    n1_session1    show clock

    log    STEP:1 Enter a invalid User ID to login to the system Should not display any error message
    ${conn}=    Session copy info    n1_session1    user=${invalid_usr}    password=${operator_pwd}
    Session build local    n1_localsession1    ${conn}
    Run Keyword And Expect Error    SSHLoginException    Cli     n1_localsession1    show version    \\#    30

    log    STEP:2 Enter an invalid password for the invalid user ID Should deny access to login to the system , but should not display why the access failed (Example login failed due to wrong user ID or wrong password)
    ${conn}=    Session copy info    n1_session1    user=${invalid_usr}    password=${invalid_pwd}
    Session build local    n1_localsession2    ${conn}
    Run Keyword And Expect Error    SSHLoginException    Cli     n1_localsession2    show version    \\#    30

    log    STEP:5 Verify in audit/security log all unauthorized invalid login attempts and valid login attempts is logged
    ${formatted_time}    Get formatted date time    ${login_date_time}
    Wait Until Keyword Succeeds   2 min   5 sec   Verify SysLog Entry     n1_session1    ${formatted_time}    authentication failure.*user=${invalid_usr}
    Wait Until Keyword Succeeds   2 min   5 sec   Verify SysLog Entry     n1_session1    ${formatted_time}   ${verify3}

    ${login_date_time}    cli    n1_session1    show clock

    log    STEP:3 Enter a valid user ID to login to the System Should not display any error message
    log    STEP:4 Enter the password for the valid user ID Should be able to successfully login to the system
    ${conn}=    Session copy info    n1_session1    user=${operator_usr}    password=${operator_pwd}
    Session build local    n1_localsession3    ${conn}
    Cli     n1_localsession3    show version


    log    STEP:6 Verify that passwords are not logged during failed/successful login attempts
    ${formatted_time}    Get formatted date time    ${login_date_time}
    Wait Until Keyword Succeeds   2 min   5 sec   Verify SysLog Entry    n1_session1    ${formatted_time}   ${verify1}
    Wait Until Keyword Succeeds   2 min   5 sec   Verify AuditLog Entry     n1_session1    ${formatted_time}   ${verify2}


*** Keywords ***
AXOS_E72_PARENT-TC-2694 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2694 setup

    # Adding the user
    cli    n1_session1    conf
    cli    n1_session1    aaa user ${operator_usr} password ${operator_pwd} role oper
    cli    n1_session1    end


AXOS_E72_PARENT-TC-2694 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2694 teardown

    # Destroy local sessions created
    Session destroy local    n1_localsession1
    Session destroy local    n1_localsession2
    Session destroy local    n1_localsession3

    # Removing the user
    cli    n1_session1    conf
    cli    n1_session1    no aaa user ${operator_usr}
    cli    n1_session1    end
