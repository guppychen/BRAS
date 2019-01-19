*** Settings ***
Documentation     Voice Port modification of description
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Voice_Port_modification_of_description
    [Documentation]    1. interface pots 211/p1 description "Another 255 char value", description "Another 255 char value", show running-config interface pots 211/p1 | detail
    ...    2. interface pots 211/p1 description "256 char value", command rejected, dcli potsmgr show pots
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3452    @globalid=2473209    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. interface pots 211/p1 description "Another 255 char value", description "Another 255 char value", show running-config interface pots 211/p1 | detail
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    description=${description_1}
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}
    ...    | details    description=${description_1}
    
    log    STEP:2. interface pots 211/p1 description "256 char value", command rejected, dcli potsmgr show pots
    cli    eutA    configure
    ${res}    cli    eutA    interface pots ${pots_id1} description ${description_2}
    should contain    ${res}    "${description_2}" has a bad length/size        
    


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
    dprov_interface    eutA    pots    ${pots_id1}    description=${EMPTY}