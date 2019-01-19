*** Settings ***
Documentation     Test suite verifies igmp ratelimit
Resource          ../base.robot

*** Variables ***
${mcast_profile}    NO_MVR
${attribute}    ratelimit
# ${default_interval}    50
${allow_interval}    1
# ${illegal_interval}    257
${subscriber_port_type}    ${service_model.subscriber_point1.attribute.interface_type}
${subscriber_port_name}    ${service_model.subscriber_point1.name}

*** Test Cases ***
tc_igmp_ratelimit
    [Documentation]       Test suite verifies igmp ratelimit
     ...    1.  Verify that default igmp ratelimit is 50
     ...    2.  Change ratelimit within acceptable range (1-50) and verify change
     ...    3.  Change ratelimit outside of acceptable range and verify change
    [Tags]    @author=llim    @globalid=2276044    @tcid=AXOS_E72_PARENT-TC-528    @user_interface=CLI    @priority=P1    @jira=EXA-28289
     ...  @jira=EXA-21530  @functional   @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 verify that igmp default ratelimit is 50
    ${vlan}    convert to string    ${p_data_vlan}
    check_running_config_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}    igmp ${attribute}=${p_default_igmp_ratelimit}

    log    STEP:2 Change ratelimit is within acceptable range (1-50) and verify change
    prov_interface     eutA    ${subscriber_port_type}    ${subscriber_port_name}     ${p_data_vlan}    igmp ${attribute}=${allow_interval}
    check_running_config_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}    igmp ${attribute}=${allow_interval}
    
    log    STEP:3 Change ratelimit is outside of acceptable range and verify change
    ${illegal_interval}    evaluate    ${p_max_igmp_ratelimit}+1
    ${status}    run keyword and return status    prov_interface     eutA    ${subscriber_port_type}    ${subscriber_port_name}     ${p_data_vlan}    
    ...    sub_view_type=igmp ${attribute}    sub_view_value=${illegal_interval}
    cli    eutA    show running-config interface ${subscriber_port_type} ${subscriber_port_name}
    run keyword if     ${status}==True    Fail    ${illegal_interval} (beyond max limit) shouldn't be provisioned successfully.
    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    case setup: Assign vlan to ont-ethernet
    prov_multicast_profile    eutA    ${mcast_profile}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${mcast_profile}
    
case teardown
    [Documentation]    case teardown
    log    case teardown: Unassign vlan from ont-ethernet
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${mcast_profile}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${mcast_profile}