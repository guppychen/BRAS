*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
provision_4_tacacs_server_on_card
    [Documentation]    provision_4_tacacs_server_on_card
    [Tags]    @author= Sean Wang    @globalid=2533147    @tcid=AXOS_E72_PARENT-TC-4432
    [Setup]    case setup
    log    show info
    Configure    eutA    aaa tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    Configure    eutA    aaa tacacs server ${tacacs_ip_2} secret ${tacacs_ps}
    Configure    eutA    aaa tacacs server ${tacacs_ip_3} secret ${tacacs_ps}
    Configure    eutA    aaa tacacs server ${tacacs_ip_4} secret ${tacacs_ps}
    check_tacacs_server_number    ${tacacs_ip_1}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown
    Configure    eutA    no aaa tacacs server ${tacacs_ip_2}
    Configure    eutA    no aaa tacacs server ${tacacs_ip_3}
    Configure    eutA    no aaa tacacs server ${tacacs_ip_4}

check_tacacs_server_number
    [Arguments]    ${pa1}
    ${result}    cli    eutA    show run aaa tacacs server
    should_contain_x_times    ${result}    tacacs server 10.245   4
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa tacacs server (\\d+.\\d+.\\d+.\\d+)
    should contain    ${result}    ${group1}
    [Return]   ${group1}