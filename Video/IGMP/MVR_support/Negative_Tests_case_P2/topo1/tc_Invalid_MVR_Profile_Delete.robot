*** Settings ***
Documentation    Invalid MVR Profile Delete
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]

*** Test Cases ***
tc_Invalid_MVR_Profile_Delete
    [Documentation]
    ...    1	Attempt to perform the following MVR profile deletes: name not present.	Operation correctly is indicated as failed.	
    ...    2	Attempt to perform the following MVR profile deletes: missing parameter.	Operation correctly is indicated as failed.		
    ...    3	Attempt to perform the following MVR profile deletes: still present for multicast-profile.	Operation correctly is indicated as failed.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1502      @subFeature=MVR support      @globalid=2321571      @priority=P2    @user_interface=CLI    @eut=NGPON2-4    
    [Teardown]     case teardown
      
    log    STEP:1 Attempt to perform the following MVR profile deletes: name not present. Operation correctly is indicated as failed. 
    ${status}    ${msg}    Run Keyword And Ignore Error    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    run keyword if     '${status}'=='PASS'    Fail    Failure: shouldn't delete name not present mvr-profile
    should contain    ${msg}    not found
    
    log    STEP:2 Attempt to perform the following MVR profile deletes: missing parameter. Operation correctly is indicated as failed. 
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    ${status}    ${msg}    Run Keyword And Ignore Error    delete_config_object    eutA    mvr-profile    ${p_mvr_prf} address @{p_mvr_start_ip_list}[0]
    run keyword if     '${status}'=='PASS'    Fail    Failure: shouldn't delete mvr-profile with missing parameter
    should contain    ${msg}    incomplete path
    
    log    STEP:3 Attempt to perform the following MVR profile deletes: still present for multicast-profile. Operation correctly is indicated as failed. 
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    ${status}    ${msg}    Run Keyword And Ignore Error    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    run keyword if     '${status}'=='PASS'    Fail    Failure: shouldn't delete mvr-profile present for multicast-profile
    should contain    ${msg}    multicast-profile

    
*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
