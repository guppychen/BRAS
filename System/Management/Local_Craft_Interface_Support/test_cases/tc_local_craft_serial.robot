*** Settings ***
Resource          ./base.robot

*** Variables ***
#${craft1}    1
#${craft2}    2
#${craft_serial}    serial
#${craft2_ip}    10.245.46.220
#${craft2_mask}    255.255.255.0
#${craft2_gateway}    10.245.46.1
#${craft2_ip_mask}    10.245.46.220/24
#${baudrate}    115200
#${databits}    8
#${parity}    none
#${stopbits}    1
#${flowcontrl}    none

*** Test Cases ***
tc_local_craft_serial
    [Documentation]    local_craft_serial
    [Tags]    @author=Sean Wang    @globalid=2324701    @tcid=AXOS_E72_PARENT-TC-1843   @feature=Management    @subfeature=Local Craft Interface Support    @priority=P1
    [Setup]    case setup
    log    local_craft_serial
    ${result}    cli    eutA    show interface craft-serial
    should contain    ${result}    craft ${craft_serial}
    should contain    ${result}    ${baudrate}
    should contain    ${result}    ${databits}
    should contain    ${result}    ${parity}
    should contain    ${result}    ${stopbits}
    should contain    ${result}    ${flowcontrl}
    
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    cli    eutB    paginate false
    cli    eutB    show inter craft

case teardown
    log    Enter case teardown
    cli    eutB    show inter craft
    
    
