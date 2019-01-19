*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_User_authorization_order_set_to_radius_if_up_else_local_radius_down_radius_local_password
    [Documentation]
      
    ...    1	User-authorization set to radius-if-up-else-local. Radius server is down. Login with calix1/hello1  (configured on radius and E7) Use Telnet and SSH. Execute the show session command.	Verify that it is a local login.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4769      @globalid=2534732      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 User-authorization set to radius-if-up-else-local. Radius server is down. Login with calix1/hello1 (configured on radius and E7) Use Telnet and SSH. Execute the show session command. Verify that it is a local login. 
    prov_aaa_authentication_order    euta_radius    radius-if-up-else-local
    prov_radius_server    euta_radius    ${invalid_server}    secret=${invalid_secret}
    
    log    Telnet, login successed
    cli    euta_localsession    configure
    show_user_sessions_contain    euta_radius    ${radius_admin_user}
    Session destroy local    euta_localsession
    show_user_sessions_nocontain    euta_radius    ${radius_admin_user}
    
    log    SSH, login successed
    cli    euta_localsession2    configure
    show_user_sessions_contain    euta_radius    ${radius_admin_user}
      
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    log    dprov valid server
    dprov_radius_server    euta_radius    ${radius_server}
    prov_aaa_user    euta_radius    ${radius_admin_user}    ${radius_admin_password}    ${role}
    log    prov new session    
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}    protocol=telnet
    Session build local    euta_localsession    ${conn}        
    ${conn2}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}     protocol=ssh
    Session build local    euta_localsession2    ${conn2}    
        
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession2
    Run Keyword And Ignore Error    Session destroy local    euta_localsession
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    log    prov invalid server
    dprov_radius_server    euta_radius    ${invalid_server}
    prov_radius_server    eutB_root    ${radius_server}    secret=${secret}    retry=${radius_retry}
    dprov_aaa_authentication_order    euta_radius    radius-if-up-else-local
    
