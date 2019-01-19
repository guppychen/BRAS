*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=AXOS-WI-6945 10GE-12: Packet Capture support      @author=Min Gu

*** Variables ***


*** Test Cases ***
tc_start_packet_capture_external_interface_ethernet.robot
    [Documentation]
      
    ...    check it can works fine

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4539      @globalid=2533260      @priority=P1      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2    @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
    cli    eutA    start packet-capture external-interface ethernet ${service_model.service_point1.member.interface1}
    ${packet_capture1}    cli    eutA    show packet-capture
    ${server_udp_port}    convert to string    ${server_udp_port}
    ${packets}    convert to string    ${packets}
    should contain    ${packet_capture1}    ${server_add}
    should contain    ${packet_capture1}    ${server_udp_port}
    should contain    ${packet_capture1}    ${packets}
    should contain    ${packet_capture1}    ${start_state}
    should contain    ${packet_capture1}    ${service_model.service_point1.member.interface1}
        
*** Keywords ***
case setup
    log    check it can works fine
case teardown
    log    case over
    Axos Cli With Error Check    eutA   stop packet-capture 
