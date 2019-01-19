*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=AXOS-WI-6945 10GE-12: Packet Capture support      @author=Min Gu

*** Variables ***


*** Test Cases ***
tc_switch_controller.robot
    [Documentation]
      
    ...    check it can works fine

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4562      @globalid=2533283      @priority=P1      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2    @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
    ${packet_capture1}    cli    eutA    show packet-capture
    &{dict_card_info}    get_system_equipment_card_info    eutA
    Set Suite Variable    ${old_active_Card}    &{dict_card_info}[active]
    Set Suite Variable    ${old_standby_Card}    &{dict_card_info}[standby]
    
    redundancy_switchover    eutA
    Wait Until Keyword Succeeds    ${p_check_switchover_status}    10s    check_switchover_status    eutA    switchover-dm-in-sync-status="All DMs in sync"
    check_card_info    eutA    ${old_active_Card}    In Service
    check_card_info    eutA    ${old_standby_Card}    In Service
    check_system_equipment_info    eutA    active-controller=${old_standby_Card}    standby-controller=${old_active_Card}
    check_system_equipment_info    eutA    active-controller=${old_active_Card}    standby-controller=${old_standby_Card}    contain=no
    ${packet_capture2}    cli    eutA    show packet-capture
    should be equal    ${packet_capture1}    ${packet_capture2}
        
*** Keywords ***
case setup
    log    start the packet-capture
    cli    eutA    start packet-capture external-interface ethernet ${service_model.service_point1.member.interface1}
case teardown
    log    case over
    Axos Cli With Error Check    eutA   stop packet-capture