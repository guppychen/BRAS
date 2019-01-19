*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Edit_IGMP_profile
    [Documentation]    1	edit the IGMP version = v3	Action succeed and can be retrieved.
    ...    2	edit the IGMP version = auto	Action succeed and can be retrieved.
    ...    3	edit the IGMP version = v2	Action succeed and can be retrieved
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2236    @GlobalID=2346503
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 edit the IGMP version = v3 Action succeed and can be retrieved.
    prov_igmp_profile    eutA    ${p_igmp_profile1}    V3
    ${result}    cli    eutA    show running-config igmp-profile ${p_igmp_profile1}
    should match regexp    ${result}    igmp-version\\s+V3
    log    STEP:2 edit the IGMP version = auto Action succeed and can be retrieved.
    prov_igmp_profile    eutA    ${p_igmp_profile1}    auto
    ${result}    cli    eutA    show running-config igmp-profile ${p_igmp_profile1}
    should match regexp    ${result}    igmp-version\\s+AUTO
    log    STEP:3 edit the IGMP version = v2 Action succeed and can be retrieved
    prov_igmp_profile    eutA    ${p_igmp_profile1}    V2
    ${result}    cli    eutA    show running-config igmp-profile ${p_igmp_profile1}
    should match regexp    ${result}    igmp-version\\s+V2




*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2236 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2236 teardown
    prov_igmp_profile    eutA    ${p_igmp_profile1}    auto