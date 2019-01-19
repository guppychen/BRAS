*** Settings ***
Documentation     SIP Profile with RTP DSCP 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_RTP_DSCP
    [Documentation]    1. Enter SIP-Profile rtp-dscp = 0 and 63, rtp-dscp = selection, Enter SIP-Profile rtp-dscp > 63, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3377    @globalid=2473134    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile rtp-dscp = 0 and 63, rtp-dscp = selection 
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-dscp=${rtp_dscp_2}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-dscp=${rtp_dscp_2}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_dscp_2}    RTP DSCP
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    rtp-dscp=${rtp_dscp_3}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-dscp=${rtp_dscp_3}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_dscp_3}    RTP DSCP
    
    log    STEP:1. Enter SIP-Profile rtp-dscp > 63, command rejected
    cli    eutA    configure
    ${res}    cli    eutA    sip-profile ${sip_profile} rtp-dscp ${rtp_dscp_4} 
    should contain    ${res}    unknown element
    cli    eutA    end   


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-dscp

  