*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_delete_igmp_profile_on_vlan
    [Documentation]    1	Delete igmp-profiles that have been assigned to a vlan. Show igmp-profile.	Verify the igmp-profile cannot be deleted if assigned to a vlan.
    ...    2	Verify the igmp-profile cannot be deleted if assigned to a vlan. Remove the igmp-profile from all vlans. Delete igmp-profile.	Verify custom igmp-profiles can be deleted if not assigned to a vlan.
    ...    3	Assign the deleted igmp-profile to vlan.	Verify the deleted igmp-profile cannot be assigned to a vlan.
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2238    @GlobalID=2346505
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Delete igmp-profiles that have been assigned to a vlan. Show igmp-profile. Verify the igmp-profile cannot be deleted if assigned to a vlan.
    prov_igmp_profile    eutA    ${p_igmp_profile_test}    auto
    prov_vlan    eutA    ${p_igmp_vlan}    igmp-profile=${p_igmp_profile_test}

    log    STEP:2 Verify the igmp-profile cannot be deleted if assigned to a vlan. Remove the igmp-profile from all vlans. Delete igmp-profile. Verify custom igmp-profiles can be deleted if not assigned to a vlan.
    cli    eutA    configure
    ${result}    cli    eutA    no igmp-profile ${p_igmp_profile_test}
    should contain    ${result}    Aborted: illegal reference 'vlan ${p_igmp_vlan} igmp-profile'
    cli    eutA    end

    log    STEP:3 Assign the deleted igmp-profile to vlan. Verify the deleted igmp-profile cannot be assigned to a vlan.
    dprov_vlan    eutA    ${p_igmp_vlan}    igmp-profile
    delete_config_object    eutA    igmp-profile    ${p_igmp_profile_test}
    cli    eutA    configure
    ${result}    cli    eutA    vlan ${p_igmp_vlan} igmp-profile ${p_igmp_profile_test}
    should contain    ${result}    Aborted: illegal reference 'vlan ${p_igmp_vlan} igmp-profile'
    cli    eutA    end


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2238 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2238 teardown
    delete_config_object    eutA    vlan    ${p_igmp_vlan}
