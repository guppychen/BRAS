*** Settings ***
Documentation     Voice Port with System RX Loss plan ETSI
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_with_System_RX_Loss_plan_ETSI
    [Documentation]    1. RX loss plan with ETSI: interface pots 211/p1 loss-plan-RX etsi, loss-plan-RX etsi, show running-config interface pots 211/p1 | detail
    ...    2. manual-RX-gain no present, show running-config interface pots 211/p1 | detail
    ...    3. RX-Gain -11.00, dcli potsmgr show pots
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3468    @globalid=2473225    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. RX loss plan with ETSI: interface pots 211/p1 loss-plan-RX etsi, loss-plan-RX etsi, show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    loss-plan-rx=${gain_type_e}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    loss-plan-rx=${gain_type_e}
    
    log    STEP:2. manual-RX-gain no present, show running-config interface pots 211/p1 | detail
    ${res}    cli    eutA    show running-config interface pots ${pots_id1} | detail
    should not contain    ${res}    manual-rx-gain

    log    STEP:3. RX-Gain -11.00, dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Rx-Gain    ${rx_gain_etsi}



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