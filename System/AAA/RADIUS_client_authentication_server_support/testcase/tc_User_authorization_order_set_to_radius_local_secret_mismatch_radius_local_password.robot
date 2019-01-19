*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_User_authorization_order_set_to_radius_local_secret_mismatch_radius_local_password
    [Documentation]
      
    ...    1	User-authorization set to radius-local. Radius server is up. SECRET mismatch between radius Server and E7 radius-cfg auth configuration. Login with calix1/hello1 (configured in Radius and E7).	Verify that it is a local login.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4753      @globalid=2534716      @priority=P1      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to radius-local. Radius server is up. SECRET mismatch between radius Server and E7 radius-cfg auth configuration. Login with calix1/hello1 (configured in Radius and E7). Verify that it is a local login. 
    prov_aaa_authentication_order    euta_radius    radius-then-local
    prov_radius_server    euta_radius    ${radius_server}    secret=${invalid_secret}
        
    log    login succeeds
    cli    euta_localsession    configure
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
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession
    dprov_aaa_authentication_order    euta_radius    radius-then-local
    dprov_radius_server    euta_radius    ${radius_server} 
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}
    dprov_aaa_user    euta_radius    ${radius_admin_user}
