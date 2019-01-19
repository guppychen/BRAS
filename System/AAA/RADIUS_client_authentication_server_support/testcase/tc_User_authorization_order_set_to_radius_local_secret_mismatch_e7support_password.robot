*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***
${root_user}    root
${root_user_passwd}    root


*** Test Cases ***
tc_User_authorization_order_set_to_radius_local_secret_mismatch_e7support_password
    [Documentation]
      
    ...    1	User-authorization set to radius-local. Radius server is up. SECRET mismatch between radius Server and E7 radius-cfg auth configuration Login with root/root (only local)	Verify that it is a local login.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4756       @globalid=2534719      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to radius-local. Radius server is up. SECRET mismatch between radius Server and E7 radius-cfg auth configuration Login with root/root (only local) Verify that it is a local login. 
    prov_radius_server    euta_radius    ${radius_server}    secret=${invalid_secret}
    prov_aaa_authentication_order    euta_radius    radius-then-local
    
    log    login succeeds
    cli    euta_localsession    configure
    show_user_sessions_contain    euta_radius    ${root_user}
            
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    log    prov RADIUS user    
    ${conn}=    Session copy info    euta_radius    user=${root_user}    password=${root_user_passwd}
    Session build local    euta_localsession    ${conn}
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession
    dprov_radius_server    euta_radius    ${radius_server} 
    dprov_aaa_authentication_order    euta_radius    radius-then-local