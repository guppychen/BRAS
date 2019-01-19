*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
check_more_cli_commands_running_with_tacacs_server_user
    [Documentation]    check_more_cli_commands_running_with_tacacs_server_user
    [Tags]    @author= Sean Wang    @globalid=2533189    @tcid=AXOS_E72_PARENT-TC-4474
    [Setup]    case setup
    log    show run aaa
    Configure    eutC    aaa tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    ${result}    cli    eutC    show run aaa tacacs
    should contain    ${result}    ${tacacs_ip_1}
    ${result}    cli    eutC    show aaa tacacs
    should contain    ${result}    ${tacacs_ip_1}
    ${result}    cli    eutC    show aaa
    should contain    ${result}    ${tacacs_ip_1}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutC    do show aaa

case teardown
    log    Enter case teardown