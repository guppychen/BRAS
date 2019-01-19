*** Settings ***
Documentation     pon module work with ont
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_pon_module_work_with_ont
    [Documentation]    1	Insert PON module in slot 1.	.
    ...    2	Link PON to ONT(s).
    ...    3	With PON module in service, try to delete PON module from slot.
    [Tags]       @author=PEIJUN LIU     @TCID=AXOS_E72_PARENT-TC-2956     @globalid=2393710
    ...    @subfeature=Discovery_and_Inventory_of_XFP_and_PON_OIMs    @feature=HW_Support    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Insert PON module in slot 1. .
    log    STEP:2 Link PON to ONT(s).
    log    STEP:3 With PON module in service, try to delete PON module from slot.
    log     create traffic
    create_raw_traffic_udp    tg1    up1    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    down1    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    log    check all traffic can pass
    Tg Start All Traffic    tg1
    # wait enough time to run
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # wait to stop
    sleep    ${wait_time}
    TG Verify Traffic Loss For Stream Is Within    tg1    up1    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    down1    ${loss_rate}





*** Keywords ***
case setup
    [Documentation]   case setup
    [Arguments]
    log    create vlan
    prov_vlan    eutA    ${service_vlan}
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error      Tg Stop All Traffic    tg1
    run keyword and ignore error      Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}

