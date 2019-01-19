*** Settings ***
Documentation     SIP Service removal of message-waiting-indicator
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_removal_of_message_waiting_indicator
    [Documentation]    1. Edit SIP service with no Call Waiting enabled: no sip-service Daniel call-waiting
    ...    no call-waiting, show running-config interface pots |details
    ...    2. Call Waiting disable, dcli potsmgr show sip_service
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3440    @globalid=2473197    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP service with no Call Waiting enabled: no sip-service Daniel call-waiting, no call-waiting, show running-config interface pots |details
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    Wait Until Keyword Succeeds    5min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    msg-waiting-indicator=${EMPTY}
    
    log    STEP:2. Call Waiting disable, dcli potsmgr show sip_service
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_service    ontA    1    Message Waiting    enabled


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  