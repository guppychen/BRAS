*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=AXOS-WI-6945 10GE-12: Packet Capture support      @author=Min Gu

*** Variables ***


*** Test Cases ***
tc_packet_capture_server_udp_port
    [Documentation]
      
    ...    check it can works fine

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4536      @globalid=2533257      @priority=P1      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2    @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
    ${run_server_udp_port}    cli    eutA    show run packet-capture server-udp-port
    ${server_udp_port}    convert to string    ${server_udp_port}
    should contain    ${run_server_udp_port}    ${server_udp_port}
        
*** Keywords ***
case setup
    log    check it can works fine
case teardown
    log    case over
