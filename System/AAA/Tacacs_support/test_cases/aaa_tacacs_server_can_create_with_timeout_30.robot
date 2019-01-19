*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_tacacs_server_create_with_timeout_30
    [Documentation]    aaa_tacacs_server_create_with_timeout_30
    [Tags]    @author= Sean Wang    @globalid=2533163    @tcid=AXOS_E72_PARENT-TC-4448
    [Setup]    case setup
    log    show info
    Configure    eutA    aaa tacacs server ${tacacs_ip_domain} secret ${tacacs_ps} timeout 30
    check tacacs timeout    ${tacacs_ip_domain}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown
    Configure    eutA    no aaa tacacs server ${tacacs_ip_domain}

check tacacs timeout
    [Arguments]    ${pa1}
    ${result}    cli    eutA    show run aaa tacacs server ${tacacs_ip_domain} timeout
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa tacacs server (\\w+\\d+-\\d+.\\w+.\\w+)
    ${tacacs}    ${group2}    should Match Regexp    ${result}    timeout (\\d+)
    should contain    ${group1}    ${pa1}
    should contain    ${group2}    30
    [Return]   ${group1}