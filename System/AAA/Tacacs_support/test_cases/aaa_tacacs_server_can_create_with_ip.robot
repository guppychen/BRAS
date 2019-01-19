*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_tacacs_server_create_with_ip
    [Documentation]    aaa_tacacs_server_create_with_ip
    [Tags]    @author= Sean Wang    @globalid=2533153    @tcid=AXOS_E72_PARENT-TC-4438
    [Setup]    case setup
    log    show info
    Configure    eutA    aaa tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    check tacacs provisioned    ${tacacs_ip_1}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown

check tacacs provisioned
    [Arguments]    ${pa1}
    ${result}    cli    eutA    show run aaa tacacs
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa tacacs server (\\d+.\\d+.\\d+.\\d+)
    # ${sn}    ${group11}    should Match Regexp    ${result}    serial-number\\s+(\\d+) 
    should contain    ${group1}    ${pa1}
    [Return]   ${group1}