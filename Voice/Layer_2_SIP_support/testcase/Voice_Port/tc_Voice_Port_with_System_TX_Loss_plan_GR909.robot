*** Settings ***
Documentation     Voice Port with System TX Loss plan GR909
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_with_System_TX_Loss_plan_GR909
    [Documentation]    1. TX loss plan with GR909: interface pots 211/p1 loss-plan-tx gr909, loss-plan-tx gr909, show running-config interface pots 211/p1 | detail
    ...    2. manual-tx-gain no present, show running-config interface pots 211/p1 | detail
    ...    3. Tx-Gain -2.00, dcli potsmgr show pots
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3459    @globalid=2473216    @eut=GPON-8r2    @user_interface=CLI    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. TX loss plan with GR909: interface pots 211/p1 loss-plan-tx gr909, loss-plan-tx gr909, show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    loss-plan-tx=${gain_type_g}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    loss-plan-tx=${gain_type_g}

    log    STEP:2. manual-tx-gain no present, show running-config interface pots 211/p1 | detail
    ${res}    cli    eutA    show running-config interface pots ${pots_id1} | detail
    should not contain    ${res}    manual-tx-gain

    log    STEP:3. Tx-Gain -2.00, dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Tx-Gain    ${tx_gain_gr909}


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
    dprov_interface    eutA    pots    ${pots_id1}    loss-plan-tx=${EMPTY}