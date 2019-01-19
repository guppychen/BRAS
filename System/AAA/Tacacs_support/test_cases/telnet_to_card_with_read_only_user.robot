*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
telnet_to_card_with_read_only_user
    [Documentation]    telnet_to_card_with_read_only_user
    [Tags]    @author= Sean Wang    @globalid=2533178    @tcid=AXOS_E72_PARENT-TC-4463
    [Setup]    case setup
    log    show run aaa
    ${result}    cli    eutE    show run aaa tacacs
    should contain    ${result}    syntax error: expecting
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown