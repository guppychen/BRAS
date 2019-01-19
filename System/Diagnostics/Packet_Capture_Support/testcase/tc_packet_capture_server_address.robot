*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=AXOS-WI-6945 10GE-12: Packet Capture support      @author=Min Gu

*** Variables ***


*** Test Cases ***
tc_packet_capture_server_address
    [Documentation]
      
    ...    check it can works fine

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4535      @globalid=2533256      @priority=P1      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2    @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
    ${run_server_address}    cli    eutA    show run packet-capture server-address
    should contain    ${run_server_address}    ${server_add}
        
*** Keywords ***
case setup
    log    check it can works fine
case teardown
    log    case over
