*** Settings ***
Documentation     SIP Profile with Switch type
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_with_Switch_type
    [Documentation]    1. Enter SIP-Profile switch-type = zte huaw syla eric cs2k bell, switch-type = selection, Switch type = selection
    ...    2. Enter SIP-Profile switch-type = abc, command rejected
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3401    @globalid=2473158    @priority=P1    @eut=GPON-8r2    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter SIP-Profile switch-type = zte huaw syla eric cs2k bell, switch-type = selection, Switch type = selection
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    switch-type=${switch_type_zte}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    switch-type=${switch_type_zte}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${switch_type_zte}    Switch Type
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    switch-type=${switch_type_huaw}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    switch-type=${switch_type_huaw}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${switch_type_huaw}    Switch Type
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    switch-type=${switch_type_syla}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    switch-type=${switch_type_syla}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${switch_type_syla}    Switch Type
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    switch-type=${switch_type_eric}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    switch-type=${switch_type_eric}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${switch_type_eric}    Switch Type
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    switch-type=${switch_type_cs2k}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    switch-type=${switch_type_cs2k}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${switch_type_cs2000}    Switch Type
    
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    switch-type=${switch_type_bell}
    Wait Until Keyword Succeeds    2min    10sec    check_running_configure    eutA    sip-profile    ${sip_profile}    | detail    switch-type=${switch_type_bell}
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${switch_type_bell}    Switch Type
    
    log    STEP:2. Enter SIP-Profile switch-type = abc, command rejected
    cli    eutA    configure
    ${res}    cli    eutA    sip-profile ${sip_profile} switch-type ${switch_type_abc} 
    should contain    ${res}    "${switch_type_abc}" is an invalid value
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
    dprov_sip_profile    eutA    ${sip_profile}    =switch-type

  