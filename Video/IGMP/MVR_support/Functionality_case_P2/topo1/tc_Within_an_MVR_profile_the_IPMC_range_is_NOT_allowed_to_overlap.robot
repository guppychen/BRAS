*** Settings ***
Documentation     Within an MVR profile, the IPMC range is NOT allowed to overlap
Resource          ./base.robot


*** Variables ***
${range1_start}    225.1.1.1
${range1_end}    225.1.1.10

# range2 overlap with range1
${range2_start}    225.1.1.5
${range2_end}    225.1.1.20

# range3 not overlap with range1
${range3_start}    225.1.1.11
${range3_end}    225.1.1.20

*** Test Cases ***
tc_Within_an_MVR_profile_the_IPMC_range_is_NOT_allowed_to_overlap
    [Documentation]    1	Create 2 service vlans, create igmp profile, set vlans igmp mode proxy, version v2	Success		
    ...    2	Create mvr-profile, add mvr-profile to vlan 1 with range 1 Success		
    ...    3	Try to add range 2 which overlaps range 1 to vlan 1	Fail with message: address ranges for MVR profile must not overlap.		
    ...    4	Try to add range 2 which overlaps range 1 to vlan 2	Fail with message: address ranges for MVR profile must not overlap.		
    ...    5	Delete your configurations	Success
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1461    @globalid=2321529    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Teardown]   case teardown
    log    STEP:1 Create 2 service vlans, create igmp profile, set vlans igmp mode proxy, version v2 Success(Done in init file)

    log    STEP:2 Create mvr-profile, add mvr-profile to vlan 1 with range 1 Success
    prov_mvr_profile    eutA    ${p_mvr_prf}    ${range1_start}    ${range1_end}    @{p_video_vlan_list}[0]
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=${range1_start} ${range1_end} @{p_video_vlan_list}[0]

    log    STEP:3 Try to add range 2 which overlaps range 1 to vlan 1 Fail with message: address ranges for MVR profile must not overlap.
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    ${p_mvr_prf}    ${range2_start}    ${range2_end}    @{p_video_vlan_list}[0]
    run keyword if     '${status}'=='PASS'    Fail    Failure: address ranges for MVR profile shouldn't overlap
    Should Contain Any    ${msg}    Invalid range    Range is overlapped

    log    STEP:4 Try to add range 2 which overlaps range 1 to vlan 2 Fail with message: address ranges for MVR profile must not overlap.
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    ${p_mvr_prf}    ${range2_start}    ${range2_end}    @{p_video_vlan_list}[1]
    run keyword if     '${status}'=='PASS'    Fail    Failure: address ranges for MVR profile shouldn't overlap
    Should Contain Any    ${msg}    Invalid range    Range is overlapped
    
    log    Try to add range 2 which not overlaps range 1 to vlan 2 Success
    prov_mvr_profile    eutA    ${p_mvr_prf}    ${range3_start}    ${range3_end}    @{p_video_vlan_list}[1]
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=${range3_start} ${range3_end} @{p_video_vlan_list}[1]

    log    STEP:5 Delete your configurations Success (see case teardown part)

*** Keywords ***
case teardown
    [Documentation]    case teardown
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
