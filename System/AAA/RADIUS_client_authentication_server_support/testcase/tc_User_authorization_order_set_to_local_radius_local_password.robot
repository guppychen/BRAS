*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_User_authorization_order_set_to_local_radius_local_password
    [Documentation]
      
    ...    1	User-authorization set to local. Radius server is up. Login with sysadmin/sysadmin (configured in radius and E7). Use Telnet and SSH. Execute the show session command.	Verify that local login succeeds.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4749      @globalid=2534712      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to local. Radius server is up. Login with sysadmin/sysadmin (configured in radius and E7). Use Telnet and SSH. Execute the show session command. Verify that local login succeeds.   
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}
    prov_aaa_authentication_order    euta_radius    local-only
    
    log    Telnet, sysadmin/sysadmin login successed
    cli    euta_localsession    configure
    show_user_sessions_contain    euta_radius    ${user_sysadmin}
    Session destroy local    euta_localsession
    
    log    SSH, sysadmin/sysadmin login successed
    cli    euta_localsession2    configure
    show_user_sessions_contain    euta_radius    ${user_sysadmin}
            
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup    
    log    prov E7 local aaa user: sysadmin/sysadmin
    prov_aaa_user    euta_radius    ${user_sysadmin}    ${user_sys_passwd}    ${role}
    log    prov RADIUS user, euta_radius user/secret is sysadmin/sysadmin 
    ${conn}=    Session copy info    euta_radius    user=${user_sysadmin}    password=${user_sys_passwd}     protocol=telnet
    Session build local    euta_localsession    ${conn}     
    ${conn2}=    Session copy info    euta_radius    user=${user_sysadmin}    password=${user_sys_passwd}     protocol=ssh
    Session build local    euta_localsession2    ${conn2}    
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession2
    Run Keyword And Ignore Error    Session destroy local    euta_localsession
    dprov_radius_server    euta_radius    ${radius_server}
    Run Keyword And Ignore Error    dprov_aaa_user    euta_radius    ${user_sysadmin}