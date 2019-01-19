*** Settings ***
Documentation     The EXA device must support consistent authentication of users via each management interface using RADIUS.
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_security_Radius_EXA_Device_must_support_RADIUS_based_authentications_of_users_via_all_management_interfaces_CLI
    [Documentation]
      
    ...    1	configure the system with Radius server and client session (with server IP and shared Secret), and connect to the Radius server network	all parameters are set to default value		
    ...    2	Login from the CLI session. monitor traffic with Wireshark or verify the authenticated client at the Radius server	Session is authenticated, and connection to the system is established/access granted.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-1326      @globalid=2319908      @priority=P1      @eut=10GE-12          @user_interface=CLI    
    [Setup]    case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 configure the system with Radius server and client session (with server IP and shared Secret), and connect to the Radius server network all parameters are set to default value 
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}    retry=${radius_retry}
    prov_aaa_authentication_order    euta_radius    ${authentication}

    log    STEP:2 Login from the CLI session. monitor traffic with Wireshark or verify the authenticated client at the Radius server Session is authenticated, and connection to the system is established/access granted. 
    log    Creating local session for radius user
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    radius_localsession    ${conn}
        
    log    tcpdump for RADIUS messages
    ${RadiusFileName}    generate_pcap_name     radius
    get_packet_capture    eutB_root    radius_localsession    ${interface_craft}    ${radius_server}   ${RadiusFileName}
    
    log    Verify packet capture for access-request and accesss-accept
    analyze_packet_capture    eutB_root    ${RadiusFileName}    ${DEVICES.euta_radius.ip}     ${radius_server}    1=Access-Request
    analyze_packet_capture    eutB_root    ${RadiusFileName}    ${radius_server}    ${DEVICES.euta_radius.ip}     2=Access-Accept
    
    cli    euta_radius    show user-sessions session session-login
    Result should contain    ${radius_admin_user}
  
    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName}"
    
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup    
    dprov_aaa_user    euta_radius    ${radius_admin_user}
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session Destroy Local    radius_localsession
    log    Removing the radius service
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    dprov_radius_server    euta_radius    ${radius_server}
    dprov_aaa_authentication_order    euta_radius    ${authentication}
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName}"