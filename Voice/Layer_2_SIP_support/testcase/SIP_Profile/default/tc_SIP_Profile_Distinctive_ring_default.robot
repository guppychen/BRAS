*** Settings ***
Documentation     SIP Profile Distinctive ring default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Distinctive_ring_default
    [Documentation]    1. Enter SIP-Profile without distinct-ring-prefix, distinct-ring-prefix = Bellcore-dr, Distinctive Ring Prefix = Bellcore-dr
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3360    @globalid=2473117    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without distinctive-ring-prefix, distinctive-ring-prefix = Bellcore-dr, Distinctive Ring Prefix = Bellcore-dr
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    distinctive-ring-prefix=${distinct_ring_prefix}
    Wait Until Keyword Succeeds    2min    10sec    check_ont_sip_profile    ontA    ${distinct_ring_prefix_ont}    Distinctive Ring Prefix    
   

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  