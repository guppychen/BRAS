*** Settings ***
Documentation     The EXA Device MUST NOT allow a user to exit the CLI, when logged in with role oper, admin or networkadmin and return to the linux operating system environment. Upon exit from an CLI, the telnet session should be terminated logging the user out of the System.
Force Tags        @Feature=AXOS-WI-305 CLI_Support    @subfeature=AXOS-WI-305 CLI_Support    @author=kshettar
Resource          ./base.robot

*** Variables ***
${operator_usr}    operator
${operator_pwd}    operator123
${network_usr}    netadmin
${network_pwd}    netadmin123
${admin_usr}    admintest
${admin_pwd}    admintest123

*** Test Cases ***
tc_EXA_Device_MUST_not_support_users_exiting_the_CLI_to_access_the_shell_Unless_Logged_In_With_Root_Root_Privilege
    [Documentation]    1. The EXA Device MUST NOT allow a user to exit the CLI, when logged in with role oper, admin or networkadmin and return to the linux operating system environment. Upon exit from an CLI, the telnet session should be terminated logging the user out of the System. As Stated
    [Tags]    @author=kshettar    @TCID=AXOS_E72_PARENT-TC-2429
    [Setup]     AXOS_E72_PARENT-TC-2429 setup
    log    STEP:1. The EXA Device MUST NOT allow a user to exit the CLI, when logged in with role oper, admin or networkadmin and return to the linux operating system environment. Upon exit from an CLI, the telnet session should be terminated logging the user out of the System. As Stated
    
    #Admin Login and cli exit
    ${conn}=    Session copy info    n1_session1    user=${admin_usr}    password=${admin_pwd}
    Session build local    n1_localsession1    ${conn}
    cli    n1_localsession1    show running-config aaa | nomore    \\#    30
    Result Should Contain    ${admin_usr}
    cli    n1_localsession1    exit    $    10
    Result should not contain    root
    
    #Oper Login and cli exit
    ${conn}=    Session copy info    n1_session1    user=${operator_usr}    password=${operator_pwd}
    Session build local    n1_localsession2    ${conn}
    cli    n1_localsession2    show running-config aaa | nomore    \\#    30
    Result Should Contain    ${operator_usr}
    cli    n1_localsession2    exit    $    10
    Result should not contain    root

    #Network admin Login and cli exit
    ${conn}=    Session copy info    n1_session1    user=${network_usr}    password=${network_pwd}
    Session build local    n1_localsession3    ${conn}
    cli    n1_localsession3    show running-config aaa | nomore    \\#    30
    Result Should Contain    ${network_usr}
    cli    n1_localsession3    exit    $    10
    Result should not contain    root

    [Teardown]    AXOS_E72_PARENT-TC-2429 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-2429 setup 
    [Documentation]    setup
    log    Enter AXOS_E72_PARENT-TC-2429 setup
    #Destroy local session
    Session destroy local    n1_localsession1
    Session destroy local    n1_localsession2
    Session destroy local    n1_localsession3

    # Adding the user
    cli    n1_session1    conf
    cli    n1_session1    no aaa user ${operator_usr}
    cli    n1_session1    no aaa user ${network_usr}
    cli    n1_session1    no aaa user ${admin_usr}
    cli    n1_session1    aaa user ${operator_usr} password ${operator_pwd} role oper
    cli    n1_session1    aaa user ${network_usr} password ${network_pwd} role networkadmin
    cli    n1_session1    aaa user ${admin_usr} password ${admin_pwd} role admin
    cli    n1_session1    end

AXOS_E72_PARENT-TC-2429 teardown
    [Documentation]    teardown
    log    Enter AXOS_E72_PARENT-TC-2429 teardown
    #Destroy local session
    Session destroy local    n1_localsession1
    Session destroy local    n1_localsession2
    Session destroy local    n1_localsession3

    # Removing the user
    cli    n1_session1    conf
    cli    n1_session1    no aaa user ${operator_usr}
    cli    n1_session1    no aaa user ${network_usr}
    cli    n1_session1    no aaa user ${admin_usr}
    cli    n1_session1    end
