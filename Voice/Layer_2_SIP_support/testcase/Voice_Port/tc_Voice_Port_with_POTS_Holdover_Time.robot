*** Settings ***
Documentation     Voice Port with POTS Holdover Time
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_with_POTS_Holdover_Time
    [Documentation]    1. Selection is 0 and 60 and 65535: interface pots 211/p1 pots-holdover-timer selection, direct-connect-timer selection, show running-config interface pots 211/p1 | detail
    ...    2. Holdover selection, dcli potsmgr show pots
    ...    3. Selection is 59 and 65536: interface pots 211/p1 pots-holdover-timer, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3471    @globalid=2473228    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Selection is 0 and 60 and 65535: interface pots 211/p1 pots-holdover-timer selection, direct-connect-timer selection, show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    pots-holdover-timer=${pots_holdover_timer0}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    pots-holdover-timer=${pots_holdover_timer0}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    HoldOver    ${pots_holdover_timer0}
    
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    pots-holdover-timer=${pots_holdover_timer60}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    pots-holdover-timer=${pots_holdover_timer60}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    HoldOver    ${pots_holdover_timer60}    
  
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    pots-holdover-timer=${pots_holdover_timer43200}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    pots-holdover-timer=${pots_holdover_timer43200}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    HoldOver    ${pots_holdover_timer43200}
    # the range of pots-holdover-timer is 60 ~ 43200 and 0
    
    log    STEP:2. Selection is 59 and 65536: interface pots 211/p1 pots-holdover-timer, selection command rejected
    cli    eutA    configure
    ${res1}    cli    eutA    interface pots ${pots_id1} pots-holdover-timer ${pots_holdover_timer59}
    should contain    ${res1}    "${pots_holdover_timer59}" is out of range
    cli    eutA    end 
    
    cli    eutA    configure
    ${res2}    cli    eutA    interface pots ${pots_id1} pots-holdover-timer ${pots_holdover_timer65536}
    should contain    ${res2}    "${pots_holdover_timer65536}" is not a valid value
    cli    eutA    end


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    pots-holdover-timer=${EMPTY}