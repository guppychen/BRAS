*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_check_fantray_speed
    [Documentation]    check fantray manufacturer and version
    [Tags]    @author= Sean Wang    @globalid=2272303    @tcid=AXOS_E72_PARENT-TC-505     @feature=HW Support    @subfeature=Fan Tray Assembly hardware support
    [Setup]    case setup
    log    show info
    check fan version
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show inventory

case teardown
    log    Enter 2143103 teardown
    Configure    eutA    do show inventory

check fan version
    ${result}    cli    eutA    show inventory fans
    ${fantray}    ${group1}    should Match Regexp    ${result}    hw-revision\\s+(\\d+)
    ${sn}    ${group11}    should Match Regexp    ${result}    manufacturer\\s+(Calix)
