*** Settings ***
Documentation     Voice Port deletion of description
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_deletion_of_description
    [Documentation]    1. no interface pots 211/p1 description, description "", show running-config interface pots 211/p1 | detail
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3453    @globalid=2473210    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no interface pots 211/p1 description, description "", show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    dprov_interface    eutA    pots    ${pots_id1}    description=${EMPTY}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    description=""


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
  