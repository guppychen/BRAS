*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=AXOS-WI-6945 10GE-12: Packet Capture support      @author=Min Gu

*** Variables ***


*** Test Cases ***
tc_stop_packet_capture.robot
    [Documentation]
      
    ...    check it can works fine

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4553      @globalid=2533274      @priority=P1      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2    @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
    cli    eutA   stop packet-capture
    ${packet_capture1}    cli    eutA    show packet-capture
    ${server_udp_port}    convert to string    ${server_udp_port}
    ${packets}    convert to string    ${packets}
    should contain    ${packet_capture1}    ${server_add}
    should contain    ${packet_capture1}    ${server_udp_port}
    should contain    ${packet_capture1}    ${packets}
    should contain    ${packet_capture1}    ${default_state2}
    should contain    ${packet_capture1}    ${default_capture_source}
        
*** Keywords ***
case setup
    log    check it can works fine
    cli    eutA    start packet-capture external-interface ethernet ${service_model.service_point1.member.interface1}
case teardown
    log    case over
