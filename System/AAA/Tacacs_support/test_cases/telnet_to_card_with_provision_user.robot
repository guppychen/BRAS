*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
telnet_to_card_with_provision_user
    [Documentation]    telnet_to_card_with_provision_user
    [Tags]    @author= Sean Wang    @globalid=2533177    @tcid=AXOS_E72_PARENT-TC-4462
    [Setup]    case setup
    log    show run aaa
    Configure    eutH    aaa tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    ${result}    cli    eutH    show run aaa tacacs
    should contain    ${result}    ${tacacs_ip_1}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutH    do show aaa

case teardown
    log    Enter case teardown