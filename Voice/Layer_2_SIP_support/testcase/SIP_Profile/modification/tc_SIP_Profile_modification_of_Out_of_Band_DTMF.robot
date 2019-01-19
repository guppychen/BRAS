*** Settings ***
Documentation     SIP Profile with Out of Band DTMF
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_modification_of_Out_of_Band_DTMF
    [Documentation]    1. Edit SIP-Profile out-of-band-dtmf = none and rfc2833 and info, out-of-band-dtmf = selection, Out-of-band DTMF = selection
    ...    2. Edit SIP-Profile with out-of-band-dtmf = abc, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3370    @globalid=2473127    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Edit SIP-Profile out-of-band-dtmf = none and rfc2833 and info, out-of-band-dtmf = selection, Out-of-band DTMF = selection
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    out-of-band-dtmf=${out_of_band_dtmf}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    out-of-band-dtmf=${out_of_band_dtmf}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${out_of_band_dtmf}    Out-of-band DTMF
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    out-of-band-dtmf=${out_of_band_dtmf1}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    out-of-band-dtmf=${out_of_band_dtmf1}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${out_of_band_dtmf1}    Out-of-band DTMF
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    out-of-band-dtmf=${out_of_band_dtmf2}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    out-of-band-dtmf=${out_of_band_dtmf2}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${out_of_band_dtmf2}    Out-of-band DTMF
    
    log    STEP:2. Edit SIP-Profile with out-of-band-dtmf = abc, command rejected
    cli    eutA    configure
    ${res}    cli    eutA    sip-profile ${sip_profile} out-of-band-dtmf ${out_of_band_dtmf3}
    should contain    ${res}    unknown element
    cli    eutA    end


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup
    dprov_sip_profile    eutA    ${sip_profile}    =out-of-band-dtmf

case teardown
    [Documentation]
    [Arguments]
    log    case teardown
    dprov_sip_profile    eutA    ${sip_profile}    =out-of-band-dtmf

  