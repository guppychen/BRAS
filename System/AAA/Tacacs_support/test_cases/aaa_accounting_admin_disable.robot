*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_accounting_admin_disable
    [Documentation]    aaa_accounting_admin_disable
    [Tags]    @author= Sean Wang    @globalid=2533165    @tcid=AXOS_E72_PARENT-TC-4450
    [Setup]    case setup
    log    show info
    Configure    eutA    aaa accounting admin-state disable
    check tacacs accounting    disable
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown

check tacacs accounting
    [Arguments]    ${en}
    ${result}    cli    eutA    show run aaa accounting
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa accounting admin-state (\\w+)
    should contain    ${group1}    ${en}
    [Return]   ${group1}