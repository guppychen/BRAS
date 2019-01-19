*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_create_IGMP_profile
    [Documentation]    1	Provision IGMP version = v2	Action succeed and can be retrieved.
    ...    2	Provision IGMP version = v3	Action succeed and can be retrieved.
    ...    3	Provision IGMP version = auto	Action succeed and can be retrieved.
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2235    @GlobalID=2346502
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Provision IGMP version = v2 Action succeed and can be retrieved.
    prov_igmp_profile    eutA    ${p_igmp_profile_test}    V2
    ${result}    CLI    eutA    show running-config igmp-profile ${p_igmp_profile_test}
    should match regexp    ${result}    igmp-version\\s+V2
    log    STEP:2 Provision IGMP version = v3 Action succeed and can be retrieved.
    prov_igmp_profile    eutA    ${p_igmp_profile_test}    V3
    ${result}    CLI    eutA    show running-config igmp-profile ${p_igmp_profile_test}
    should match regexp    ${result}    igmp-version\\s+V3
    log    STEP:3 Provision IGMP version = auto Action succeed and can be retrieved.
    prov_igmp_profile    eutA    ${p_igmp_profile_test}    auto
    ${result}    CLI    eutA    show running-config igmp-profile ${p_igmp_profile_test}
    should match regexp    ${result}    igmp-version\\s+AUTO


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2235 setup

case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2235 teardown
    delete_config_object    eutA    igmp-profile    ${p_igmp_profile_test}