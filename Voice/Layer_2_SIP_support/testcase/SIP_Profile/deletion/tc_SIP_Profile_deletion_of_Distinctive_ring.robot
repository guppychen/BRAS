*** Settings ***
Documentation     SIP Profile deletion of Distinctive ring
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Distinctive_ring
    [Documentation]    1. no distinctive-ring-prefix, distinct-ring-prefix = Bellcore-dr, Distinctive Ring Prefix = Bellcore-dr
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3363    @globalid=2473120    @priority=P3    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no distinctive-ring-prefix, distinct-ring-prefix = Bellcore-dr, Distinctive Ring Prefix = Bellcore-dr
    dprov_sip_profile    eutA    ${sip_profile}    =distinctive-ring-prefix
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    distinctive-ring-prefix=${distinct_ring_prefix}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${distinct_ring_prefix_ont}    Distinctive Ring Prefix    

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  