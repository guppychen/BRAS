*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_tacacs_server_create_with_domain_name
    [Documentation]    aaa_tacacs_server_create_with_domain_name
    [Tags]    @author= Sean Wang    @globalid=2533154    @tcid=AXOS_E72_PARENT-TC-4439
    [Setup]    case setup
    log    show info
    Configure    eutA    aaa tacacs server ${tacacs_ip_domain} secret ${tacacs_ps}
    check tacacs provisioned    ${tacacs_ip_domain}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown
    Configure    eutA    no aaa tacacs server ${tacacs_ip_domain}

check tacacs provisioned
    [Arguments]    ${pa1}
    ${result}    cli    eutA    show run aaa tacacs
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa tacacs server (\\w+\\d+-\\d+.\\w+.\\w+)
    should contain    ${group1}    ${pa1}
    [Return]   ${group1}