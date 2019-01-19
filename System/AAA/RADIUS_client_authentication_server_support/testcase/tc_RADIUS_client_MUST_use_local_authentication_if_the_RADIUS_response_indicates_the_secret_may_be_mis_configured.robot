*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_RADIUS_client_MUST_use_local_authentication_if_the_RADIUS_response_indicates_the_secret_may_be_mis_configured
    [Documentation]
      
    ...    1	Configure "authentication-order" as radius-then-local	Config should be successful		
    ...    2	Authenticate using RADIUS user	Provided config is correct; authentication should be successful		
    ...    3	Change RADIUS config so that it was incorrect secret	Config should be successful		
    ...    4	Try to authenticate using local user	Authentication should fall back to local and provided credentials are correct; it should be successful.		
    ...    5	Check alamrs/evemts	Appropriate fallback alarm should be generated.		
    ...    6	Test above steps with tacacs then local and local only orders	Results should be consistent		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-1342      @globalid=2319924      @priority=P1      @eut=VDSL2-35b    @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 Configure "authentication-order" as radius-then-local Config should be successful 
    prov_aaa_authentication_order    euta_radius    radius-then-local
    
    log    STEP:2 Authenticate using RADIUS user Provided config is correct; authentication should be successful     
    log     using RADIUS user, tcpdump for RADIUS messages
    ${RadiusFileName}    generate_pcap_name     radius
    get_packet_capture    eutB_root     euta_localsession    ${interface_craft}    ${radius_server}   ${RadiusFileName}

    log   Verify packet capture for access-request and accesss-accept
    analyze_packet_capture    eutB_root     ${RadiusFileName}    ${DEVICES.euta_radius.ip}     ${radius_server}    1=Access-Request
    analyze_packet_capture    eutB_root     ${RadiusFileName}    ${radius_server}    ${DEVICES.euta_radius.ip}     2=Access-Accept
    
    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName}"
    
    log    STEP:3 Change RADIUS config so that it was incorrect secret Config should be successful 
    dprov_radius_server    euta_radius    ${radius_server} 
    prov_radius_server    euta_radius    ${radius_server}    secret=${invalid_secret}
    
    log    STEP:4 Try to authenticate using local user Authentication should fall back to local and provided credentials are correct; it should be successful. 
    log     using local user, tcpdump for RADIUS messages
    ${RadiusFileName1}    generate_pcap_name     radius
    get_packet_capture    eutB_root     euta_localsession2    ${interface_craft}    ${radius_server}   ${RadiusFileName1}
    
    log   Verify packet capture for access-request
    analyze_packet_capture    eutB_root     ${RadiusFileName1}    ${DEVICES.euta_radius.ip}     ${radius_server}    1=Access-Request
    analyze_packet_capture    eutB_root     ${RadiusFileName1}     ${radius_server}    ${DEVICES.euta_radius.ip}    3=Access-Reject
    
    log    STEP:5 Check alamrs/evemts Appropriate fallback alarm should be generated.
    show_alarm_authentication    euta_radius    fallback-to-localauthentication
    show_alarm_authentication    euta_radius    radius-secret-invalid
                            
    log    STEP:6 Test above steps with tacacs then local and local only orders Results should be consistent 

    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName1}"
    
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    log    prov RADIUS user
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    euta_localsession    ${conn}        
    log    prov local user
    prov_aaa_user    euta_radius    ${local_user_blank}    ${local_blank_passwd}    ${role}
    ${conn2}=    Session copy info    euta_radius    user=${local_user_blank}    password=${local_blank_passwd}
    Session build local    euta_localsession2    ${conn2}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession2
    Session destroy local    euta_localsession
    dprov_aaa_user    euta_radius    ${local_user_blank}
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    dprov_radius_server    euta_radius    ${radius_server} 
    dprov_aaa_authentication_order    euta_radius    radius-then-local
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName}"
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName1}"