*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_check_fantray_speed
    [Documentation]    Check Fantray speed
    [Tags]    @author= Sean Wang    @globalid=2272301    @tcid=AXOS_E72_PARENT-TC-503       @feature=HW Support    @subfeature=Fan Tray Assembly hardware support
    [Setup]    case setup
    log    show info
    ${inp_str}    release_cmd_adapter    eutA    ${show_info_fan_speed}
    Run Keyword If    '${EMPTY}'!='${inp_str}'    check fan speed low     80
    check sensors fan low    eutA    80
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    log    set eut version and release
    set_eut_version
    Configure    eutA    do show info

case teardown
    log    Enter 2143103 teardown
    Configure    eutA    do show info

check fan speed low
    [Arguments]    ${max_speed}
    ${result}    cli    eutA    show info
    ${speed}    ${group1}    should Match Regexp    ${result}    fan-speed\\s+(\\d+)\\s+%
    should be true    ${group1}<${max_speed}
