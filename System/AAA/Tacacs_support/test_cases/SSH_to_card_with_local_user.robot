*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
telnet_to_card_with_local_user
    [Documentation]    telnet_to_card_with_local_user
    [Tags]    @author= Sean Wang    @globalid=2533179    @tcid=AXOS_E72_PARENT-TC-4464
    [Setup]    case setup
    log    show run aaa
    Configure    eutI    aaa tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    ${result}    cli    eutI    show run aaa tacacs
    should contain    ${result}    ${tacacs_ip_1}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    cli    eutI    cli
    Configure    eutI    do show aaa

case teardown
    log    Enter case teardown