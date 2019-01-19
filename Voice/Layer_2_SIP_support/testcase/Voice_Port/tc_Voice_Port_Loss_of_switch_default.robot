*** Settings ***
Documentation     Voice Port Loss of switch default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_Loss_of_switch_default
    [Documentation]    1. interface pots 211/p1 no loss-of-switch show running-config interface pots 211/p1 | detail
    ...    2. Loss-of-switch disabled dcli potsmgr show pots
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3474    @globalid=2473231    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. interface pots 211/p1 no loss-of-switch show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    no=loss-of-switch
    
    log    STEP:2. Loss-of-switch disabled dcli potsmgr show pots
    Wait Until Keyword Succeeds    2min    10sec    check_ont_pots    ontA    ${ua_id}    Loss-of-switch    disabled


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log     case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  