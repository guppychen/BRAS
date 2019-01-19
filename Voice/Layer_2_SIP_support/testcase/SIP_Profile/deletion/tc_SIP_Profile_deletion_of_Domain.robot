*** Settings ***
Documentation     SIP Profile deletion of Domain
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Profile_deletion_of_Domain
    [Documentation]    1. no domain, domain = no, Domain =
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3387    @globalid=2473144    @eut=GPON-8r2     @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. no domain, domain = no, Domain =
    prov_sip_profile    eutA    ${sip_profile}    ${proxy_server}    ${EMPTY}    ${EMPTY}    ${EMPTY}    domain=${domain_1}
    dprov_sip_profile    eutA    ${sip_profile}    =domain
    ${res}    cli    eutA    show running-config sip-profile ${sip_profile} | detail 
    should not contain    ${res}    domain 
    Wait Until Keyword Succeeds    5min    10sec    check_ont_sip_profile    ontA    ${domain}    Domain     


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

  