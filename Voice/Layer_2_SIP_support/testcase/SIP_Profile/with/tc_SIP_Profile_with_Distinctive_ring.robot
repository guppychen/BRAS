*** Settings ***
Documentation     SIP Profile with Distinctive ring
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_Distinctive_ring
    [Documentation]    1. Enter SIP-Profile distinct-ring = abcdefghijklmnopqrstuvwxyz1234-6, distinct-ring-prefix = abcdefghijklmnopqrstuvwxyz1234-6, Distinctive Ring Prefix = abcdefghijklmnopqrstuvwxyz1234-6
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3361    @globalid=2473118    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile distinct-ring = abcdefghijklmnopqrstuvwxyz1234-6, distinct-ring-prefix = abcdefghijklmnopqrstuvwxyz1234-6, Distinctive Ring Prefix = abcdefghijklmnopqrstuvwxyz1234-6
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    distinctive-ring-prefix=${distinct_ring_prefix_modi}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    distinctive-ring-prefix=${distinct_ring_prefix_modi}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${distinct_ring_prefix_modi}    Distinctive Ring Prefix


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =country-code
  