*** Settings ***
Documentation     SIP service missing mandatory parameters
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_service_missing_mandatory_parameters
    [Documentation]    1. Enter POTS interface without sip service: interface pots 211/p1 ip-host 1 user 2012069019 password 2012069019 uri 2012069019, command should be rejected
    ...    2. Enter POTS interface without IP Host: interface pots 211/p1 sip-service Daniel user 2012069019 password 2012069019 uri 2012069019, command should be rejected
    ...    3. Enter POTS interface without user: interface pots 211/p1 sip-service Daniel ip-host 1 password 2012069019 uri 2012069019, command should be rejected
    ...    4. Enter POTS interface without password: interface pots 211/p1 sip-service Daniel ip-host 1 user 2012069019 uri 2012069019, command should be rejected
    ...    5. Enter POTS interface without URI: interface pots 211/p1 sip-service Daniel ip-host 1 user 2012069019 password 2012069019, command should be rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3409    @globalid=2473166    @priority=P3    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter POTS interface without sip service: interface pots 211/p1 ip-host 1 user 2012069019 password 2012069019 uri 2012069019, command should be rejected
    cli    eutA    configure
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    ${res}    cli    eutA    interface pots ${pots_id1} uri ${uri_number1} user ${user_number1} password ${password} 
    should contain    ${res}    element does not exist
    log    STEP:2. Enter POTS interface without IP Host: interface pots 211/p1 sip-service Daniel user 2012069019 password 2012069019 uri 2012069019, command should be rejected
    # this command is accepted 
    log    STEP:3. Enter POTS interface without user: interface pots 211/p1 sip-service Daniel ip-host 1 password 2012069019 uri 2012069019, command should be rejected
    ${res}    cli    eutA    interface pots ${pots_id1} uri ${uri_number1} password ${password} 
    should contain    ${res}    element does not exist
    
    log    STEP:4. Enter POTS interface without password: interface pots 211/p1 sip-service Daniel ip-host 1 user 2012069019 uri 2012069019, command should be rejected
    ${res}    cli    eutA    interface pots ${pots_id1} uri ${uri_number1} user ${user_number1} 
    should contain    ${res}    element does not exist
    
    log    STEP:5. Enter POTS interface without URI: interface pots 211/p1 sip-service Daniel ip-host 1 user 2012069019 password 2012069019, command should be rejected
    ${res}    cli    eutA    interface pots ${pots_id1} user ${user_number1} password ${password} 
    should contain    ${res}    element does not exist
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