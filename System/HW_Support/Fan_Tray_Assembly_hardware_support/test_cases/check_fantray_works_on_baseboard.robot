*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_check_fantray_works_on_baseboard
    [Documentation]    Check fantry can works fine
    [Tags]    @author= Sean Wang    @globalid=2272212    @tcid=AXOS_E72_PARENT-TC-502        @feature=HW Support    @subfeature=Fan Tray Assembly hardware support
    [Setup]    case setup
    log    show inventory
    check fan works on baseboard    80
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show inventory

case teardown
    log    Enter 2143103 teardown
    Configure    eutA    do show inventory

check fan works on baseboard
    [Arguments]    ${max_speed}
    ${result}    cli    eutA    show inventory
#    should_contain    ${result}    NGPON2-4
    should_contain    ${result}    E7 SFF Assembly
    ${calix count}    get count    ${result}    Calix
    # add by llin 20180424 EXA-31289
#    should be true    ${calix count}==6 or ${calix count}==3
    ${fantray}    ${group1}    should Match Regexp    ${result}    E7 Fan Tray Assembly FTA(\\d+)
    ${sn}    ${group11}    should Match Regexp    ${result}    serial-number\\s+(\\d+)
    should Match Regexp    ${result}    manufacturer\\s+Calix
    # add by llin 20180424 EXA-31289

    should be true    ${group1}<${max_speed}