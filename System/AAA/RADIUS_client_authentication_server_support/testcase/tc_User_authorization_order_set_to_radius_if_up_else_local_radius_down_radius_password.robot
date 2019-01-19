*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_User_authorization_order_set_to_radius_if_up_else_local_radius_down_radius_password
    [Documentation]
      
    ...    1	User-authorization set to radius-if-up-else-local. Radius server is down. Login with bozo/clown (configured in radius only).. Use Telnet and SSH. Execute the show session command.	Verify that login fails.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4770      @globalid=2534733      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to radius-if-up-else-local. Radius server is down. Login with bozo/clown (configured in radius only).. Use Telnet and SSH. Execute the show session command. Verify that login fails. 
    prov_radius_server    euta_radius    ${invalid_server}    secret=${invalid_secret}
    prov_aaa_authentication_order    euta_radius    radius-if-up-else-local
    
    log    Verify that login fails
    log    telnet, failed
    Run Keyword And Expect Error    SSHLoginException    cli    euta_localsession    configure
    log    SSH, failed
    Run Keyword And Expect Error    SSHLoginException    cli    euta_localsession2    configure
    
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup    
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    dprov_radius_server    euta_radius    ${radius_server}
    log    Creating local session for radius user
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}    protocol=telnet
    Session build local    euta_localsession    ${conn}
    ${conn2}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}     protocol=ssh
    Session build local    euta_localsession2    ${conn2}    
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession
    Session destroy local    euta_localsession2
    log    Removing the invalid radius service
    dprov_radius_server    euta_radius    ${invalid_server}
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}    retry=${radius_retry}
    dprov_aaa_authentication_order    euta_radius    radius-if-up-else-local