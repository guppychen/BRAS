*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_radius_if_up_else_local_Authentication_Order
    [Documentation]
      
    ...    1	Configure "authentication-order" as radius-if-up-else-local	Config should be successful		
    ...    2	Authenticate using RADIUS user	Provided config is correct; authentication should be successful		
    ...    3	Change RADIUS config so that it was incorrect secret	Config should be successful		
    ...    4	Try to authenticate using local user	Authentication should fall back to local and provided credentials are correct; it should be successful.		
    ...    5	Check alarms/evemts	Appropriate fallback alarm should be generated.		
    ...    6	Test above steps with unreachable RADIUS server	Results should be consistent		
    ...    7	While RADIUS is configured correctly; try to authenticate as local user	Authentication should be rejected and appropriate event should be generated.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-1343      @globalid=2319925      @priority=P1      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 Configure "authentication-order" as radius-if-up-else-local Config should be successful 
    prov_aaa_authentication_order    euta_radius    radius-if-up-else-local 
    
    log    STEP:2 Authenticate using RADIUS user Provided config is correct; authentication should be successful 
    log    tcpdump for RADIUS messages
    ${RadiusFileName}    generate_pcap_name     radius
    get_packet_capture    eutB_root     euta_localsession1    ${interface_craft}    ${radius_server}   ${RadiusFileName}

    log   Verify packet capture for access-request and accesss-accept
    analyze_packet_capture    eutB_root     ${RadiusFileName}    ${DEVICES.euta_radius.ip}     ${radius_server}    1=Access-Request
    analyze_packet_capture    eutB_root     ${RadiusFileName}    ${radius_server}    ${DEVICES.euta_radius.ip}     2=Access-Accept
    
    cli    eutB_root    rm -rf "${RadiusFileName}"
    
    log    STEP:3 Change RADIUS config so that it was incorrect secret Config should be successful 
    dprov_radius_server    euta_radius    ${radius_server} 
    prov_radius_server    euta_radius    ${radius_server}    secret=${invalid_secret}
    
    log    STEP:4 Try to authenticate using local user Authentication should fall back to local and provided credentials are correct; it should be successful. 
    ${RadiusFileName1}    generate_pcap_name     radius
    get_packet_capture    eutB_root     euta_localsession2    ${interface_craft}    ${radius_server}   ${RadiusFileName1}
    
    log   Verify packet capture for access-request
    analyze_packet_capture    eutB_root     ${RadiusFileName1}    ${DEVICES.euta_radius.ip}     ${radius_server}    1=Access-Request
    analyze_packet_capture    eutB_root     ${RadiusFileName1}     ${radius_server}    ${DEVICES.euta_radius.ip}    3=Access-Reject
    
    log    STEP:5 Check alarms/evemts Appropriate fallback alarm should be generated. 
    show_alarm_authentication    euta_radius    radius-secret-invalid
    show_alarm_authentication    euta_radius    fallback-to-localauthentication
    
    cli    eutB_root    rm -rf "${RadiusFileName1}"
    
    log    STEP:6 Test above steps with unreachable RADIUS server Results should be consistent 
    log    using RADIUS user login
    Run Keyword And Expect Error    SSHLoginException    cli    euta_localsession3    configure
    log    Check alarms/evemts Appropriate
    show_alarm_authentication    euta_radius    radius-server-unreachable
   
    log    STEP:7 While RADIUS is configured correctly; try to authenticate as local user Authentication should be rejected and appropriate event should be generated. 
    log    using local user login
    cli    euta_localsession4    configure
    log    Check alarms/evemts Appropriate
    show_alarm_authentication    euta_radius    fallback-to-localauthentication
        
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    log    prov unreachable RADIUS
    prov_radius_server    euta_radius    ${invalid_server}    secret=${invalid_secret}
    log    prov RADIUS user    
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    euta_localsession1    ${conn}   
    Session build local    euta_localsession3    ${conn}        
    log    prov local user
    prov_aaa_user    euta_radius    ${local_user_blank}    ${local_blank_passwd}    ${role}
    ${conn2}=    Session copy info    euta_radius    user=${local_user_blank}    password=${local_blank_passwd}
    Session build local    euta_localsession2    ${conn2}
    Session build local    euta_localsession4    ${conn2}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession4
    Session destroy local    euta_localsession3
    Session destroy local    euta_localsession2
    Session destroy local    euta_localsession1
    dprov_aaa_user    euta_radius    ${local_user_blank}
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    dprov_radius_server    euta_radius    ${invalid_server}
    dprov_radius_server    euta_radius    ${radius_server} 
    dprov_aaa_authentication_order    euta_radius    radius-if-up-else-local
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName}"
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName1}"