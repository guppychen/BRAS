*** Settings ***
Documentation    test_suite keyword lib
Resource         ../base.robot

*** Variable ***


*** Keywords ***
check_igmp_multicast_summary
    [Arguments]    ${device}        ${data_vlan}        ${interface}        ${group}        ${video_vlan}
    [Documentation]    show igmp multicast summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | group | group ip address |
    ...    | data_vlan | data vlan |
    ...    | interface | port id |
    ...    | video_vlan| MVR vlan |
    ...    Example:
    ...    | check_igmp_multicast_group_summary | n1 | 225.0.0.1 | 100 | 1/1/xp2 |
    ...    | check_igmp_multicast_group_summary | n1 | 225.0.0.1 | 100 |
    ...    | check_igmp_multicast_group_summary | n1 | 225.0.0.1 |
    [Tags]    @author=Philip_Chen
    ${result}    CLI    ${device}    show igmp multicast summary
    should match regexp    ${result}    (${data_vlan})?\\s+[\\d\\s]?\\s+\\d\\s+\\d\\s+${interface}.*\\s+${group}\\s+${video_vlan}

check_igmp_multicast_summary_not_contain
    [Arguments]    ${device}        ${data_vlan}        ${interface}        ${group}        ${video_vlan}
    [Documentation]    show igmp multicast summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | group | group ip address |
    ...    | data_vlan | data vlan |
    ...    | interface | port id |
    ...    | video_vlan| MVR vlan |
    ...    Example:
    ...    | check_igmp_multicast_group_summary | n1 | 225.0.0.1 | 100 | 1/1/xp2 |
    ...    | check_igmp_multicast_group_summary | n1 | 225.0.0.1 | 100 |
    ...    | check_igmp_multicast_group_summary | n1 | 225.0.0.1 |
    [Tags]    @author=Philip_Chen
    ${result}    CLI    ${device}    show igmp multicast summary
    should not match regexp    ${result}    (${data_vlan})?\\s+[\\d\\s]?\\s+\\d\\s+\\d\\s+${interface}.*\\s+${group}\\s+${video_vlan}


check_igmp_host_summary
    [Arguments]    ${device}        ${video_vlan}        ${subscriber_port}        ${version}        ${proxy_ip}
    [Documentation]    show igmp host summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | group | group ip address |
    ...    | data_vlan | data vlan |
    ...    | interface | port id |
    ...    | video_vlan| MVR vlan |
    ...    Example:
    ...    | check_igmp_multicast_group_summary | n1 | 225.0.0.1 | 100 | 1/1/xp2 |
    ...    | check_igmp_multicast_group_summary | n1 | 225.0.0.1 | 100 |
    ...    | check_igmp_multicast_group_summary | n1 | 225.0.0.1 |
    [Tags]    @author=Philip_Chen
    # ${pon_port}    subscriber_point_get_pon_port_name    ${subscriber_port}
    # @{shelf}    get regexp matches    ${pon_port}    (\\d)\\/1    1
    # @{slot}    get regexp matches    ${pon_port}    \\/(\\d)\\/    1
    # @{interface}    get regexp matches    ${pon_port}    \\d\\/\\d\\/(\\w{2}\\d)    1
    # ${result}    CLI    ${device}    show igmp host summary
    # should match regexp    ${result}    (${video_vlan})?\\s+@{shelf}[0]\\s+@{slot}[0]\\s+@{interface}[0]\\s+STATIC\\s+${version}\\s+\\w\\s+-\\s+${proxy_ip}
    subscriber_point_check_igmp_hosts    ${subscriber_port}    ${p_data_vlan}    ${version}    ${proxy_ip}    .*    ${video_vlan}
    

check_igmp_routers_sumarry_not_contain
    [Arguments]    ${device}        ${video_vlan}        ${router_interface}        ${version}        ${proxy_ip}        ${query_ip}
    [Documentation]    show igmp host summary
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    [Tags]    @author=Philip_Chen
    ${result}    CLI    ${device}    show igmp routers summary
    @{shelf}    get regexp matches    ${router_interface}    (\\d)\\/1    1
    @{slot}    get regexp matches    ${router_interface}    \\/(\\d)\\/    1
    @{interface}    get regexp matches    ${router_interface}    \\d\\/\\d\\/(\\w\\d)    1
    should not match regexp    ${result}    ${video_vlan}\\s+@{shelf}[0]\\s+@{slot}[0]\\s+@{interface}[0]\\s+LEARNED\\s+${version}\\s+${proxy_ip}\\s+${query_ip}\\s+UP

clear_igmp_statistics_vlan
    [Arguments]    ${device}        ${video_vlan}
    [Documentation]    clear igmp statistics vlan vlan-id xxx
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | video_vlan | MVR vlan |
    [Tags]    @author=Philip_Chen
    ${result}    CLI    ${device}    clear igmp statistics vlan vlan-id ${video_vlan}

show_igmp_statistics_vlan
    [Arguments]    ${device}        ${video_vlan}
    [Documentation]    show igmp statistics vlan xxx
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | video_vlan | MVR vlan |
    [Tags]    @author=Philip_Chen
    ${result}    CLI    ${device}    show igmp statistics vlan ${video_vlan}
    [Return]    ${result}

analyze_packet_count_equal
    [Arguments]    ${save_file}    ${filter}    ${value}=0
    [Documentation]    Description: analyze filter packet count ==${value}
    ...    If use this keyword ,must use keyword "start_capture" before start traffic and "stop_capture" after stop traffic,
    ...    and save packet by use "Tg Store Captured Packets" to save packet.
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | save_file | tg store file path and name |
    ...    | filter | wireshark filter |
    ...    | value | expect packet number greater than this value |
    ...
    ...    Example:
    ...    | analyze_packet_count_greater_than | tg1 | eth.src==00:00:01:00:00:01 and eth.dst==00:00:02:00:00:02 | ${file_name} |
    ...    | analyze_packet_count_greater_than | tg1 | ip.src==10.10.10.1 and eth.dst==10.10.10.2 | ${file_name} |
    ...    | analyze_packet_count_greater_than | tg1 | bootp.type == 2 | ${file_name} | 10 |
    [Tags]    @author=philip_chen
    Wsk Load File    ${save_file}    ${filter}
    ${cnt}    wsk_get_total_packet_count
    Should Be True    ${cnt}==${value}
    [Return]    ${cnt}

add_new_range_to_mvr_profile
    [Arguments]    ${device}        ${profile_name}        ${start_ip}        ${end_ip}        ${mvr_vlan}
    [Documentation]    add new mcast range to mvr profile
    [Tags]    @author=Philip_Chen
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli    ${device}    end