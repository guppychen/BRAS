*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_User_authorization_order_set_to_radius_if_up_else_local_secret_mismatch_radius_local_password
    [Documentation]
      
    ...    1	User-authorization set to radius-if-up-else-local. Radius server is up. SECRET mismatch between radius server and E7 radius-cfg auth configuration. Login with e7/admin (configured in radius and E7). Use Telnet and SSH. Execute the show session command.	Verify radius login fails and that local login succeeds.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4765      @globalid=2534728      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to radius-if-up-else-local. Radius server is up. SECRET mismatch between radius server and E7 radius-cfg auth configuration. Login with e7/admin (configured in radius and E7). Use Telnet and SSH. Execute the show session command. Verify radius login fails and that local login succeeds. 
    prov_aaa_authentication_order    euta_radius    radius-if-up-else-local
    prov_radius_server    euta_radius    ${radius_server}    secret=${invalid_secret}
    
    log    login succeeds
    cli    euta_localsession    configure
    show_user_sessions_contain    euta_radius    ${radius_admin_user}
    Session destroy local    euta_localsession
    show_user_sessions_nocontain    euta_radius    ${radius_admin_user}
    
    log    SSH, login succeeds
    cli    euta_localsession2    configure
    show_user_sessions_contain    euta_radius    ${radius_admin_user}
    
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    dprov_radius_server    euta_radius    ${radius_server}   
    log    prov local user
    prov_aaa_user    euta_radius    ${radius_admin_user}    ${radius_admin_password}
    log    prov RADIUS user
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    euta_localsession    ${conn}
    ${conn2}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    euta_localsession2    ${conn2}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession2
    Run Keyword And Ignore Error    Session destroy local    euta_localsession
    dprov_radius_server    euta_radius    ${radius_server} 
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    dprov_aaa_authentication_order    euta_radius    radius-if-up-else-local