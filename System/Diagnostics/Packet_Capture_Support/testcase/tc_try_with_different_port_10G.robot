*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=AXOS-WI-6945 10GE-12: Packet Capture support      @author=Min Gu

*** Variables ***


*** Test Cases ***
tc_try_with_different_port_10G.robot
    [Documentation]
      
    ...    check it can works fine

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4554      @globalid=2533275      @priority=P1      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2    @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
    cli    eutA    start packet-capture external-interface ethernet ${service_model.service_point1.member.interface2}
    &{dict_card_info}    get_system_equipment_card_info    eutA
    ${card_num}    set variable    &{dict_card_info}[active]
    ${packet_capture_active}    cli    eutA    show packet-capture ${card_num}
    ${server_udp_port}    convert to string    ${server_udp_port}
    ${packets}    convert to string    ${packets}
    should contain    ${packet_capture_active}    ${server_add}
    should contain    ${packet_capture_active}    ${server_udp_port}
    should contain    ${packet_capture_active}    ${packets}
    should contain    ${packet_capture_active}    ${start_state}
    should contain    ${packet_capture_active}    ${service_model.service_point1.member.interface2}
        
        
*** Keywords ***
case setup
    log    check it can works fine
case teardown
    log    case over
    cli    eutA   stop packet-capture
