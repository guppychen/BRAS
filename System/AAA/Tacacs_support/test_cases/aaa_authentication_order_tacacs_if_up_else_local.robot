*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_authentication_order_tacacs_if_up_else_local
    [Documentation]    aaa_authentication_order_tacacs_if_up_else_local
    [Tags]    @author= Sean Wang    @globalid=2533172    @tcid=AXOS_E72_PARENT-TC-4457
    [Setup]    case setup
    log    show aaa
    Configure    eutA    aaa authentication-order tacacs-if-up-else-local
    check tacacs auth    tacacs-if-up-else-local
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown
    Configure    eutA    aaa authentication-order tacacs-then-local

check tacacs auth
    [Arguments]    ${tacacs_auth}
    ${result}    cli    eutA    show run aaa authentication-order
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa authentication-order (\\w+-\\w+-\\w+-\\w+-\\w+)
    should contain    ${group1}    ${tacacs_auth}
    [Return]   ${group1}