*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_User_authorization_order_set_to_radius_local_radius_local_password
    [Documentation]
      
    ...    1	User-authorization set to radius-local. Radius server is up. Login with calix1/hello1 (configured in radius and E7). Use Telnet and SSH. Execute the show session command.	Verify that it is a radius login.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4750      @globalid=2534713      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to radius-local. Radius server is up. Login with calix1/hello1 (configured in radius and E7). Use Telnet and SSH. Execute the show session command. Verify that it is a radius login.    
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}
    prov_aaa_authentication_order    euta_radius    radius-then-local

    log    Telnet, login succeeds
    cli    euta_localsession    configure
    show_user_sessions_contain    euta_radius    ${radius_admin_user}
    Session destroy local    euta_localsession
    
    log    SSH, login succeeds
    cli    euta_localsession2    configure
    show_user_sessions_contain    euta_radius    ${radius_admin_user}
            
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    log    prov E7 local aaa user
    prov_aaa_user    euta_radius    ${radius_admin_user}    ${radius_admin_password}    ${role}
    log    prov RADIUS user    
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}    protocol=telnet
    Session build local    euta_localsession    ${conn}     
    ${conn2}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}    protocol=ssh
    Session build local    euta_localsession2    ${conn2}    
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession2
    Run Keyword And Ignore Error    Session destroy local    euta_localsession
    dprov_radius_server    euta_radius    ${radius_server} 
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    dprov_aaa_authentication_order    euta_radius    radius-then-local