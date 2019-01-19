*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_show_local_craft
    [Documentation]    show inter craft
    [Tags]    @author=Sean Wang    @globalid=2319903    @tcid=AXOS_E72_PARENT-TC-1322   @feature=Management    @subfeature=Local Craft Interface Support    @priority=P1
    [Setup]    case setup
    log    STEP:1 show inter craft
    ${result}    cli    eutA    show inter craft
    should contain    ${result}    craft 1
    should contain    ${result}    craft 2
    
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    cli    eutA    paginate false
    cli    eutA    show inter craft

case teardown
    log    Enter 2143103 teardown
    cli    eutA    show inter craft
