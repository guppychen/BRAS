*** Settings ***
Documentation     SIP Profile with Out of Band DTMF
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Out_of_Band_DTMF
    [Documentation]    1. no Out-of-band-DTMF, out-of-band-dtmf = none, Out-of-band DTMF = none
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3371    @globalid=2473128    @eut=GPON-8r2    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no Out-of-band-DTMF, out-of-band-dtmf = none, Out-of-band DTMF = none
    dprov_sip_profile    eutA    ${sip_profile}    =out-of-band-dtmf
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

  