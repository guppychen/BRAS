*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_User_authorization_order_set_to_radius_local_secret_mismatch_radius_password
    [Documentation]
      
    ...    1	User-authorization set to radius-local. Radius server is up. SECRET mismatch between radius Server and E7 radius-cfg auth configuration. Login with calix1/hello1 (configured only in radius). Use Telnet and SSH. Execute the show session command.	Verify that login fails		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4754      @globalid=2534717      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to radius-local. Radius server is up. SECRET mismatch between radius Server and E7 radius-cfg auth configuration. Login with calix1/hello1 (configured only in radius). Use Telnet and SSH. Execute the show session command. Verify that login fails 
    prov_aaa_authentication_order    euta_radius    radius-then-local
    prov_radius_server    euta_radius    ${radius_server}    secret=${invalid_secret}
    
    log    Telnet, login failed
    Run Keyword And Expect Error    SSHLoginException    cli    euta_localsession    configure
    
    log    SSH, login failed
    Run Keyword And Expect Error    SSHLoginException    cli    euta_localsession2    configure
      
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    dprov_aaa_user    euta_radius    ${radius_admin_user}
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
    Session destroy local    euta_localsession
    dprov_radius_server    euta_radius    ${radius_server} 
    dprov_aaa_authentication_order    euta_radius    radius-then-local