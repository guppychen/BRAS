*** Settings ***
Documentation     Test suite creates minimum of 30 mcast profile support on system
Resource          ../base.robot


*** Variables ***
${mcast_total}    31
${subscriber_port_type}    ${service_model.subscriber_point1.attribute.interface_type}
${subscriber_port_name}    ${service_model.subscriber_point1.name}

*** Test Cases ***
tc_create_minimum_30_mcast_profiles_on_system

    [Documentation]       Test suite creates minimum of 30 mcast profile support on system
    ...    1.  verify that all mcast profiles successfully created
    ...    2.  assign mcast profile 8 to ONT
    ...    3.  verify that vlan and mcast profile 8 successfully assigned to ONT

    [Tags]    @author=llim    @globalid=2276024    @tcid=AXOS_E72_PARENT-TC-508    @user_interface=CLI    @priority=P1    @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown

    log    STEP:1 Verify that all mcast profiles successfully created
    : FOR    ${each}    IN RANGE    1    ${mcast_total}+1
    \    check_running_configure    eutA    multicast-profile    ${each}
    
    log    STEP:2 Assign mcast profile 8 to ONT
    ${mcast_profile}    set variable    8
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${mcast_profile}
    
    log    STEP:3 Verify that vlan and mcast profile 8 successfully assigned to ONT
    check_running_config_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}    igmp multicast-profile=${mcast_profile}
    
    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    case setup: Create 30 mcast profiles and assign them to ONT
    : FOR    ${each}    IN RANGE    1    ${mcast_total}+1
    \    prov_multicast_profile    eutA    ${each}    
    
case teardown
    [Documentation]    case teardown
    log    case teardown: Unassign and delete all multicast profiles
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=8

    : FOR    ${each}    IN RANGE    1    ${mcast_total}+1
    \    delete_config_object    eutA    multicast-profile    ${each}