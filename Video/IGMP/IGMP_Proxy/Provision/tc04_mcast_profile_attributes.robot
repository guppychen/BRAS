*** Settings ***
Documentation     Test suite verifies mcast profile attributes
Resource          ../base.robot

*** Variables ***
${profile}    1
${default_max_streams}    16
${min_allow_streams}    0
${max_allow_streams}    256
${illegal_max_allow_streams}    257

*** Test Cases ***
tc_verifies_mcast_profile_attributes
 
    [Documentation]       Test suite verifies mcast profile attributes
     
     ...    1.  verify that default number of max-streams is 16, min max-stream is 0 and max max-stream is 256
     ...    2.  Create and verify mvr-profile
     ...    3.  Assign mvr-profile to mcast-profile
     ...    4.  Create and verify mcast-whitelist-profile 
     ...    5.  Assign mcast-whitelist-profile to mcast-profile
     ...    6.  unassign_mvr-profile, mcast-whitelist-profile from mcast-profile
          
    [Tags]    @author=llim    @globalid=2276028
     ...   @jira=EXA-19498  @tcid=AXOS_E72_PARENT-TC-512    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    
    log    STEP:1 Verify that default number of max-streams is 16, min max-stream is 0 and max max-stream is 256
    check_running_configure    eutA    object=multicast-profile    object_value=${profile}    subview2=max-streams    max-streams=${default_max_streams}
    prov_multicast_profile    eutA    ${profile}    max-streams=${min_allow_streams}
    check_running_configure    eutA    object=multicast-profile    object_value=${profile}    subview2=max-streams    max-streams=${min_allow_streams}
    prov_multicast_profile    eutA    ${profile}    max-streams=${max_allow_streams}
    check_running_configure    eutA    object=multicast-profile    object_value=${profile}    subview2=max-streams    max-streams=${max_allow_streams}
    ${status}    run keyword and return status    prov_multicast_profile    eutA    ${profile}    max-streams=${illegal_max_allow_streams}
    run keyword if     ${status}==False    check_running_configure    eutA    object=multicast-profile    object_value=${profile}    subview2=max-streams    max-streams=${max_allow_streams}

    log    STEP:2 Create and verify mvr profile
    prov_mvr_profile    eutA    ${profile}    225.${profile}.0.1	225.${profile}.0.10    ${p_video_vlan}
    check_running_configure    eutA    mvr-profile    ${profile}
    
    log    STEP:3 Assign mvr-profile to mcast-profile
    prov_multicast_profile    eutA    ${profile}    mvr-profile=${profile}
    check_running_configure    eutA    multicast-profile    ${profile}    subview2=mvr-profile    mvr-profile=${profile}

    log    STEP:4 Create mcast-whitelist-profile and assign mcast-whitelist-profile to mcast-profile
    configure_whitelist_profile    eutA    ${profile}
    check_running_configure    eutA    multicast-whitelist-profile    ${profile}

    log    STEP:5 Assign whitelist-profile to mcast-profile
    prov_multicast_profile    eutA    ${profile}    multicast-whitelist-profile=${profile}
    check_running_configure    eutA    multicast-profile    ${profile}    subview2=multicast-whitelist-profile    multicast-whitelist-profile=${profile}
    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    case setup: create and verify mcast profile
    prov_multicast_profile    eutA    ${profile}
    check_running_configure    eutA    multicast-profile    ${profile}
    
case teardown
    [Documentation]    case teardown
    log    STEP:6 Unassign_mvr-profile, mcast-whitelist-profile from mcast-profile
    dprov_multicast_profile    eutA    ${profile}    multicast-whitelist-profile    mvr-profile

    log    case teardown: delete mcast-profile
    delete_config_object    eutA    mvr-profile    ${profile} 
    delete_config_object    eutA    multicast-whitelist-profile    ${profile} 
    delete_config_object    eutA    multicast-profile    ${profile}     