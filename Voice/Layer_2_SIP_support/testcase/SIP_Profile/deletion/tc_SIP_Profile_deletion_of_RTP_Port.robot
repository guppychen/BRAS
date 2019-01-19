*** Settings ***
Documentation     SIP Profile deletion of RTP Port
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_RTP_Port
    [Documentation]    1. no rtp-port, rtp-port = 49152, RTP Port = 49152
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3399    @globalid=2473156    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no rtp-port, rtp-port = 49152, RTP Port = 49152
    dprov_sip_profile    eutA    ${sip_profile}    =rtp-port
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    rtp-port=${rtp_port}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${rtp_port}    RTP Port

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  