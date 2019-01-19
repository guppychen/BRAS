*** Settings ***
Documentation    keyword for axos servie model
Resource         ../base.robot

*** Keywords ***
################################### keyword used in TCs #####################################
service_point_prov
    [Arguments]    ${service_point_list}
    [Documentation]    Description: provision for service_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_prov | service_point_list1 |
    [Tags]    @author=CindyGao
    : FOR    ${service_point}    IN    @{service_model.${service_point_list}}
    \    ${device}    set variable    ${service_model.${service_point}.device}
    \    log    ****** uplink service provision for ${device} ${service_point} ******
    \    Run Keyword    service_point_${service_model.${service_point}.type}_prov    ${device}    ${service_point}

service_point_dprov
    [Arguments]    ${service_point_list}
    [Documentation]    Description: deprovision for service_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_dprov | service_point_list1 |
    [Tags]    @author=CindyGao
    : FOR    ${service_point}    IN    @{service_model.${service_point_list}}
    \    ${device}    set variable    ${service_model.${service_point}.device}
    \    log    ****** uplink service deprovision for ${device} ${service_point} ******
    \    Run Keyword    service_point_${service_model.${service_point}.type}_dprov    ${device}    ${service_point}

service_point_list_check_status_up
    [Arguments]    ${service_point_list}
    [Documentation]    Description: provision for service_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_list_check_status_up | service_point_list1 |
    [Tags]    @author=CindyGao
    : FOR    ${service_point}    IN    @{service_model.${service_point_list}}
    \    ${device}    set variable    ${service_model.${service_point}.device}
    \    log    ****** service provision check for ${device} ${service_point} ******
    \    Wait Until Keyword Succeeds    5min    10sec    service_point_${service_model.${service_point}.type}_check    ${service_point}

service_point_add_vlan
    [Arguments]    ${service_point_list}    ${vlan_list}    ${cfg_prefix}=auto
    [Documentation]    Description: add vlan for service_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_add_vlan | service_point_list1 | 100 |
    ...    | service_point_add_vlan | service_point_list1 | 30,100-200 |
    [Tags]    @author=CindyGao
    ${vlan_list_str}    Convert To String    ${vlan_list}
    ${vlan_list_str}    Replace String    ${vlan_list_str}    ,    _
    ${transport_prf}    set variable    ${cfg_prefix}_TransVlan_${vlan_list_str}
    : FOR    ${service_point}    IN    @{service_model.${service_point_list}}
    \    ${device}    set variable    ${service_model.${service_point}.device}
    \    log    ****** uplink service add vlan ${vlan_list} for ${device} ${service_point} ******
    \    log    create transport-service-profile
    \    prov_transport_service_profile    ${device}    ${transport_prf}    ${vlan_list}
    \    service_point_add_transport_profile    ${device}    ${service_point}    ${transport_prf}
    [Return]    ${transport_prf}
 
service_point_remove_vlan
    [Arguments]    ${service_point_list}    ${vlan_list}    ${cfg_prefix}=auto
    [Documentation]    Description: remove vlan for service_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_remove_vlan | service_point_list1 | 200 |
    [Tags]    @author=CindyGao
    ${vlan_list_str}    Convert To String    ${vlan_list}
    ${vlan_list_str}    Replace String    ${vlan_list_str}    ,    _
    ${transport_prf}    set variable    ${cfg_prefix}_TransVlan_${vlan_list_str}
    : FOR    ${service_point}    IN    @{service_model.${service_point_list}}
    \    ${device}    set variable    ${service_model.${service_point}.device}
    \    log    ****** uplink service remove vlan ${vlan_list} for ${device} ${service_point} ******
    \    service_point_remove_transport_profile    ${device}    ${service_point}    ${transport_prf}
    \    run keyword and ignore error    delete_config_object    ${device}    transport-service-profile    ${transport_prf}
    [Return]    ${transport_prf}

service_point_prov_igmp
    [Arguments]    ${service_point_list}    ${igmp_prf}    ${proxy_intf}    ${proxy_ip_list}    ${proxy_mask}    ${proxy_gw}    @{vlan_list}
    [Documentation]    Description: add igmp profile and proxy interface for service_point_list
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    ...    | igmp_prf | igmp-profile name |
    ...    | proxy_intf | restricted-ip-host name |
    ...    | proxy_ip_list | restricted-ip-host ip, must be set as list format |
    ...    | proxy_mask | restricted-ip-host mask |
    ...    | proxy_gw | restricted-ip-host gateway |
    ...    | vlan_list | vlan list to add igmp service, for single vlan input: ${vlan_id}, for vlan list input: @{vlan_list} |
    ...    Example:
    ...    | service_point_prov_igmp | service_point_list1 | igmp_prf | 1 | 7.7.7.7 | 255.255.255.0 | 7.7.7.1 | 100 |
    ...    | service_point_prov_igmp | service_point_list1 | igmp_prf | 1 | 7.7.7.7 | 255.255.255.0 | 7.7.7.1 | ${vlan_id} |
    ...    | service_point_prov_igmp | service_point_list1 | igmp_prf | 1 | 7.7.7.7 | 255.255.255.0 | 7.7.7.1 | @{vlan_list} |
    [Tags]    @author=CindyGao
    ${index}    set variable    0
    : FOR    ${service_point}    IN    @{service_model.${service_point_list}}
    \    ${device}    set variable    ${service_model.${service_point}.device}
    \    log    ******[${device}] service_point prov igmp profile ${igmp_prf} and proxy interface ${proxy_intf} for ${service_point}******
    \    log    create igmp profile
    \    igmp_prov_vlan_igmp_profile    ${device}    ${igmp_prf}    @{vlan_list}
    \    log    config igmp proxy interface
    \    igmp_prov_proxy    ${device}    ${proxy_intf}    @{proxy_ip_list}[${index}]    ${proxy_mask}    ${proxy_gw}    @{vlan_list}
    \    ${index}    evaluate    ${index}+1

service_point_dprov_igmp
    [Arguments]    ${service_point_list}    ${igmp_prf}    ${proxy_intf}    @{vlan_list}
    [Documentation]    Description: delete igmp profile and proxy interface for service_point_list
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point_list | service_point_list name in service_model.yaml |
    ...    | igmp_prf | igmp-profile name |
    ...    | proxy_intf | restricted-ip-host name |
    ...    | vlan_list | vlan list to add igmp service, for single vlan input: ${vlan_id}, for vlan list input: @{vlan_list} |
    ...    Example:
    ...    | service_point_dprov_igmp | service_point_list1 | igmp_prf | 1 | 100 |
    ...    | service_point_dprov_igmp | service_point_list1 | igmp_prf | 1 | ${vlan_id} |
    ...    | service_point_dprov_igmp | service_point_list1 | igmp_prf | 1 | @{vlan_list} |
    [Tags]    @author=CindyGao
    : FOR    ${service_point}    IN    @{service_model.${service_point_list}}
    \    ${device}    set variable    ${service_model.${service_point}.device}
    \    log    ******[${device}] service_point dprov igmp ${igmp_prf} and proxy interface ${proxy_intf} for ${service_point}******
    \    log    delete igmp proxy interface
    \    delete_config_object    ${device}    interface restricted-ip-host     ${proxy_intf}
    \    log    delete igmp profile
    \    igmp_dprov_vlan_igmp_profile    ${device}    ${igmp_prf}    @{vlan_list}

service_point_check_igmp_routers
    [Arguments]    ${service_point}    ${igmp_vlan}    ${source_ip}=.+    ${querier_ip}=.+    ${version}=V2    ${contain}=yes
    [Documentation]    Description: delete igmp profile and proxy interface for service_point_list
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point | service_point name in service_model.yaml |
    ...    | igmp_vlan | igmp vlan to check |
    ...    | source_ip | igmp router source ip address |
    ...    | querier_ip | igmp router querier ip address |
    ...    | version | igmp version, default=V2 |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    Example:
    ...    | service_point_check_igmp_routers | service_point1 | 100 | source_ip=${p_proxy_ip} | querier_ip=${p_igmp_querier_ip} |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${service_point}.device}
    log    ******[${device}] ${service_point} check igmp router vlan:${igmp_vlan} src_ip:${source_ip} querier_ip:${querier_ip} version:${version}******
    ${igmp_intf}    Set Variable If    "eth"=="${service_model.${service_point}.type}"    ${service_model.${service_point}.member.interface1}
    ...    ${service_model.${service_point}.name}
    &{dict_intf}    get_shelf_slot_interface_info    ${igmp_intf}    ${service_model.${service_point}.type}
    check_igmp_routers    ${device}    summary    ${igmp_vlan}    &{dict_intf}[port]    ${source_ip}    ${querier_ip}    ${version}    contain=${contain}

subscriber_point_check_igmp_multicast_group
    [Arguments]    ${subscriber_point}    ${igmp_vlan}    ${mc_group}    ${contain}=yes    ${summary}=yes
    [Documentation]    Description: show igmp multicast group summary and check
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | igmp_vlan | igmp vlan to check |
    ...    | mc_group | multicast group to check |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    | summary | [yes|no] default=yes, check show igmp multicast group summary; else check show igmp multicast group ip |
    ...    Example:
    ...    | subscriber_point_check_igmp_multicast_group | subscriber_point1 | 100 | 225.0.0.1 |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ******[${device}] ${subscriber_point} check igmp mc group: vlan:${igmp_vlan} group:${mc_group}******
    cli    ${device}    show igmp
    cli    ${device}    show igmp statistics vlan ${igmp_vlan}
    ${interface}    Set Variable If    "ont_port"=="${service_model.${subscriber_point}.type}"    @{service_model.${subscriber_point}.attribute.pon_port}[0]
    ...    ${service_model.${subscriber_point}.name}
    Run Keyword If    'yes'=='${summary}'    check_igmp_multicast_group_summary    ${device}    ${mc_group}    ${igmp_vlan}    ${interface}    contain=${contain}
    ...    ELSE    check_igmp_multicast_group_ip    ${device}    ${mc_group}    ${igmp_vlan}    ${interface}    contain=${contain}

subscriber_point_check_igmp_multicast_vlan
    [Arguments]    ${subscriber_point}    ${svlan}    ${contain}=yes    &{dict_group_vlan}
    [Documentation]    Description: show igmp multicast vlan ${svlan} and check
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | svlan | service vlan to check |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    | dict_group_vlan | dictionary type mc group and video vlan pair, format as mc_group=video_vlan |
    ...    Example:
    ...    | subscriber_point_check_igmp_multicast_vlan | subscriber_point1 | 100 | 225.0.0.1=700 |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ******[${device}] ${subscriber_point} check igmp mc vlan ${svlan}******
    cli    ${device}    show igmp
    cli    ${device}    show igmp statistics vlan ${svlan}
    &{dict_intf}    get_shelf_slot_interface_info    ${service_model.${subscriber_point}.name}    ${service_model.${subscriber_point}.attribute.interface_type}
    check_igmp_multicast_vlan    ${device}    ${svlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]    contain=${contain}    &{dict_group_vlan}

subscriber_point_check_igmp_multicast_summary
    [Arguments]    ${subscriber_point}    ${svlan}    ${mc_group}    ${mvr_vlan}=${EMPTY}    ${contain}=yes
    [Documentation]    Description: show igmp multicast vlan summary and check
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | svlan | service vlan to check |
    ...    | mc_group | multicast group |
    ...    | mvr_vlan | mvr vlan, default=${EMPTY} |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    Example:
    ...    | subscriber_point_check_igmp_multicast_vlan | subscriber_point1 | 100 | 225.0.0.1=700 |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ******[${device}] ${subscriber_point} check igmp mc vlan ${svlan}******
    cli    ${device}    show igmp
    cli    ${device}    show igmp statistics vlan ${svlan}
    Run Keyword If    '${mvr_vlan}'!='${EMPTY}'    cli    ${device}    show igmp statistics vlan ${mvr_vlan}
    ${video_vlan}    Set Variable If    '${mvr_vlan}'!='${EMPTY}'    ${mvr_vlan}    ${svlan}
    &{dict_intf}    get_shelf_slot_interface_info    ${service_model.${subscriber_point}.name}    ${service_model.${subscriber_point}.attribute.interface_type}
    check_igmp_multicast_sum    ${device}    ${svlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]
    ...    ${mc_group}    ${video_vlan}    contain=${contain}
    
    Return From Keyword If    '${mvr_vlan}'=='${EMPTY}' or 'yes'!='${contain}'
    log    check for mvr situation vlan ${mvr_vlan}
    ${pon_port}    Run Keyword If    "ont_port"=="${service_model.${subscriber_point}.type}"    subscriber_point_get_pon_port_name    ${subscriber_point}
    ...    ELSE    set variable    ${EMPTY}
    &{dict_intf}    Run Keyword If    "ont_port"=="${service_model.${subscriber_point}.type}"    get_shelf_slot_interface_info    ${pon_port}    pon
    ...    ELSE    Copy Dictionary    ${dict_intf}
    check_igmp_multicast_sum    ${device}    ${video_vlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]
    ...    ${mc_group}    ${video_vlan}    contain=${contain}

subscriber_point_check_igmp_hosts
    [Arguments]    ${subscriber_point}    ${svlan}    ${version}    ${src_ip}    ${mcast_prf}    ${mvr_vlan}=${EMPTY}    ${contain}=yes    ${data_vlan_src}=([0-9.]+)    ${data_vlan_ver}=v3
    [Documentation]    Description: show igmp hosts summary and check
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | svlan | service vlan to check |
    ...    | version | igmp version |
    ...    | src_ip | igmp router source ip address |
    ...    | mcast_prf | multicast profile |    
    ...    | mvr_vlan | mvr vlan, default=${EMPTY} |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    | data_vlan_src | igmp source ip for data vlan in mvr situatin, default=0.0.0.0 |
    ...    | data_vlan_ver | igmp version for data vlan in mvr situatin, default=v3 |
    ...    
    ...    Example:
    ...    | subscriber_point_check_igmp_hosts | subscriber_point1 | 100 | v2 | 10.10.10.1 |  |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ******[${device}] ${subscriber_point} check igmp hosts vlan:${svlan} version:${version} src_ip:${src_ip} mcast_prf:${mcast_prf}******
    cli    ${device}    show igmp
    cli    ${device}    show igmp statistics vlan ${svlan}
    Run Keyword If    '${mvr_vlan}'!='${EMPTY}'    cli    ${device}    show igmp statistics vlan ${mvr_vlan}
    ${svlan_src}    Set Variable If    '${mvr_vlan}'!='${EMPTY}'    ${data_vlan_src}    ${src_ip}
    ${svlan_ver}    Set Variable If    '${mvr_vlan}'!='${EMPTY}'    ${data_vlan_ver}    ${version}
    &{dict_intf}    get_shelf_slot_interface_info    ${service_model.${subscriber_point}.name}    ${service_model.${subscriber_point}.attribute.interface_type}
    check_igmp_hosts_summary    ${device}    ${svlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]    ${svlan_ver}
    ...    src_ip=${svlan_src}    mcast_prf=${mcast_prf}    mgmt_status=STATIC    contain=${contain}
    
    Return From Keyword If    '${mvr_vlan}'=='${EMPTY}' or 'yes'!='${contain}'
    log    check for mvr situation vlan ${mvr_vlan}
    ${video_vlan}    Set Variable If    '${mvr_vlan}'!='${EMPTY}'    ${mvr_vlan}    ${svlan}
    ${pon_port}    Run Keyword If    "ont_port"=="${service_model.${subscriber_point}.type}"    subscriber_point_get_pon_port_name    ${subscriber_point}
    ...    ELSE    set variable    ${EMPTY}
    &{dict_intf}    Run Keyword If    "ont_port"=="${service_model.${subscriber_point}.type}"    get_shelf_slot_interface_info    ${pon_port}    pon
    ...    ELSE    Copy Dictionary    ${dict_intf}
    check_igmp_hosts_summary    ${device}    ${video_vlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]    ${version}
    ...    src_ip=${src_ip}    mcast_prf=-    mgmt_status=STATIC    contain=${contain}

subscriber_point_check_igmp_ports
    [Arguments]    ${subscriber_point}    ${svlan}    ${version}    ${src_ip}    ${mcast_prf}    ${mvr_vlan}=${EMPTY}    ${contain}=yes    ${data_vlan_src}=([0-9.]+)    ${data_vlan_ver}=v3
    [Documentation]    Description: show igmp ports summary and check
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | svlan | service vlan to check |
    ...    | version | igmp version |
    ...    | src_ip | igmp router source ip address |
    ...    | mcast_prf | multicast profile |   
    ...    | mvr_vlan | mvr vlan, default=${EMPTY} |
    ...    | contain | [yes|no] check contain or not contain, default=yes |
    ...    | data_vlan_src | igmp source ip for data vlan in mvr situatin, default=0.0.0.0 |
    ...    | data_vlan_ver | igmp version for data vlan in mvr situatin, default=v3 |
    ...    
    ...    Example:
    ...    | subscriber_point_check_igmp_ports | subscriber_point1 | 100 | 225.0.0.1=700 |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ******[${device}] ${subscriber_point} check igmp ports vlan:${svlan} version:${version} src_ip:${src_ip} mcast_prf:${mcast_prf}******
    cli    ${device}    show igmp
    ${svlan_src}    Set Variable If    '${mvr_vlan}'!='${EMPTY}'    ${data_vlan_src}    ${src_ip}
    ${svlan_ver}    Set Variable If    '${mvr_vlan}'!='${EMPTY}'    ${data_vlan_ver}    ${version}
    &{dict_intf}    get_shelf_slot_interface_info    ${service_model.${subscriber_point}.name}    ${service_model.${subscriber_point}.attribute.interface_type}
    check_igmp_ports_summary    ${device}    ${svlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]    ${svlan_ver}
    ...    src_ip=${svlan_src}    mcast_prf=${mcast_prf}    mode=HOST    mgmt_status=STATIC    contain=${contain}
    
    Return From Keyword If    '${mvr_vlan}'=='${EMPTY}' or 'yes'!='${contain}'
    log    check for mvr situation vlan ${mvr_vlan}
    ${video_vlan}    Set Variable If    '${mvr_vlan}'!='${EMPTY}'    ${mvr_vlan}    ${svlan}
    ${pon_port}    Run Keyword If    "ont_port"=="${service_model.${subscriber_point}.type}"    subscriber_point_get_pon_port_name    ${subscriber_point}
    ...    ELSE    set variable    ${EMPTY}
    &{dict_intf}    Run Keyword If    "ont_port"=="${service_model.${subscriber_point}.type}"    get_shelf_slot_interface_info    ${pon_port}    pon
    ...    ELSE    Copy Dictionary    ${dict_intf}
    check_igmp_ports_summary    ${device}    ${video_vlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]    ${version}
    ...    src_ip=${src_ip}    mcast_prf=-    mode=HOST    mgmt_status=STATIC    contain=${contain}

subscriber_point_prov
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: provision for subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_prov | subscriber_point1 |
    [Tags]    @author=CindyGao
    log    ****** subscriber service provision for ${subscriber_point} ******
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    Run Keyword    subscriber_point_${service_model.${subscriber_point}.type}_prov    ${device}    ${subscriber_point}

subscriber_point_dprov
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: deprovision for subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_dprov | subscriber_point1 |
    [Tags]    @author=CindyGao
    log    ****** subscriber service deprovision for ${subscriber_point} ******
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    Run Keyword    subscriber_point_${service_model.${subscriber_point}.type}_dprov    ${device}    ${subscriber_point}

subscriber_point_add_svc
    [Arguments]    ${subscriber_point}    ${match_vlan}    ${svlan}    ${ctag_action}=${EMPTY}    ${cvlan}=${EMPTY}
    ...    ${cevlan_action}=${EMPTY}    ${cevlan}=${EMPTY}    ${mcast_profile}=${EMPTY}    ${cfg_prefix}=auto    &{dict_policy_map_option_cmd}
    [Documentation]    Description: create l2 basic class-map and policy-map, add service to subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | match_vlan | class-map match vlan, set to untagged for untagged |
    ...    | svlan | interface svlan |
    ...    | ctag_action | policy-map ctag action, {add-ctag} |
    ...    | cvlan | policy-map cvlan |
    ...    | cevlan_action | policy-map ctag action, {remove-cevlan|translate-cevlan-tag} |
    ...    | cevlan | policy-map cevlan, no need to set it when using remove-cevlan action |
    ...    | mcast_profile | multicast profile, no need to set it when only create l2 data service |
    ...    | cfg_prefix | string as configuration name prefix |
    ...    | dict_policy_map_option_cmd | dictionary format command for policy-map |
    ...
    ...    Return Value:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | dict_prf | dictionary format profile name, use &{dict_prf}[classmap] to get class-map name, use &{dict_prf}[policymap] to get policy-map name |
    ...
    ...    Example:
    ...    | subscriber_point_add_svc | subscriber_point1 | 100 | 300 | add-tag | 300 | remove-cevlan |
    ...    | subscriber_point_add_svc | subscriber_point1 | 100 | 300 | add-tag | 300 | translate-cevlan-tag | 200 | set-ctag-pcp=7 | set-cevlan-pcp=5 |
    ...    Example for video service
    ...    | subscriber_point_add_svc | subscriber_point1 | 100 | 300 | add-tag | 300 | mcast_profile=multicast_profile |
    ...    This is the example for how to use return value to add more rule on class-map and policy map:
    ...    | &{dict_prf} | subscriber_point_add_svc | subscriber_point1 | 100 | 300 | add-ctag | 300 | remove-cevlan |
    ...    | prov_class_map | eutA | &{dict_prf}[classmap] | ethernet | flow | 2 | 1 | vlan=1000 |
    ...    | prov_policy_map | eutA | &{dict_prf}[policymap] | class-map-ethernet | &{dict_prf}[classmap] | flow | 2 | translate-cevlan-tag=400 |

    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ****** [${device}] create and add l2 basic service to ${subscriber_point} ******
    ${port_type}    subscriber_point_get_port_type    ${subscriber_point}
    &{dict_prf}    l2_setting_prov_vlan_policy    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}    ${match_vlan}    ${svlan}
    ...    ${ctag_action}    ${cvlan}    ${cevlan_action}    ${cevlan}    ${mcast_profile}    ${cfg_prefix}    &{dict_policy_map_option_cmd}
    [Return]    &{dict_prf}

subscriber_point_remove_svc
    [Arguments]    ${subscriber_point}    ${match_vlan}    ${svlan}    ${cvlan}=${EMPTY}    ${cevlan}=${EMPTY}    ${mcast_profile}=${EMPTY}    ${cfg_prefix}=auto
    [Documentation]    Description: delete l2 basic class-map and policy-map, remove service from subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | match_vlan | class-map match vlan, set to untagged for untagged |
    ...    | svlan | interface svlan |
    ...    | cvlan | policy-map cvlan |
    ...    | cevlan | policy-map cevlan, no need to set it when using remove-cevlan action |
    ...    | cfg_prefix | string as configuration name prefix |
    ...
    ...    Example:
    ...    | subscriber_point_remove_svc | subscriber_point1 | 100 | 300 |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ****** [${device}] remove and delete l2 basic service from ${subscriber_point} ******
    ${port_type}    subscriber_point_get_port_type    ${subscriber_point}
    l2_setting_dprov_vlan_policy    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}
    ...    ${match_vlan}    ${svlan}    ${cvlan}    ${cevlan}    ${mcast_profile}    ${cfg_prefix}

subscriber_point_add_svc_user_defined
    [Arguments]    ${subscriber_point}    ${svlan}    ${policy_map}    ${mcast_profile}=${EMPTY}
    [Documentation]    Description: add user-defined policy-map and mcast_profile to subscriber_point 
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | svlan | interface svlan |
    ...    | policy_map | policy-map name, need to create it before |
    ...    | mcast_profile | multicast profile for video service |
    ...
    ...    Example:
    ...    | subscriber_point_add_svc_user_defined | subscriber_point1 | 100 | ${policy_map} |
    ...    | subscriber_point_add_svc_user_defined | subscriber_point1 | 100 | ${policy_map} | ${multicast_profile} |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ****** [${device}] add user-defined service to ${subscriber_point} ******
    ${port_type}    subscriber_point_get_port_type    ${subscriber_point}
    ${port_name}    set variable    ${service_model.${subscriber_point}.name}
    log    add policy-map to interface
    prov_interface    ${device}    ${port_type}    ${port_name}    ${svlan}    ${policy_map}
    
    log    add multicast-profile to interface
    run keyword if     "${mcast_profile}"!="${EMPTY}"    prov_interface    ${device}    ${port_type}    ${port_name}    ${svlan}    igmp multicast-profile=${mcast_profile}
    
    log    check eth-svc
    check_running_config_interface    ${device}    ${port_type}    ${port_name}    policy-map=${policy_map}
    run keyword if     "${mcast_profile}"!="${EMPTY}"    check_running_config_interface    ${device}    ${port_type}    ${port_name}    igmp multicast-profile=${mcast_profile}
    

subscriber_point_remove_svc_user_defined
    [Arguments]    ${subscriber_point}    ${svlan}    ${policy_map}    ${mcast_profile}=${EMPTY}
    [Documentation]    Description: remove user-defined policy-map and mcast_profile from subscriber_point 
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | svlan | interface svlan |
    ...    | policy_map | policy-map name, need to create it before |
    ...    | mcast_profile | multicast profile for video service |
    ...
    ...    Example:
    ...    | subscriber_point_remove_svc_user_defined | subscriber_point1 | 100 | ${policy_map} |
    ...    | subscriber_point_remove_svc_user_defined | subscriber_point1 | 100 | ${policy_map} | ${multicast_profile} |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ****** [${device}] remove user-defined service from ${subscriber_point} ******
    ${port_type}    subscriber_point_get_port_type    ${subscriber_point}
    log    remove multicast-profile from interface
    run keyword if    "${mcast_profile}"!="${EMPTY}"    dprov_interface    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}    ${svlan}    igmp multicast-profile=${EMPTY}
    log    remove policy-map from interface
    dprov_interface    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}    ${svlan}    policy-map=${policy_map}
    log    remove svlan from interface
    dprov_interface    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}    vlan=${svlan}

subscriber_point_check_status_up
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: check status for subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_check_status | subscriber_point1 |
    [Tags]    @author=CindyGao
    log    ******check subscriber status for ${subscriber_point}******
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    Run Keyword    subscriber_point_${service_model.${subscriber_point}.type}_check_status    ${device}    ${subscriber_point}    up

subscriber_point_shutdown
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: shutdown subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    |  |  |
    ...
    ...    Example:
    ...    | subscriber_point_shutdown | subscriber_point1 |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ******[${device}] shutdown ${subscriber_point}******
    ${port_type}    subscriber_point_get_port_type    ${subscriber_point}
    shutdown_port    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}

subscriber_point_no_shutdown
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: no shutdown subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_no_shutdown | subscriber_point1 |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${subscriber_point}.device}
    log    ******[${device}] no shutdown ${subscriber_point}******
    ${port_type}    subscriber_point_get_port_type    ${subscriber_point}
    no_shutdown_port    ${device}    ${port_type}    ${service_model.${subscriber_point}.name}

subscriber_point_get_port_type   
    [Arguments]    ${subscriber_point}
    [Documentation]    Description: get subscriber port type
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_get_port_type | eutA | subscriber_point1 |
    [Tags]    @author=CindyGao
    ${contain}    Run Keyword And Return Status    Dictionary Should Contain Key    ${service_model.${subscriber_point}.attribute}    interface_type
    Return From Keyword If    ${contain}    ${service_model.${subscriber_point}.attribute.interface_type}
    
    ${type}    set variable    ${service_model.${subscriber_point}.type}
    ${port_type}    set variable if    'eth'=='${type}' or 'dsl'=='${type}'    ethernet
    ...    'ont_port'=='${type}'    ont-ethernet
    [Return]    ${port_type} 

subscriber_point_get_pon_port_name
    [Arguments]    ${subscriber_point}    ${port_num}=1
    [Documentation]    Description: ont_port subscriber get pon port name
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | port_num | pon port number |
    ...    
    ...    Return Value:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | pon_port | pon port name |
    ...
    ...    Example:
    ...    1. get first gpon port name
    ...    | ${pon_port} | subscriber_point_get_pon_port_name | subscriber_point1 |
    ...    2. get second gpon port name
    ...    | ${pon_port} | subscriber_point_get_pon_port_name | subscriber_point1 | 2 |
    [Tags]    @author=CindyGao
    ${index}    evaluate    ${port_num}-1
    ${pon_port}    set variable    @{service_model.${subscriber_point}.attribute.pon_port}[${index}]
    [Return]    ${pon_port}

################################### below keyword are only internal use, CANNOT be used in TCs #####################################    
################################### service_point keyword #####################################
service_point_eth_prov
    [Arguments]    ${device}    ${service_point}
    [Documentation]    Description: provision for eth type service point (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point | service_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_eth_prov | eutA | service_point1 |
    [Tags]    @author=CindyGao
    log    ****** [${device}] ethernet port basic provision for ${service_point} ******
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** provision port ${port} role and parameter ******
    \    prov_interface_ethernet    ${device}    ${port}    ${service_model.${service_point}.attribute.interface_role}   ENABLED
    \    no_shutdown_port    ${device}    ethernet    ${port}
    # \    Wait Until Keyword Succeeds    1min    5sec    check_interface_up    ${device}    ethernet    ${port}

service_point_eth_dprov
    [Arguments]    ${device}    ${service_point}
    [Documentation]    Description: deprovision for eth type service point (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point | service_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_eth_dprov | eutA | service_point1 |
    [Tags]    @author=CindyGao
    log    ****** [${device}] ethernet port basic deprovision for ${service_point} ******
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** provision port ${port} role and parameter ******
    # [AT-4749] modified by cindy for switchport default value change to enable, start
    \    dprov_interface_ethernet    ${device}    ${port}    role
    # [AT-4749] modified by cindy for switchport default value change to enable, end
    \    shutdown_port    ${device}    ethernet    ${port}

service_point_eth_check
    [Arguments]    ${service_point}
    [Documentation]    Description: check eth port is up (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point | service_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_eth_check | eutA | service_point1 |
    [Tags]    @author=CindyGao
    ${device}    set variable    ${service_model.${service_point}.device}
    log    ****** [${device}] ethernet port basic provision for ${service_point} ******
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    Wait Until Keyword Succeeds    1min    5sec    check_interface_up    ${device}    ethernet    ${port}

service_point_lag_check
    [Arguments]    ${service_point}
    [Documentation]    Description: check lag is up for service_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point | service_point name in service_model.yaml |

    ...    Example:
    ...    | service_point_lag_check | service_point1 |
    [Tags]    @author=BlairWang
    ${device}    set variable    ${service_model.${service_point}.device}
    log    ******check lag up on service point******
    check_lag_up   ${device}    ${service_model.${service_point}.name}

service_point_lag_prov
    [Arguments]    ${device}    ${service_point}
    [Documentation]    Description: service point lag basic provision (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    |  service_point | service_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_lag_prov | eutA | service_point1 |
    [Tags]    @author=CindyGao
    ${lag}    set variable    ${service_model.${service_point}.name}
    log    ****** [${device}] lag basic provision for ${service_point} lag ${lag} ******
    log    create lag
    # [AT-4218] modify by Cindy, start
    prov_interface    ${device}    lag    ${lag}    switchport=ENABLED
    prov_interface    ${device}    lag    ${lag}    role=inni
    # [AT-4218] modify by Cindy, end
    no_shutdown_port    ${device}    lag    ${lag}
    
    log    set interface role and add lag group
    ${lag_cmd}    release_cmd_adapter    ${device}    ${prov_interface_ethernet_lag}
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** provision port ${port} to lag ${lag} ******
    \    prov_interface_ethernet    ${device}    ${port}    ${service_model.${service_point}.attribute.interface_role}   ENABLED    ${lag_cmd}=${lag}
    \    no_shutdown_port    ${device}    ethernet    ${port}

service_point_lag_dprov
    [Arguments]    ${device}    ${service_point}
    [Documentation]    Description: service point lag basic deprovision (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    |  service_point | service_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_lag_dprov | eutA | service_point1 |
    [Tags]    @author=CindyGao
    ${lag}    set variable    ${service_model.${service_point}.name}
    log    ****** [${device}] lag basic deprovision for ${service_point} lag ${lag} ******
    log    set interface role and remove lag group
    ${lag_cmd}    release_cmd_adapter    ${device}    ${prov_interface_ethernet_lag}
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** deprovision port ${port} from erps lag ${lag} ******
    \    # [AT-4749] modified by cindy for switchport default value change to enable, start
    \    dprov_interface_ethernet    ${device}    ${port}    ${lag_cmd}    role
    \    # [AT-4749] modified by cindy for switchport default value change to enable, end
    \    shutdown_port    ${device}    ethernet    ${port}

    log    delete lag
    # [EXA-27006] added by cindy, start
    dprov_interface    ${device}    lag    ${lag}    role=${EMPTY}
    #dprov_interface    ${device}    lag    ${lag}    switchport=${EMPTY}
    # [EXA-27006] added by cindy, end
    delete_config_object    ${device}    interface lag    ${lag}

service_point_erps_check
    [Arguments]    ${service_point}
    [Documentation]    Description: check erps ring is up for service_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point | service_point name in service_model.yaml |

    ...    Example:
    ...    | service_point_erps_check | service_point1 |
    [Tags]    @author=BlairWang
    ${device}    set variable    ${service_model.${service_point}.device}
    log    ******check erps ring up on service point******
    check_erps_ring_up    ${device}    ${service_model.${service_point}.name}
    
service_point_erps_prov
    [Arguments]    ${device}    ${service_point}
    [Documentation]    Description: service point erps basic provision (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    |  service_point | service_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_erps_prov | eutA | service_point1 |
    [Tags]    @author=CindyGao
    ${ring}    set variable    ${service_model.${service_point}.name}
    log    ****** [${device}] erps basic provision for ${service_point} ring ${ring} ******
    log    create erps ring
    prov_erps_ring    ${device}    ${ring}    ${service_model.${service_point}.attribute.erps_role}    ${service_model.${service_point}.attribute.control_vlan}    admin-state=enable

    log    set interface role and add erps ring
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** provision port ${port} to erps ring ${ring} ******
    \    prov_interface_ethernet    ${device}    ${port}    ${service_model.${service_point}.attribute.interface_role}   ENABLED
    \    prov_interface_ethernet    ${device}    ${port}    sub_view_type=erps-ring    sub_view_value=${ring}    role=${service_model.${service_point}.attribute.${port_key}_erps_role}
    \    no_shutdown_port    ${device}    ethernet    ${port}

service_point_erps_dprov
    [Arguments]    ${device}    ${service_point}
    [Documentation]    Description: service point erps basic deprovision (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    |  service_point | service_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_erps_dprov | eutA | service_point1 |
    [Tags]    @author=CindyGao
    ${ring}    set variable    ${service_model.${service_point}.name}
    log    ****** [${device}] erps basic deprovision for ${service_point} ring ${ring} ******
    log    set interface role and remove erps ring
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** deprovision port ${port} from erps ring ${ring} ******
    \    # [AT-4749] modified by cindy for switchport default value change to enable, start
    \    dprov_interface_ethernet    ${device}    ${port}    erps-ring    role
    \    # [AT-4749] modified by cindy for switchport default value change to enable, end
    \    shutdown_port    ${device}    ethernet    ${port}

    log    delete erps ring
    delete_config_object    ${device}    erps-ring    ${ring}

service_point_g8032_check
    [Arguments]    ${service_point}
    [Documentation]    Description: check erps ring is up for service_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point | service_point name in service_model.yaml |

    ...    Example:
    ...    | service_point_g8032_check | service_point1 |
    [Tags]    @author=BlairWang
    ${device}    set variable    ${service_model.${service_point}.device}
    ${ring_info}    set variable    ${service_model.${service_point}.attribute}
    log    ******[${device}]check g8032 ring up on ${service_point}******
    Run Keyword if    '${ring_info.interface1_rpl_mode}'=='owner' or '${ring_info.interface2_rpl_mode}'=='owner'
    ...    cli    ${device}    perform g8032 clear ring-instance-id ${service_model.${service_point}.name}
    check_g8032_ring_up    ${device}    ${service_model.${service_point}.name}
    
service_point_g8032_prov
    [Arguments]    ${device}    ${service_point}
    [Documentation]    Description: service point g8032 basic provision (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    |  service_point | service_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_g8032_prov | eutA | service_point1 |
    [Tags]    @author=CindyGao
    ${ring}    set variable    ${service_model.${service_point}.name}
    log    ****** [${device}] g8032 basic provision for ${service_point} ring ${ring} ******
    log    create g8032 ring
    prov_g8032_ring    ${device}    ${ring}    ${service_model.${service_point}.attribute.control_vlan}    enable

    log    set interface role and add g8032 ring
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** provision port ${port} to g8032 ring ${ring} ******
    \    prov_interface_ethernet    ${device}    ${port}    ${service_model.${service_point}.attribute.interface_role}   ENABLED
    \    prov_interface_ethernet    ${device}    ${port}    sub_view_type=g8032-ring    sub_view_value=${ring}    rpl-mode=${service_model.${service_point}.attribute.${port_key}_rpl_mode}
    \    no_shutdown_port    ${device}    ethernet    ${port}

service_point_g8032_dprov
    [Arguments]    ${device}    ${service_point}
    [Documentation]    Description: service point g8032 basic deprovision (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    |  service_point | service_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | service_point_g8032_dprov | eutA | service_point1 |
    [Tags]    @author=CindyGao
    ${ring}    set variable    ${service_model.${service_point}.name}
    log    ****** [${device}] g8032 basic provision for ${service_point} ring ${ring} ******
    log    set interface role and remove g8032 ring
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** deprovision port ${port} from g8032 ring ${ring} ******
    \    # [AT-4749] modified by cindy for switchport default value change to enable, start
    \    dprov_interface_ethernet    ${device}    ${port}    g8032-ring    role
    \    # [AT-4749] modified by cindy for switchport default value change to enable, end
    \    shutdown_port    ${device}    ethernet    ${port}

    log    delete g8032 ring
    # dprov_g8032_ring    ${device}    ${ring}    ${service_model.${service_point}.attribute.control_vlan}
    delete_config_object    ${device}    g8032-ring    ${ring}

service_point_add_transport_profile
    [Arguments]    ${device}    ${service_point}    ${transport_prf}
    [Documentation]    Description: add transport_profile to service_point interface (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point | service_point name in service_model.yaml |
    ...    | transport_prf | transport-service-profile name |
    ...
    ...    Example:
    ...    | service_point_add_transport_profile | eutA | service_point1 | trans_prf |
    [Tags]    @author=CindyGao
    # special operation for lag
    Run Keyword And Return If    'lag'=='${service_model.${service_point}.type}'
    ...    prov_interface    ${device}    lag    ${service_model.${service_point}.name}    transport-service-profile=${transport_prf}
    
    log    add transport-service-profile to interface
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** provision port ${port} transport-service-profile ******
    \    prov_interface_ethernet    ${device}    ${port}    transport-service-profile=${transport_prf}
    \    check_running_config_interface    ${device}    ethernet    ${port}    transport-service-profile=${transport_prf}

service_point_remove_transport_profile
    [Arguments]    ${device}    ${service_point}    ${transport_prf}
    [Documentation]    Description: remove transport_profile for service_point interface (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | service_point | service_point name in service_model.yaml |
    ...    | transport_prf | transport-service-profile name |
    ...
    ...    Example:
    ...    | service_point_remove_transport_profile | eutA | service_point1 | trans_prf |
    [Tags]    @author=CindyGao
    # special operation for lag
    Run Keyword And Return If    'lag'=='${service_model.${service_point}.type}'
    ...    dprov_interface    ${device}    lag    ${service_model.${service_point}.name}    transport-service-profile=${transport_prf}
    
    log    remove transport-service-profile from interface
    : FOR    ${port_key}    IN    @{service_model.${service_point}.member}
    \    ${port}    set variable    ${service_model.${service_point}.member.${port_key}}
    \    log    ****** deprovision port ${port} transport-service-profile******
    \    cli    ${device}    show running-config interface ethernet ${port}
    \    dprov_interface_ethernet    ${device}    ${port}    transport-service-profile

################################### subscriber_point keyword #####################################
subscriber_point_ont_port_prov
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]    Description: ont_port subscriber create (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_ont_port_prov | eutA | subscriber_point1 |
    [Tags]    @author=CindyGao
    log    ****** [${device}] ont port subscriber provision for ${subscriber_point} ******
    ${ont_info}    set variable    ${service_model.${subscriber_point}.attribute}
    
    # log    create ont-profile if not exist
    # gpon_prov_official_ont_profile    ${device}    ${ont_info.ont_profile_id}    
    
    log    enable pon port
    : FOR    ${port}    IN    @{ont_info.pon_port}
    \    no_shutdown_port    ${device}    pon    ${port}

    log    create ont
    prov_ont    ${device}    ${ont_info.ont_id}    ${ont_info.ont_profile_id}    ${ont_info.vendor_id}    ${ont_info.serial_number}
    
    log    provision ont-interface role
    Return From Keyword If    '${EMPTY}'=='${ont_info.interface_role}'
    : FOR    ${port_key}    IN    @{service_model.${subscriber_point}.member}
    \    ${port}    set variable    ${service_model.${subscriber_point}.member.${port_key}}
    \    prov_interface    ${device}    ont-ethernet    ${port}    role=${ont_info.interface_role}

subscriber_point_ont_port_dprov
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]    Description: ont_port subscriber delete (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_ont_port_dprov | eutA | subscriber_point1 |
    [Tags]    @author=CindyGao
    log    ****** [${device}] ont port subscriber deprovision for ${subscriber_point} ******
    ${ont_info}    set variable    ${service_model.${subscriber_point}.attribute}
    log    delete ont
    # dprov_ont    ${device}    ${ont_info.ont_id}
    delete_config_object    ${device}    ont    ${ont_info.ont_id}
    
    # log    delete ont-profile
    # # Run Keyword And Ignore Error    delete_config_object    ${device}    ont-profile    ${ont_info.ont_profile_id}
    # gpon_dprov_official_ont_profile    ${device}    ${ont_info.ont_profile_id}

    log    disable pon port
    : FOR    ${port}    IN    @{ont_info.pon_port}
    \    shutdown_port    ${device}    pon    ${port}

subscriber_point_ont_port_check_status
    [Arguments]    ${device}    ${subscriber_point}    ${status}=up
    [Documentation]    Description: ont_port subscriber check status up (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_ont_port_check_status | eutA | subscriber_point1 | up |
    [Tags]    @author=CindyGao
    log    ******[${device}] check ont port subscriber for ${subscriber_point} status is ${status}******
    ${ont_info}    set variable    ${service_model.${subscriber_point}.attribute}
    Wait Until Keyword Succeeds    1min    5sec    check_ont_status    ${device}    ${ont_info.ont_id}    oper-state=present 

subscriber_point_eth_prov
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]    Description: ethernet port subscriber provision (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_eth_prov | eutA | subscriber_point1 |
    [Tags]    @author=CindyGao
    log    ****** [${device}] ethernet port subscriber provision for ${subscriber_point} ******
    : FOR    ${port_key}    IN    @{service_model.${subscriber_point}.member}
    \    ${port}    set variable    ${service_model.${subscriber_point}.member.${port_key}}
    \    log    ****** provision port ${port} role and parameter ******
    \    prov_interface_ethernet    ${device}    ${port}    ${service_model.${subscriber_point}.attribute.interface_role}   ENABLED
    \    no_shutdown_port    ${device}    ethernet    ${port}

subscriber_point_eth_dprov
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]    Description: ethernet port subscriber deprovision (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_eth_dprov | eutA | subscriber_point1 |
    [Tags]    @author=CindyGao
    log    ****** [${device}] ethernet port subscriber deprovision for ${subscriber_point} ******
    : FOR    ${port_key}    IN    @{service_model.${subscriber_point}.member}
    \    ${port}    set variable    ${service_model.${subscriber_point}.member.${port_key}}
    \    log    ****** provision port ${port} role and parameter ******
    \    # [AT-4749] modified by cindy for switchport default value change to enable, start
    \    dprov_interface_ethernet    ${device}    ${port}    role    
    \    # [AT-4749] modified by cindy for switchport default value change to enable, end
    \    shutdown_port    ${device}    ethernet    ${port}

subscriber_point_eth_check_status
    [Arguments]    ${device}    ${subscriber_point}    ${status}=up
    [Documentation]    Description: eth subscriber check status up (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_eth_check_status | eutA | subscriber_point1 | up |
    [Tags]    @author=CindyGao
    log    ******[${device}] check eth subscriber for ${subscriber_point} status is ${status}******
    : FOR    ${port_key}    IN    @{service_model.${subscriber_point}.member}
    \    ${port}    set variable    ${service_model.${subscriber_point}.member.${port_key}}
    \    log    ****** check port ${port} status ******
    \    Wait Until Keyword Succeeds    1min    5sec    check_interface_up    ${device}    ethernet    ${port}

subscriber_point_dsl_prov
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]    Description: dsl subscriber create (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_dsl_prov | eutA | subscriber_point1 |
    [Tags]    @author=CindyGao
    ${port}    set variable    ${service_model.${subscriber_point}.name}
    log    ******[${device}] dsl subscriber provision for ${subscriber_point} port ${port} attribute setting******
    log    ****** provision port ${port} role and parameter ******
    prov_interface_ethernet    ${device}    ${port}    ${service_model.${subscriber_point}.attribute.interface_role}   ENABLED
    no_shutdown_port    ${device}    ethernet    ${port}
    no_shutdown_port    ${device}    line    ${service_model.${subscriber_point}.attribute.interface_line}

subscriber_point_dsl_dprov
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]    Description: ont_port subscriber delete (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_dsl_dprov | eutA | subscriber_point1 |
    [Tags]    @author=CindyGao
    ${port}    set variable    ${service_model.${subscriber_point}.name}
    log    ******[${device}] dsl subscriber deprovision for ${subscriber_point} port ${port} attribute unsetting******
    log    ****** provision port ${port} role and parameter ******
    # [AT-4749] modified by cindy for switchport default value change to enable, start
    dprov_interface_ethernet    ${device}    ${port}    role    
    # [AT-4749] modified by cindy for switchport default value change to enable, end
    shutdown_port    ${device}    ethernet    ${port}

subscriber_point_dsl_check_status
    [Arguments]    ${device}    ${subscriber_point}    ${status}=up
    [Documentation]    Description: dsl subscriber check status up (This keyword is only internal use, CANNOT be used in TCs)
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...
    ...    Example:
    ...    | subscriber_point_dsl_check_status | eutA | subscriber_point1 | up |
    [Tags]    @author=CindyGao
    ${port}    set variable    ${service_model.${subscriber_point}.name}
    log    ******[${device}] check dsl subscriber for ${subscriber_point} port ${port} status is ${status}******
    Wait Until Keyword Succeeds    5min    5sec    check_interface_up    ${device}    ethernet    ${port}
    Wait Until Keyword Succeeds    5min    5sec    check_interface    ${device}    ethernet    ${port}    status    fwd-state    forwarding
    Wait Until Keyword Succeeds    5min    5sec    check_interface_up    ${device}    line    ${service_model.${subscriber_point}.attribute.interface_line}
    


