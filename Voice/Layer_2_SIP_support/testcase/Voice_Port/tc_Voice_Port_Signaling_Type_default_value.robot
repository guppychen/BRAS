*** Settings ***
Documentation     Voice Port Signaling Type default value
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_Signaling_Type_default_value
    [Documentation]    1. interface pots 211/p1, signaling-type loopstart, show running-config interface pots 211/p1 | detail
    ...    2. Signal-Type loopstart, dcli potsmgr show pots
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3454    @globalid=2473211    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. interface pots 211/p1, signaling-type loopstart, show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    signaling-type=${signaling_type}
  
    log    STEP:2. Signal-Type loopstart, dcli potsmgr show pots
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
  