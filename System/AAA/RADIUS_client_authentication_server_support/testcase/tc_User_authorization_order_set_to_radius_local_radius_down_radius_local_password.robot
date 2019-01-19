*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_User_authorization_order_set_to_radius_local_radius_down_radius_local_password
    [Documentation]
      
    ...    1	User-authorization set to radius-local. Radius server is down. Login with calix1/hello1 (configured in radius and E7).	Verify that it is a local login.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4757      @globalid=2534720      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to radius-local. Radius server is down. Login with calix1/hello1 (configured in radius and E7). Verify that it is a local login. 
    prov_aaa_authentication_order    euta_radius    radius-then-local
    prov_radius_server    euta_radius    ${invalid_server}    secret=${invalid_secret}
    
    cli    euta_localsession    configure
    show_user_sessions_contain    euta_radius    ${radius_admin_user}

      
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    prov_aaa_user    euta_radius    ${radius_admin_user}    ${radius_admin_password}    
    dprov_radius_server    euta_radius    ${radius_server}
    log    prov new session    
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    euta_localsession    ${conn}   
        
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession
    dprov_radius_server    euta_radius    ${invalid_server}
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    prov_radius_server    eutB_root    ${radius_server}    secret=${secret}    retry=${radius_retry}
    dprov_aaa_authentication_order    euta_radius    radius-then-local