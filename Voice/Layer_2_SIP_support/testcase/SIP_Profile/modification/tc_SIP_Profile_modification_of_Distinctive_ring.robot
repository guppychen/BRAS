*** Settings ***
Documentation     SIP Profile modification of Distinctive ring
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Distinctive_ring
    [Documentation]    1. Edit SIP-Profile Distinct-ring = ABCdefghijklmnopqrstuvwxyz1234-6, distinct-ring-prefix = ABCdefghijklmnopqrst, Distinctive Ring Prefix = ABCdefghijklmnopqrst
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3362    @globalid=2473119    @eut=GPON-8r2    @priority=P1    user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile Distinct-ring = ABCdefghijklmnopqrst, distinct-ring-prefix = ABCdefghijklmnopqrst, Distinctive Ring Prefix = ABCdefghijklmnopqrst
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    distinctive-ring-prefix=${distinct_ring_prefix_modi1}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    distinctive-ring-prefix=${distinct_ring_prefix_modi1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${distinct_ring_prefix_modi1}    Distinctive Ring Prefix


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =distinctive-ring-prefix
  