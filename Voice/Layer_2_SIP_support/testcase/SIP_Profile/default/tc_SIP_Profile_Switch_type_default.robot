*** Settings ***
Documentation     SIP Profile Switch type default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Switch_type_default
    [Documentation]    1. Enter SIP-Profile without switch-type, switch-type = none
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3400    @globalid=2473157    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile without switch-type, switch-type = none
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    switch-type=${switch_type}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${switch_type}    Switch Type



*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup    

case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  