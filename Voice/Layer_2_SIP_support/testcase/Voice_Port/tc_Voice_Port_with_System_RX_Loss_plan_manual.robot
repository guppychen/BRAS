*** Settings ***
Documentation     Voice Port with System RX Loss plan manual
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_with_System_RX_Loss_plan_manual
    [Documentation]    1. RX loss plan with MANUAL default value: interface pots 211/p1 loss-plan-RX manual, loss-plan-RX manual manual-RX-gain 0.0 N, show running-config interface pots 211/p1 | detail
    ...    2. RX-Gain 0.00, dcli potsmgr show pots
    ...    3. RX loss plan with MANUAL min value (: interface pots 211/p1 loss-plan-RX manual manual-RX-gain -12, loss-plan-RX manual manual-RX-gain -12.0, show running-config interface pots 211/p1 | detail
    ...    4. RX-Gain -12.0, dcli potsmgr show pots
    ...    5. RX loss plan with MANUAL max value (: interface pots 211/p1 loss-plan-RX manual manual-RX-gain 6, loss-plan-RX manual manual-RX-gain 6.0, show running-config interface pots 211/p1 | detail
    ...    6. RX-Gain 6.00, dcli potsmgr show pots
    ...    7. Interface pots 211/p1 loss-plan-RX manual manual-RX-gain -12.2, command rejected
    ...    8. Interface pots 211/p1 loss-plan-RX manual manual-RX-gain 6.2, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3469    @globalid=2473226    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. RX loss plan with MANUAL default value: interface pots 211/p1 loss-plan-RX manual, loss-plan-RX manual manual-RX-gain 0.0 N, show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    loss-plan-rx=${loss_plan_rx_man}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    manual-rx-gain=${manual_rx_gain}

    log    STEP:2. RX-Gain 0.00, dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Rx-Gain    ${rx_gain_man}
    
    log    STEP:3. RX loss plan with MANUAL min value (: interface pots 211/p1 loss-plan-RX manual manual-RX-gain -12, loss-plan-RX manual manual-RX-gain -12.0, show running-config interface pots 211/p1 | detail
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    loss-plan-rx=${loss_plan_rx_man}    manual-RX-gain=${manual_RX_gain12}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    manual-rx-gain=${manual_RX_gain120}

    log    STEP:4. RX-Gain -12.0, dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Rx-Gain    ${manual_RX_gain120}

    log    STEP:5. RX loss plan with MANUAL max value (: interface pots 211/p1 loss-plan-RX manual manual-RX-gain 6, loss-plan-RX manual manual-RX-gain 6.0, show running-config interface pots 211/p1 | detail
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    loss-plan-rx=${loss_plan_rx_man}    manual-RX-gain=${manual_RX_gain6}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    manual-rx-gain=${manual_RX_gain60}


    log    STEP:6. RX-Gain 6.00, dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Rx-Gain    ${manual_RX_gain_600}

    log    STEP:7. Interface pots 211/p1 loss-plan-RX manual manual-RX-gain -12.2, command rejected
    cli    eutA    conf
    ${res1}    cli    eutA    interface pots ${pots_id1} loss-plan-rx manual manual-rx-gain ${manual_RX_gain122}  
    should contain    ${res1}    "${manual_RX_gain122}" is out of range    

    log    STEP:8. Interface pots 211/p1 loss-plan-RX manual manual-RX-gain 6.2, command rejected
    cli    eutA    conf
    ${res1}    cli    eutA    interface pots ${pots_id1} loss-plan-rx manual manual-rx-gain ${manual_RX_gain622}  
    should contain    ${res1}    "${manual_RX_gain622}" is out of range  


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
    ...    loss-plan-rx    ${loss_plan_rx_man}    manual-RX-gain=${EMPTY}
    dprov_interface    eutA    pots    ${pots_id1}    loss-plan-rx=${EMPTY}