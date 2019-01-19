*** Settings ***
Documentation     SIP Service modification of direct-connect
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_modification_of_direct_connect
    [Documentation]    1. Edit SIP service with direct-connect: interface pots 211/p1 sip-service Daniel direct-connect 0, direct-connect 0, show running-config interface pots |details, Direct Connect: 0, dcli potsmgr show sip_service
    ...    2. Edit SIP service without direct-connect: no direct-connect, no direct-connect, show running-config interface pots |details, Direct Connect: , dcli potsmgr show sip_service
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3431    @globalid=2473188    @priority=P1    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP service with direct-connect: interface pots 211/p1 sip-service Daniel direct-connect 0, direct-connect 0, show running-config interface pots |details, Direct Connect: 0, dcli potsmgr show sip_service
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1
    prov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    direct-connect=${direct_connect2} 
    Wait Until Keyword Succeeds    2min    10sec    check_running_config_interface    eutA    pots    ${pots_id1}    | details    direct-connect=${direct_connect2}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    Direct Connect    ${direct_connect2}
    
    log    STEP:2. Edit SIP service without direct-connect: no direct-connect, no direct-connect, show running-config interface pots |details, Direct Connect: , dcli potsmgr show sip_service
    dprov_interface    eutA    pots    ${pots_id1}    ${EMPTY}    ${EMPTY}    sip-service    ${ua_id}    direct-connect=${EMPTY}         
    ${res}    cli    eutA    show running-config interface pots ${pots_id1} | details 
    ${res1}    Get Lines Containing String    ${res}    direct-connect        
    should not be equal    ${res1}    direct-connect
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_service    ontA    1    Direct Connect    ${EMPTY} 


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  