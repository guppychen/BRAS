*** Settings ***
Documentation     Voice Port with System TX Loss plan manual
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_with_System_TX_Loss_plan_manual
    [Documentation]    1. TX loss plan with MANUAL default value: interface pots 211/p1 loss-plan-tx manual, loss-plan-tx manual manual-tx-gain 0.0 N, show running-config interface pots 211/p1 | detail
    ...    2. Tx-Gain 0.00, dcli potsmgr show pots
    ...    3. TX loss plan with MANUAL min value: interface pots 211/p1 loss-plan-tx manual manual-tx-gain -12, loss-plan-tx manual manual-tx-gain -12.0, show running-config interface pots 211/p1 | detail
    ...    4. Tx-Gain -12.0, dcli potsmgr show pots
    ...    5. TX loss plan with MANUAL max value (: interface pots 211/p1 loss-plan-tx manual manual-tx-gain 6, loss-plan-tx manual manual-tx-gain 6.0, show running-config interface pots 211/p1 | detail
    ...    6. Tx-Gain 6.00, dcli potsmgr show pots
    ...    7. Interface pots 211/p1 loss-plan-tx manual manual-tx-gain -12.2, command rejected
    ...    8. Interface pots 211/p1 loss-plan-tx manual manual-tx-gain 6.2, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3462    @globalid=2473219    @eut=GPON-8r2    @user_interface=CLI    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. TX loss plan with MANUAL default value: interface pots 211/p1 loss-plan-tx manual, loss-plan-tx manual manual-tx-gain 0.0 N, show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    loss-plan-tx=${loss_plan_tx_man}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    manual-tx-gain=${manual_rx_gain}

    log    STEP:2. Tx-Gain 0.00, dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Tx-Gain    ${tx_gain_man}

    log    STEP:3. TX loss plan with MANUAL min value: interface pots 211/p1 loss-plan-tx manual manual-tx-gain -12, loss-plan-tx manual manual-tx-gain -12.0, show running-config interface pots 211/p1 | detail
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    loss-plan-tx=${loss_plan_tx_man}    manual-TX-gain=${manual_TX_gain12}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    manual-tx-gain=${manual_TX_gain120}

    log    STEP:4. Tx-Gain -12.0, dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Tx-Gain    ${manual_TX_gain120}


    log    STEP:5. TX loss plan with MANUAL max value (: interface pots 211/p1 loss-plan-tx manual manual-tx-gain 6, loss-plan-tx manual manual-tx-gain 6.0, show running-config interface pots 211/p1 | detail
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    loss-plan-tx=${loss_plan_tx_man}    manual-TX-gain=${manual_TX_gain6}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    manual-tx-gain=${manual_TX_gain60}

    log    STEP:6. Tx-Gain 6.00, dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Tx-Gain    ${manual_TX_gain_600}
    
    log    STEP:7. Interface pots 211/p1 loss-plan-tx manual manual-tx-gain -12.2, command rejected
    cli    eutA    conf
    ${res1}    cli    eutA    interface pots ${pots_id1} loss-plan-tx manual manual-tx-gain ${manual_TX_gain122}  
    should contain    ${res1}    "${manual_TX_gain122}" is out of range


    log    STEP:8. Interface pots 211/p1 loss-plan-tx manual manual-tx-gain 6.2, command rejected
    ${res1}    cli    eutA    interface pots ${pots_id1} loss-plan-tx manual manual-tx-gain ${manual_TX_gain622}  
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
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    loss-plan-tx    ${loss_plan_tx_man}    manual-TX-gain=${EMPTY}
    dprov_interface    eutA    pots    ${pots_id1}    loss-plan-tx=${EMPTY}