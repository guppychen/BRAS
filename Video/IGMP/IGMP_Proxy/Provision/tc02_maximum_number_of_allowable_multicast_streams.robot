*** Settings ***
Documentation     Test suite verifies maximum allowable number of multicast streams
Resource          ../base.robot

*** Variables ***
${mcast_total}    1
${default_max_streams}    16
${max_allow_streams}    256
${illegal_max_allow_streams}    257

*** Test Cases ***
tc_maximum_allowable_number_of_multicast_streams
 
     [Documentation]       Test suite verifies maximum allowable number of multicast streams
     
     ...    1.  Verify that default maximum number of streams is 16
     ...    2.  Set max-streams to 256 (max allowable) and verify configuration is successful
     ...    3.  Set max-streams to 257 and verify configuration is unsuccessful
     
    [Tags]    @author=llim    @globalid=2276025    @tcid=AXOS_E72_PARENT-TC-509    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown

    log    STEP:1 Verify that default maximum number of streams is 16
    check_running_configure    eutA    object=multicast-profile    object_value=${mcast_total}    subview2=max-streams    max-streams=${default_max_streams}
    log    STEP:2 Set max-streams to 256 (max allowable) and verify configuration is successful
    prov_multicast_profile    eutA    ${mcast_total}    max-streams=${max_allow_streams}
    check_running_configure    eutA    object=multicast-profile    object_value=${mcast_total}    max-streams=${max_allow_streams}
    log    STEP:3 Set max-streams to 257 and verify configuration is unsuccessful
    ${status}    run keyword and return status    prov_multicast_profile    eutA    ${mcast_total}    max-streams=${illegal_max_allow_streams}
    run keyword if     ${status}==False    check_running_configure    eutA    object=multicast-profile    object_value=${mcast_total}    subview2=max-streams    max-streams=${max_allow_streams}
#    Run Keyword And Continue On Failure    configure_and_verify_illegal_maximum_allowable_streams    n1    ${mcast_total}    ${illegal_max_allow_streams}
    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    case setup: Create and verify mcast profile
    prov_multicast_profile    eutA    ${mcast_total}
    check_running_configure    eutA    multicast-profile    ${mcast_total}
    
case teardown
    [Documentation]    case teardown
    log    case teardown: delete mcast profile
    delete_config_object    eutA    multicast-profile    ${mcast_total} 