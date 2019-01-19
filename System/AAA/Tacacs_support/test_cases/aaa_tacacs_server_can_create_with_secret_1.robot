*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_tacacs_server_create_with_secret_1
    [Documentation]    aaa_tacacs_server_create_with_secret_1
    [Tags]    @author= Sean Wang    @globalid=2533160    @tcid=AXOS_E72_PARENT-TC-4445
    [Setup]    case setup
    log    show info
    Configure    eutA    aaa tacacs server ${tacacs_ip_domain} secret 1
    check tacacs secret    ${tacacs_ip_domain}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown
    Configure    eutA    no aaa tacacs server ${tacacs_ip_domain}

check tacacs secret
    [Arguments]    ${pa1}
    ${result}    cli    eutA    show run aaa tacacs server ${tacacs_ip_domain} secret
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa tacacs server (\\w+\\d+-\\d+.\\w+.\\w+)
    ${tacacs}    ${group2}    should Match Regexp    ${result}    (secret)\\s
    should contain    ${group1}    ${pa1}
    [Return]   ${group1}