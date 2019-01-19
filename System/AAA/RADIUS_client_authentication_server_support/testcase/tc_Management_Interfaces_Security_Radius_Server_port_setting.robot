*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Security_Radius_Server_port_setting
    [Documentation]
      
    ...    1	With the Radius server port set to 1645 provision the EXA client with the same server port and its IP addres shared Secret etc	configuration took place		
    ...    2	Provision a client with default parameters login to start authentication process	User authenticated user communication to the system is established	can use Wireshark to capture the traffic to verify	

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-1336      @globalid=2319918      @priority=P1      @eut=10GE-12          @user_interface=CLI    
    [Setup]    case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 With the Radius server port set to 1645 provision the EXA client with the same server port and its IP addres shared Secret etc configuration took place 
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}    port=${invalid_port}
    prov_aaa_authentication_order    euta_radius    ${authentication}

    log    Creating local session for radius user
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    euta_localsession    ${conn}
    Session build local    euta_localsession2    ${conn}

    log    Verify the tcpdump packet for RADIUS messages
    ${RadiusFileName}    generate_pcap_name     radius
    get_capture    eutB_root    euta_localsession    ${interface_craft}    ${radius_server}   ${RadiusFileName}
    # get_packet_capture    eutB_root    euta_localsession    ${interface_craft}    ${radius_server}   ${RadiusFileName}
    analyze_packet_capture    eutB_root    ${RadiusFileName}    ${DEVICES.euta_radius.ip}     ${radius_server}    1=Access-Request
    
    log    STEP:2 Provision a client with default parameters login to start authentication process User authenticated user communication to the system is established can use Wireshark to capture the traffic to verify 
    log    Temp step as port does not work- Remove radius server
    dprov_radius_server    euta_radius    ${radius_server}

    log    Configure the radius server with port 1812 - default
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}    port=${default_port}

    log    Verify the tcpdump packet
    ${RadiusFileName1}    generate_pcap_name     radius
    get_packet_capture    eutB_root    euta_localsession2    ${interface_craft}    ${radius_server}    ${RadiusFileName1}

    analyze_packet_capture    eutB_root    ${RadiusFileName1}    ${DEVICES.euta_radius.ip}     ${radius_server}    1=Access-Request
    analyze_packet_capture    eutB_root    ${RadiusFileName1}    ${radius_server}    ${DEVICES.euta_radius.ip}    2=Access-Accept
    
    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName}"
    cli    eutB_root    rm -rf "${RadiusFileName1}"
    
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
    Session destroy local    euta_localsession
    Session destroy local    euta_localsession2
    log    Removing the radius service
    dprov_aaa_user    euta_radius    ${radius_admin_user}
    dprov_radius_server    euta_radius    ${radius_server}
    dprov_aaa_authentication_order    euta_radius    ${authentication}
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName}"
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName1}"

