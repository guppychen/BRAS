*** Settings ***
Documentation     Voice Port with System RX Loss plan ANSI
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_with_System_RX_Loss_plan_ANSI
    [Documentation]    1. RX loss plan with ANSI: interface pots 211/p1 loss-plan-RX ansi, loss-plan-RX ansi, show running-config interface pots 211/p1 | detail
    ...    2. RX-Gain -9.00, dcli potsmgr show pots
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3467    @globalid=2473224    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. RX loss plan with ANSI: interface pots 211/p1 loss-plan-RX ansi, loss-plan-RX ansi, show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    loss-plan-rx=${gain_type_a}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    loss-plan-rx=${gain_type_a}
    
    log    STEP:2. RX-Gain -9.00, dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Rx-Gain    ${rx_gain_ansi}
    


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
    dprov_interface    eutA    pots    ${pots_id1}    loss-plan-rx=${EMPTY}