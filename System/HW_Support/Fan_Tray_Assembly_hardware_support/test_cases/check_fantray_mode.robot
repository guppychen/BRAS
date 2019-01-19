*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_check_fantray_speed
    [Documentation]    check fantray mode and SN
    [Tags]    @author= Sean Wang    @globalid=2272302    @tcid=AXOS_E72_PARENT-TC-504     @feature=HW Support    @subfeature=Fan Tray Assembly hardware support
    [Setup]    case setup
    log    show info
    check fan mode     1
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show inventory

case teardown
    log    Enter 2143103 teardown
    Configure    eutA    do show inventory

check fan mode
    [Arguments]    ${mode}
    ${result}    cli    eutA    show inventory
    ${fantray}    ${group1}    should Match Regexp    ${result}    E7 Fan Tray Assembly FTA(\\d+)
    ${sn}    ${group11}    should Match Regexp    ${result}    serial-number\\s+(\\d+)
    should be true    ${group1}>${mode}
