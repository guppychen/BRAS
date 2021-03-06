*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_User_authorization_order_set_to_radius_local_secret_mismatch_local_password
    [Documentation]
      
    ...    1	User-authorization set to radius-local. Radius server is up. SECRET mismatch between Radius Server and E7 radius-cfg auth configuration. Login with blank/blanker (configured only in E7). Use Telnet and SSH. Execute the show session command.	Verify that it is a local login.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4755      @globalid=2534718      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to radius-local. Radius server is up. SECRET mismatch between Radius Server and E7 radius-cfg auth configuration. Login with blank/blanker (configured only in E7). Use Telnet and SSH. Execute the show session command. Verify that it is a local login. 
    prov_radius_server    euta_radius    ${radius_server}    secret=${invalid_secret}
    prov_aaa_authentication_order    euta_radius    radius-then-local
    
    log    Telnet, login succeeds
    cli    euta_localsession    configure
    show_user_sessions_contain    euta_radius    ${local_user_blank}
    Session destroy local    euta_localsession
    
    log    SSH, login succeeds
    cli    euta_localsession2    configure
    show_user_sessions_contain    euta_radius    ${local_user_blank}
            
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    log    prov E7 local aaa user, ${local_user_blank} configured only in E7
    prov_aaa_user    euta_radius    ${local_user_blank}    ${local_blank_passwd}    ${role}
    log    prov RADIUS user    
    ${conn}=    Session copy info    euta_radius    user=${local_user_blank}    password=${local_blank_passwd}    protocol=telnet
    Session build local    euta_localsession    ${conn}     
    ${conn2}=    Session copy info    euta_radius    user=${local_user_blank}    password=${local_blank_passwd}    protocol=ssh
    Session build local    euta_localsession2    ${conn2}    
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession2
    Run Keyword And Ignore Error    Session destroy local    euta_localsession
    dprov_radius_server    euta_radius    ${radius_server} 
    dprov_aaa_user    euta_radius    ${local_user_blank}
    prov_radius_server    eutB_root    ${radius_server}    secret=${secret}    retry=${radius_retry}
    dprov_aaa_authentication_order    euta_radius    radius-then-local