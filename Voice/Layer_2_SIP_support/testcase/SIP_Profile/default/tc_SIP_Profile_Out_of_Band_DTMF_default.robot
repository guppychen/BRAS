*** Settings ***
Documentation     SIP Profile Out of Band DTMF default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Out_of_Band_DTMF_default
    [Documentation]    1. Enter SIP-Profile without out-of-band-dtmf, out-of-band-dtmf = none, Out-of-band DTMF = none
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3368    @globalid=2473125    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without out-of-band-dtmf, out-of-band-dtmf = none, Out-of-band DTMF = none
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    out-of-band-dtmf=${out_of_band_dtmf}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${out_of_band_dtmf}    Out-of-band DTMF
    


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  