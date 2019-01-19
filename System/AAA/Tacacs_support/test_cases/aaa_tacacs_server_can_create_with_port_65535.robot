*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_tacacs_server_create_with_port_65535
    [Documentation]    aaa_tacacs_server_create_with_port_65535
    [Tags]    @author= Sean Wang    @globalid=2533156    @tcid=AXOS_E72_PARENT-TC-4441
    [Setup]    case setup
    log    show info
    Configure    eutA    aaa tacacs server ${tacacs_ip_domain} secret ${tacacs_ps} port 65535
    check tacacs port    ${tacacs_ip_domain}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown
    Configure    eutA    no aaa tacacs server ${tacacs_ip_domain}

check tacacs port
    [Arguments]    ${pa1}
    ${result}    cli    eutA    show run aaa tacacs
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa tacacs server (\\w+\\d+-\\d+.\\w+.\\w+)
    ${tacacs}    ${group2}    should Match Regexp    ${result}    aaa tacacs server \\w+\\d+-\\d+.\\w+.\\w+\\s+port\\s+(\\d+) 
    should contain    ${group1}    ${pa1}
    should contain    ${group2}    65535
    [Return]   ${group1}