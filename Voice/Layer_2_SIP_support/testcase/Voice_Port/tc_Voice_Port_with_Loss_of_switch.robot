*** Settings ***
Documentation     Voice Port with Loss of switch
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_with_Loss_of_switch
    [Documentation]    1. interface pots 211/p1 loss-of-switch loss-of-switch show running-config interface pots 211/p1 | detail
    ...    2. Loss-of-switch enabled dcli potsmgr show pots
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3475    @globalid=2473232    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. interface pots auto838/p1, loss-of-switch loss-of-switch, show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    loss-of-switch=${EMPTY}   
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    loss-of-switch=${EMPTY}
    
    log    STEP:2. Loss-of-switch enabled dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Loss-of-switch    enabled
    
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
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    loss-of-switch=${EMPTY}