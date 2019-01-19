*** Settings ***
Documentation     SIP Profile Proxy Server default
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_Proxy_Server_default
    [Documentation]    1、Enter SIP-Profile without Proxy Server value. Associate Profile to the pots-port
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3286    @globalid=2473043    @priority=p5    @eut=GPON-8r2    @user_interface=CLI   
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1、Enter SIP-Profile without Proxy Server value. Associate Profile to the pots-port
    # Priority is P5,    

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    case setup   

case teardown
    [Documentation]    case teardown
    [Arguments]
    log    case teardown   