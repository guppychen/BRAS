*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_authentication_order_local_only
    [Documentation]    aaa_authentication_order_local_only
    [Tags]    @author= Sean Wang    @globalid=2533171    @tcid=AXOS_E72_PARENT-TC-4456
    [Setup]    case setup
    log    show aaa
    Configure    eutA    aaa authentication-order local-only
    check tacacs auth    local-only
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown

check tacacs auth
    [Arguments]    ${tacacs_auth}
    ${result}    cli    eutA    show run aaa authentication-order
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa authentication-order (\\w+-\\w+)
    should contain    ${group1}    ${tacacs_auth}
    [Return]   ${group1}