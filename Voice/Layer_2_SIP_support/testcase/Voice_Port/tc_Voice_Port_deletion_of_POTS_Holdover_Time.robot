*** Settings ***
Documentation     Voice Port deletion of POTS Holdover Time
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_deletion_of_POTS_Holdover_Time
    [Documentation]    1. no interface pots 211/p1 port-holdover-timer direct-connect-timer 180 show running-config interface pots 211/p1 | detail
    ...    2. Holdover 180 dcli potsmgr show pots
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3473    @globalid=2473230    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no interface pots 211/p1 pots-holdover-timer direct-connect-timer 180 show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    pots-holdover-timer=${EMPTY}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    pots-holdover-timer=${pots_holdover_timer}
    
    log    STEP:2. Holdover 180 dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    HoldOver    ${pots_holdover_timer}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  