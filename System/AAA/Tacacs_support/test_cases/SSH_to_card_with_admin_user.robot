*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
SSH_to_card_with_admin_user
    [Documentation]    SSH_to_card_with_admin_user
    [Tags]    @author= Sean Wang    @globalid=2533176    @tcid=AXOS_E72_PARENT-TC-4461
    [Setup]    case setup
    log    show run aaa
    Configure    eutG    aaa tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    ${result}    cli    eutG    show run aaa tacacs
    should contain    ${result}    ${tacacs_ip_1}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutG    do show aaa

case teardown
    log    Enter case teardown