*** Settings ***
Documentation    keyword for axos service level
Resource         ../base.robot

*** Keywords ***
l2_setting_prov_vlan_policy
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${match_vlan}    ${svlan}    ${ctag_action}=${EMPTY}    ${cvlan}=${EMPTY}
    ...    ${cevlan_action}=${EMPTY}    ${cevlan}=${EMPTY}    ${mcast_profile}=${EMPTY}    ${cfg_prefix}=auto    &{dict_policy_map_option_cmd}
    [Documentation]    Description:
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type, {ethernet|ont-ethernet} |
    ...    | port_name | interface name |
    ...    | match_vlan | class-map match vlan, set to untagged for untagged |
    ...    | svlan | interface svlan |
    ...    | ctag_action | policy-map ctag action, {add-ctag} |
    ...    | cvlan | policy-map cvlan |
    ...    | cevlan_action | policy-map ctag action, {remove-cevlan|translate-cevlan-tag} |
    ...    | cevlan | policy-map cevlan, no need to set it when using remove-cevlan action |
    ...    | mcast_profile | multicast profile for video service |
    ...    | cfg_prefix | string as configuration name prefix |
    ...    | dict_policy_map_option_cmd | dictionary format command for policy-map |
    ...
    ...    Return Value:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | dict_prf | dictionary format profile name, use &{dict_prf}[classmap] to get class-map name, use &{dict_prf}[policymap] to get policy-map name |
    ...
    ...    Example:
    ...    | l2_setting_prov_vlan_policy | eutA | ont-ethernet | 100/x1 | 100 | 300 | add-ctag | 300 | remove-cevlan |
    ...    | l2_setting_prov_vlan_policy | eutA | ont-ethernet | 100/x1 | 100 | 300 | add-ctag | 300 | translate-cevlan-tag | 200 | set-ctag-pcp=7 | set-cevlan-pcp=5 |
    ...    This is the example for how to use return value to add more rule on class-map and policy map:
    ...    | &{dict_prf} | l2_setting_prov_vlan_policy | eutA | ont-ethernet | 100/x1 | 100 | 300 | add-ctag | 300 | remove-cevlan |
    ...    | prov_class_map | eutA | &{dict_prf}[classmap] | ethernet | flow | 2 | 1 | vlan=1000 |
    ...    | prov_policy_map | eutA | &{dict_prf}[policymap] | class-map-ethernet | &{dict_prf}[classmap] | flow | 2 | translate-cevlan-tag=400 |
    [Tags]    @author=CindyGao
    log    ****** [${device}] add l2 basic service to ${port_type} ${port_name} ******
    ${class_map}    set variable    ${cfg_prefix}_ClassMap_v${match_vlan}
    ${policy_map}    set variable if    '${EMPTY}'=='${cevlan}'    ${cfg_prefix}_PolicyMap_v${cvlan}    ${cfg_prefix}_PolicyMap_v${cvlan}_${cevlan}
    &{dic_prf}    create dictionary    classmap=${class_map}    policymap=${policy_map}
    
    log    create class-map
    &{dict_match_rule}    run keyword if    'untagged'=='${match_vlan}'    create dictionary    untagged=${EMPTY}
    ...    ELSE IF    'any'=='${match_vlan}'    create dictionary    any=${EMPTY}
    ...    ELSE    create dictionary    vlan=${match_vlan}
    prov_class_map    ${device}    ${class_map}    ethernet    flow    1    1    &{dict_match_rule}

    log    create policy-map
    # [AT-3433] added by CindyGao for "EXA-23493 | add-ctag renamed to add-cevlan-tag", start
    ${ctag_action}    Run Keyword If    '${ctag_action}'=='add-ctag' or '${ctag_action}'=='add-cevlan-tag' or '${cevlan_action}'=='add-cevlan-tag'
    ...    release_cmd_adapter    ${device}    ${prov_policy_map_config_add_tag}
    ...    ELSE    set variable    ${ctag_action}
    # [AT-3433] added by CindyGao for "EXA-23493 | add-ctag renamed to add-cevlan-tag", end
    prov_policy_map    ${device}    ${policy_map}    class-map-ethernet    ${class_map}    flow    1
    ...    ${ctag_action}=${cvlan}    ${cevlan_action}=${cevlan}    &{dict_policy_map_option_cmd}
  
    log    add policy-map to interface
    Run keyword and ignore error    check_running_config_interface    ${device}    ${port_type}    ${port_name} 
    # [AT-3358] added by CindyGao for 35b adapt, start
    prov_interface    ${device}    ${port_type}    ${port_name}    ${svlan}    no=shutdown
    # [AT-3358] added by CindyGao for 35b adapt, end
    prov_interface    ${device}    ${port_type}    ${port_name}    ${svlan}    ${policy_map}    class-map-ethernet    ${class_map}

    log    add multicast-profile to interface
    run keyword if     "${mcast_profile}"!="${EMPTY}"    prov_interface    ${device}    ${port_type}    ${port_name}    ${svlan}    igmp multicast-profile=${mcast_profile}

    log    check eth-svc
    check_running_config_interface    ${device}    ${port_type}    ${port_name}    policy-map=${policy_map}    class-map-ethernet=${class_map}
    run keyword if     "${mcast_profile}"!="${EMPTY}"    check_running_config_interface    ${device}    ${port_type}    ${port_name}    igmp multicast-profile=${mcast_profile}
    
    [Return]    &{dic_prf}

l2_setting_dprov_vlan_policy
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${match_vlan}    ${svlan}    ${cvlan}=${EMPTY}    ${cevlan}=${EMPTY}    ${mcast_profile}=${EMPTY}    ${cfg_prefix}=auto
    [Documentation]    Description:
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type, {ethernet|ont-ethernet} |
    ...    | port_name | interface name |
    ...    | match_vlan | class-map match vlan, set to untagged for untagged |
    ...    | svlan | interface svlan |
    ...    | ctag_action | policy-map ctag action, {add-ctag} |
    ...    | cvlan | policy-map cvlan |
    ...    | cevlan_action | policy-map ctag action, {remove-cevlan|translate-cevlan-tag} |
    ...    | cevlan | policy-map cevlan, no need to set it when using remove-cevlan action |
    ...    | cfg_prefix | string as configuration name prefix |
    ...    | dict_policy_map_option_cmd | dictionary format command for policy-map |
    ...
    ...    Example:
    ...    | l2_setting_dprov_vlan_policy | eutA | ont-ethernet | 100/x1 | 100 | 300 |
    [Tags]    @author=CindyGao
    log    ****** [${device}] remove l2 basic service from ${port_type} ${port_name} ******
    ${class_map}    set variable    ${cfg_prefix}_ClassMap_v${match_vlan}
    ${policy_map}    set variable if    '${EMPTY}'=='${cevlan}'    ${cfg_prefix}_PolicyMap_v${cvlan}    ${cfg_prefix}_PolicyMap_v${cvlan}_${cevlan}
    
    log    check eth-svc
    ${res}    cli    ${device}    show running-config interface ${port_type} ${port_name}

    log    remove multicast-profile from interface
    run keyword if    "${mcast_profile}"!="${EMPTY}"    Run Keyword And Continue On Failure    dprov_interface    ${device}    ${port_type}    ${port_name}    ${svlan}    igmp multicast-profile=${EMPTY}
    log    remove policy-map from interface
    Run Keyword And Continue On Failure    dprov_interface    ${device}    ${port_type}    ${port_name}    ${svlan}    policy-map=${policy_map}
    log    remove svlan from interface
    Run Keyword And Continue On Failure    dprov_interface    ${device}    ${port_type}    ${port_name}    vlan=${svlan}
    
    log    check eth-svc
    ${res}    cli    ${device}    show running-config interface ${port_type} ${port_name}

    log    delete policy-map
    # dprov_policy_map    ${device}    ${policy_map}    class-map-ethernet=${class_map}
    delete_config_object    ${device}    policy-map    ${policy_map}

    log    delete class-map
    # dprov_class_map    ${device}    ${class_map}    ethernet    flow=1
    delete_config_object    ${device}    class-map ethernet    ${class_map}

igmp_prov_vlan_igmp_profile
    [Arguments]    ${device}    ${igmp_prf}    @{vlan_list}
    [Documentation]    Description:
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | igmp_prf | igmp-profile name |
    ...    | vlan_list | vlan list to add igmp-profile |
    ...    Example:
    ...    | igmp_prov_vlan_igmp_profile | eutA | igmpv2 | 100 | 200 | 300 |
    [Tags]    @author=CindyGao
    log    ******[${device}] add igmp profile ${igmp_prf}******
    log    create igmp profile
    prov_igmp_profile    ${device}    ${igmp_prf}    auto
    log    bound igmp profile to video vlan
    : FOR    ${vlan}    IN    @{vlan_list}
    \    prov_vlan    ${device}    ${vlan}    igmp-profile=${igmp_prf}

igmp_dprov_vlan_igmp_profile
    [Arguments]    ${device}    ${igmp_prf}    @{vlan_list}
    [Documentation]    Description:
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | igmp_prf | igmp-profile name |
    ...    | vlan_list | vlan list to add igmp-profile |
    ...    Example:
    ...    | igmp_dprov_vlan_igmp_profile | eutA | igmpv2 | 100 | 200 | 300 |
    [Tags]    @author=CindyGao
    log    ******[${device}] delete igmp profile ${igmp_prf}******
    log    bound igmp profile to video vlan
    : FOR    ${vlan}    IN    @{vlan_list}
    \    dprov_vlan    ${device}    ${vlan}    igmp-profile
    log    delete igmp profile
    delete_config_object    ${device}    igmp-profile    ${igmp_prf}

igmp_prov_proxy
    [Arguments]    ${device}    ${proxy_intf}    ${proxy_ip}    ${proxy_mask}    ${proxy_gw}    @{vlan_list}
    [Documentation]    Description:
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | proxy_intf | restricted-ip-host name |
    ...    | proxy_ip | restricted-ip-host ip |
    ...    | proxy_mask | restricted-ip-host mask |
    ...    | proxy_gw | restricted-ip-host gateway |
    ...    | vlan_list | vlan list to add igmp-profile |
    ...    Example:
    ...    | igmp_prov_proxy | eutA | 1 | 7.7.7.7 | 255.255.255.0 | 7.7.7.1 | 100 | 200 | 300 |
    [Tags]    @author=CindyGao
    log    ******[${device}] create igmp proxy interface restricted-ip-host ${proxy_intf} with ip:${proxy_ip}******    
    log    config igmp proxy
    : FOR    ${vlan}    IN    @{vlan_list}
    \    prov_interface    ${device}    restricted-ip-host    ${proxy_intf}    vlan=${vlan}
    prov_interface_ip    ${device}    restricted-ip-host    ${proxy_intf}    ${proxy_ip}    ${proxy_mask}    ${proxy_gw}
    no_shutdown_port    ${device}    restricted-ip-host    ${proxy_intf}
    
# igmp_dprov_proxy
    # [Arguments]    ${device}    ${proxy_intf}    ${proxy_ip}    ${proxy_mask}    ${proxy_gw}    ${vlan_list}
    # [Documentation]    Description:
    # ...
    # ...    Arguments:
    # ...    | =Argument Name= | \ =Argument Value= \ |
    # ...    | device | eut node in topo.yaml |
    # ...    | proxy_intf | restricted-ip-host name |
    # ...    | proxy_ip | restricted-ip-host ip |
    # ...    | proxy_mask | restricted-ip-host mask |
    # ...    | proxy_gw | restricted-ip-host gateway |
    # ...    | vlan_list | vlan list to add igmp-profile |
    # ...    Example:
    # ...    | igmp_prov_proxy | eutA | 1 | 7.7.7.7 | 255.255.255.0 | 7.7.7.1 | 100 | 200 | 300 |
    # [Tags]    @author=CindyGao
    # log    ******[${device}] create igmp proxy interface restricted-ip-host ${proxy_intf} with ip:${proxy_ip}******    
    # log    config igmp proxy
    # : FOR    ${vlan}    IN    @{vlan_list}
    # \    prov_interface    ${device}    restricted-ip-host    ${proxy_intf}    vlan=${vlan}
    # prov_interface_ip    ${device}    restricted-ip-host    ${proxy_intf}    ${proxy_ip}    ${proxy_mask}    ${proxy_gw}
    # no_shutdown_port    ${device}    restricted-ip-host    ${proxy_intf}
    
gpon_prov_official_ont_profile
    [Arguments]    ${device}    ${ont_profile}
    [Documentation]    Description: create official ont-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | ont_profile | ont profile name |
    ...    Example:
    ...    | gpon_create_official_ont_profile | eutA | 811NG |
    [Tags]    @author=CindyGao
    log    ******[${device}] create ont profile ${ont_profile} if not exist******    
    log    check ont-profile exist
    ${res}    cli    ${device}    show running-config ont-profile ${ont_profile}
    ${status}    ${result}    Run Keyword And Ignore Error    should match Regexp    ${res}    interface
    return from keyword if    'PASS'=='${status}'
    
    log    create official ont-profile
    run keyword if    'GP1000X'=='${ont_profile}' or '811NG'=='${ont_profile}'    prov_ont_profile    ${device}    ${ont_profile}    ont-ethernet    x1
    run keyword if    'GP1000X'=='${ont_profile}' or '811NG'=='${ont_profile}'    prov_ont_profile    ${device}    ${ont_profile}    ont-ethernet    g1
    
gpon_dprov_official_ont_profile
    [Arguments]    ${device}    ${ont_profile}
    [Documentation]    Description: create official ont-profile
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | ont_profile | ont profile name |
    ...    Example:
    ...    | gpon_dprov_official_ont_profile | eutA | 811NG |
    [Tags]    @author=CindyGao
    log    ******[${device}] delete ont profile ${ont_profile} if no ont use it******    
    log    check ont-profile usage
    ${res}    cli    ${device}    show running-config ont
    ${status}    ${result}    Run Keyword And Ignore Error    should match Regexp    ${res}    ${ont_profile}
    return from keyword if    'PASS'=='${status}'
    
    log    delete ont profile
    delete_config_object    ${device}    ont-profile    ${ont_profile}