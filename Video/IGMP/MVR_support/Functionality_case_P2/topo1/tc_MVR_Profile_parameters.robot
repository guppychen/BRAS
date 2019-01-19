*** Settings ***
Documentation     This test case will verify that overlapping ranges are disallowed in MVr profiles
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${range1_start}    224.0.0.1
${range1_end}    224.0.0.10

# range2 overlap with range1
${range2_start}    224.0.0.5
${range2_end}    224.0.0.15

*** Test Cases ***
tc_Layer3_Applications_Video_MVR_Profile_parameters
    [Documentation]    1	Create an MVR profile. Assign a first range of 224.0.0.1 to 224.0.0.10. The vlan chosen doesn't matter	The command should be accepted		
    ...    2	Add a range to the profile. Chose one that overlaps the first, like 224.0.0.5 to 224.0.0.15.	This command should fail		
    ...    3	Display the MVR profile	The first entry should still be in the profile, with noting else
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1448    @globalid=2321516    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Teardown]   case teardown
    log    STEP:1 Create an MVR profile. Assign a first range of 224.0.0.1 to 224.0.0.10. The vlan chosen doesn't matter The command should be accepted
    prov_mvr_profile    eutA    ${p_mvr_prf}    ${range1_start}    ${range1_end}    ${mvr_vlan}
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=${range1_start} ${range1_end} ${mvr_vlan}

    log    STEP:2 Add a range to the profile. Chose one that overlaps the first, like 224.0.0.5 to 224.0.0.15. This command should fail
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    ${p_mvr_prf}    ${range2_start}    ${range2_end}    ${mvr_vlan}
    run keyword if     '${status}'=='PASS'    Fail    Failure: address ranges for MVR profile shouldn't overlap
    Should Contain Any    ${msg}    Invalid range    Range is overlapped

    log    STEP:3 Display the MVR profile The first entry should still be in the profile, with noting else
    ${res}    cli    eutA    show running-config mvr-profile ${p_mvr_prf}
    Should Match Regexp    ${res}    (?i)address\\s+${range1_start} ${range1_end} ${mvr_vlan}
    Should Not Match Regexp    ${res}    (?i)address\\s+${range2_start} ${range2_end} ${mvr_vlan}

*** Keywords ***
case teardown
    [Documentation]    case teardown
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}