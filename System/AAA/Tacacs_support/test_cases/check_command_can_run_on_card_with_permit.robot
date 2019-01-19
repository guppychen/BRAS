*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
check_command_can_run_on_card_with_permit
    [Documentation]    check_command_can_run_on_card_with_permit
    [Tags]    @author= Sean Wang    @globalid=2533149    @tcid=AXOS_E72_PARENT-TC-4434
    [Setup]    case setup
    log    show info
    ${result}    cli    eutD    show card
    should contain    ${result}    syntax error: expecting
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown