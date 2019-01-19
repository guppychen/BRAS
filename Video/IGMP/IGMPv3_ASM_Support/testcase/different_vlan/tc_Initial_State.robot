*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Initial_State
    [Documentation]    1	config system work under igmp v3 version	provision successful
    ...    2	Show vlan igmp mode	the pon and ont port under igmp v3 mode
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2290    @GlobalID=2346557
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 config system work under igmp v3 version provision successful

    log    STEP:2 Show vlan igmp mode the pon and ont port under igmp v3 mode

    log    check igmp host version after set igmp version in igmp profile
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V3    @{p_proxy_1.ip}[0]




*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2290 setup
    prov_igmp_profile    eutA    ${p_igmp_profile1}    V3


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2290 teardown
    prov_igmp_profile    eutA    ${p_igmp_profile1}    AUTO
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}