*** Settings ***
Resource          ./base.robot

*** Variables ***
#${craft1}    1
#${craft2}    2
#${craft1_ip}    192.168.1.100
#${craft1_mask}    255.255.255.0
#${craft1_gateway}    192.168.1.1
#${craft1_ip_mask}    192.168.1.100/24

*** Test Cases ***
tc_show_local_craft
    [Documentation]    prov inter craft 1
    [Tags]    @author=Sean Wang    @globalid=2319904    @tcid=AXOS_E72_PARENT-TC-1323   @feature=Management    @subfeature=Local Craft Interface Support    @priority=P1
    [Setup]    case setup
    log    STEP:1 prov inter craft 1
    ${result}    cli    eutB    show inter craft
    should contain    ${result}    craft ${craft1}
    should contain    ${result}    craft ${craft2}
    prov_interface    eutB    craft    ${craft1}    no=shut
    prov_interface    eutB    craft    ${craft1}    ip address=${craft1_ip_mask}
    Wait Until Keyword Succeeds    30 sec    10 sec    check craft connected    eutA    ${craft1}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    cli    eutB    paginate false
    cli    eutB    show inter craft

case teardown
    log    Enter case teardown
    cli    eutB    show inter craft
    
check craft connected
    [Arguments]    ${eut}    ${craft_no}
    ${result}    cli    ${eut}    show inter craft ${craft_no}
    should contain    ${result}    ${craft1_ip_mask}
    should contain    ${result}    admin-state     enable
