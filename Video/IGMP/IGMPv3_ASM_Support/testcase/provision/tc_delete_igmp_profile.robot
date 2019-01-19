*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_delete_igmp_profile
    [Documentation]    1	Delete igmp-profiles that have not been assigned to a vlan. Show igmp-profile.	Verify deleted igmp-profile cannot be displayed
    ...    2	Create a new igmp-profile with same name. show igmp-profile.	Verify new igmp-profile of same name can be created & displayed.
    ...    3	Delete the system default igmp-profile.	Verify deletion is rejected.
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2237    @GlobalID=2346504
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Delete igmp-profiles that have not been assigned to a vlan. Show igmp-profile. Verify deleted igmp-profile cannot be displayed
    prov_igmp_profile    eutA    ${p_igmp_profile_test}
    ${result}    cli    eutA    show running-config igmp-profile ${p_igmp_profile_test}
    should contain    ${result}    igmp-profile ${p_igmp_profile_test}

    delete_config_object    eutA    igmp-profile    ${p_igmp_profile_test}
    ${result}    cli    eutA    show running-config igmp-profile ${p_igmp_profile_test}
    should contain    ${result}    error
    log    STEP:2 Create a new igmp-profile with same name. show igmp-profile. Verify new igmp-profile of same name can be created & displayed.
    prov_igmp_profile    eutA    ${p_igmp_profile_test}
    ${result}    cli    eutA    show running-config igmp-profile ${p_igmp_profile_test}
    should contain    ${result}    igmp-profile ${p_igmp_profile_test}
    log    STEP:3 Delete the system default igmp-profile. Verify deletion is rejected.
    Run Keyword And Ignore Error    delete_config_object    eutA    igmp-profile    SYSTEM
    ${result}    cli    eutA    show running-config igmp-profile SYSTEM
    should contain    ${result}    igmp-profile SYSTEM




*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2237 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2237 teardown
    delete_config_object    eutA    igmp-profile    ${p_igmp_profile_test}
