*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_accounting_tacacs_server_ip
    [Documentation]    aaa_accounting_tacacs_server_ip
    [Tags]    @author= Sean Wang    @globalid=2533166    @tcid=AXOS_E72_PARENT-TC-4451
    [Setup]    case setup
    log    show aaa
    Configure    eutA    aaa accounting tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    check tacacs accounting ip    ${tacacs_ip_1}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown

check tacacs accounting ip
    [Arguments]    ${tacacs_ip_1}
    ${result}    cli    eutA    show run aaa accounting
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa accounting tacacs server (\\d+.\\d+.\\d+.\\d+)
    should contain    ${group1}    ${tacacs_ip_1}
    [Return]   ${group1}