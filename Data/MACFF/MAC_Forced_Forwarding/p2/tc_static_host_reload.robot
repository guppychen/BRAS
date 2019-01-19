*** Settings ***
Documentation     Provision mff enabled with a static host entry. Reload system. -> MFF entries can be restored after system reload.
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen

*** Variables ***


*** Test Cases ***
tc_static_host_reload
    [Documentation]    Provision mff enabled with a static host entry. Reload system. -> MFF entries can be restored after system reload.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1437   @subFeature=MAC_Forced_Forwarding    @globalid=2286206    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1437 setup
    [Teardown]   AXOS_E72_PARENT-TC-1437 teardown
    log    reload system
    Reload System    eutA
    wait until keyword succeeds    100s    2s    check_l3_hosts    eutA    0    ${service_vlan1}    gateway1=${gateway_ip1}    l3-host=${gateway_ip1}    mac=${gateway_mac1} 
    log    check snoop table
    ${res}    cli    eutA    show l3-hosts
    ${match}    ${grp1}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${gateway_ip1}(.*)l3-host
    Log    ${grp1}
    log     verify AR info
    should match regexp    ${grp1}    mac\\s+${gateway_mac1}
    should match regexp    ${grp1}    interface\\s+${service_model.service_point2.member.interface1}
    log     verify static host info
    ${match}    ${grp2}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${subscriber_ip1}(.*)up-down-state
    should match regexp    ${grp2}    gateway1\\s+${gateway_ip1}   
     
*** Keywords ***
AXOS_E72_PARENT-TC-1437 setup
    [Documentation]  setup
    [Arguments]
    log    setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=ENABLED    source-verify=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    log    create static hosts
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${gateway_ip1} mac ${subscriber_mac1}
AXOS_E72_PARENT-TC-1437 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static hosts
    # Modify by AT-5392
    Wait Until Keyword Succeeds    5min    30s  Verify Cmd Working After Reload
    ...    eutA    show version
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
