*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=AXOS-WI-6945 10GE-12: Packet Capture support      @author=Min Gu

*** Variables ***


*** Test Cases ***
tc_show_packet_capture
    [Documentation]
      
    ...    check it can works fine

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4538      @globalid=2533259      @priority=P1      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2    @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
    ${run_packet_capture}    cli    eutA    show packet-capture
    ${server_udp_port}    convert to string    ${server_udp_port}
    ${packets}    convert to string    ${packets}
    should contain    ${run_packet_capture}    ${server_add}
    should contain    ${run_packet_capture}    ${server_udp_port}
    should contain    ${run_packet_capture}    ${packets}
    should match regexp    ${run_packet_capture}    [${default_state1},${default_state2}]
        
*** Keywords ***
case setup
    log    check it can works fine
case teardown
    log    case over
