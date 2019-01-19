*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
show_run_aaa_tacacs
    [Documentation]    show_run_aaa_tacacs
    [Tags]    @author= Sean Wang    @globalid=2533175    @tcid=AXOS_E72_PARENT-TC-4460
    [Setup]    case setup
    log    show run aaa
    Configure    eutA    aaa tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    ${result}    cli    eutA    show run aaa tacacs
    should contain    ${result}    ${tacacs_ip_1}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown
    # Configure    eutA    no aaa tacacs server ${tacacs_ip_1}