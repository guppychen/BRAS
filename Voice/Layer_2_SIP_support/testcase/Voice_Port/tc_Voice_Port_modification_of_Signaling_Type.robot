*** Settings ***
Documentation     Voice Port modification of Signaling Type 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_modification_of_Signaling_Type
    [Documentation]    1. Selection is loopstart or groundstart. Interface pots 211/p1 signaling-type selection, signaling-type selection, show running-config interface pots 211/p1 | detail
    ...    2. Signal-Type selection, dcli potsmgr show pots
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3456    @globalid=2473213    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Selection is loopstart or groundstart. Interface pots 211/p1 signaling-type selection, signaling-type selection, show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    signaling-type=${signaling_type_ground}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    signaling-type=${signaling_type_ground}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Signal-Type    ${signaling_type_ground}
    
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    signaling-type=${signaling_type}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    signaling-type=${signaling_type}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Signal-Type    ${signaling_type}



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
    dprov_interface    eutA    pots    ${pots_id1}    signaling-type=${EMPTY}