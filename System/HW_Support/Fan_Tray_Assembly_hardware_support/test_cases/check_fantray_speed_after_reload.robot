*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_check_fantray_speed_after_reload
    [Documentation]    check fantray speed and system temp after reload
    [Tags]    @author= Sean Wang    @globalid=2272509    @tcid=AXOS_E72_PARENT-TC-506          @feature=HW Support    @subfeature=Fan Tray Assembly hardware support
    [Setup]    case setup
    log    show info
    ${inp_str}    release_cmd_adapter    eutA    ${show_info_fan_speed}
    Run Keyword If    '${EMPTY}'!='${inp_str}'    check fan speed low     80
    check sensors fan low    eutA    80
    reload system    eutA
    ${r}    Run Keyword If    '${EMPTY}'!='${inp_str}'    wait_until_keyword_succeeds    10 min   30    check fan speed low     80
    ${r}    wait_until_keyword_succeeds    10 min   30    check sensors fan low    eutA    80        
    log    ${r}
    Run Keyword If    '${EMPTY}'!='${inp_str}'    check fan speed low     80
    check sensors fan low    eutA    80
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    set eut version
    Configure    eutA    do show info

case teardown
    log    Enter 2143103 teardown
    Configure    eutA    do show info
    cli    eutA    copy running-config startup-config


check fan speed low
    [Arguments]    ${max_speed}
    ${result}    cli    eutA    show info
    ${speed}    ${group1}    should Match Regexp    ${result}    fan-speed\\s+(\\d+)\\s+%
    should be true    ${group1}<${max_speed}

