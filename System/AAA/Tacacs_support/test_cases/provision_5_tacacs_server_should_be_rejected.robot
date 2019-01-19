*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
provision_5_tacas_server_should_be_rejected
    [Documentation]    provision_5_tacas_server_should_be_rejected
    [Tags]    @author= Sean Wang    @globalid=2533148    @tcid=AXOS_E72_PARENT-TC-4433
    [Setup]    case setup
    log    show info
    Configure    eutA    aaa tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    Configure    eutA    aaa tacacs server ${tacacs_ip_2} secret ${tacacs_ps}
    Configure    eutA    aaa tacacs server ${tacacs_ip_3} secret ${tacacs_ps}
    Configure    eutA    aaa tacacs server ${tacacs_ip_4} secret ${tacacs_ps}
    cli    eutA    config
    ${result}    cli    eutA    aaa tacacs server ${tacacs_ip_5} secret ${tacacs_ps}
    cli    eutA    end
    should contain    ${result}    at most 4 must be configured
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