*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
check_tacacs_server_login_prompt_message
    [Documentation]    check_tacacs_server_login_prompt_message
    [Tags]    @author= Sean Wang    @globalid=2533146    @tcid=AXOS_E72_PARENT-TC-4431
    [Setup]    case setup
    log    show info
    Configure    eutC    aaa tacacs server ${tacacs_ip_domain} secret ${tacacs_ps} timeout 30
    check_tacacs_server_login    ${tacacs_ip_domain}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutC    do show aaa

case teardown
    log    Enter case teardown
    Configure    eutC    no aaa tacacs server ${tacacs_ip_domain}

check_tacacs_server_login
    [Arguments]    ${pa1}
    ${result}    cli    eutC    show run aaa tacacs server ${tacacs_ip_domain} timeout
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa tacacs server (\\w+\\d+-\\d+.\\w+.\\w+)
    ${tacacs}    ${group2}    should Match Regexp    ${result}    timeout (\\d+)
    should contain    ${group1}    ${pa1}
    should contain    ${group2}    30
    [Return]   ${group1}