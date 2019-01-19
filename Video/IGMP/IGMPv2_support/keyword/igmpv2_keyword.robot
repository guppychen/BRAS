*** Settings ***
Documentation    test_suite keyword lib

*** Variable ***


*** Keywords ***

get_igmp_statistics
    [Arguments]    ${device}    ${type}=summary    ${vlan_id}=${EMPTY}    ${option}=${EMPTY}
    [Documentation]    Description: check the stats
    ...    rx-unknown-if                        0
    ...    rx-pkts                              0
    ...    rx-reports                           0
    ...    rx-leaves                            0
    ...    rx-general-queries                   0
    ...    rx-group-queries                     0
    ...    rx-unknown-msg-types                 0
    ...    rx-crc-errors                        0
    ...    rx-protocol-errors                   0
    ...    rx-querier-mismatch                  0
    ...    rx-originated                        0
    ...    rx-s-g-ignore                        0
    ...    rx-discards                          0
    ...    rx-v1-report-drops                   0
    ...    filtered-src-ips                     0
    ...    filtered-groups                      0
    ...    no-mvr-vlan                          0
    ...    tx-reports                           0
    ...    tx-leaves                            0
    ...    tx-general-queries                   0
    ...    tx-v2-general-queries-for-v3-reports 0
    ...    tx-group-queries                     0
    ...    suppressed-reports                   0
    ...    max-streams-exceeded                 0
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | type | summary or vlan |
    ...    | vlan_id | vlan id |
    ...    | option | other option to show the igmp stats |
    ...    Example:
    ...    | get_igmp_statistics | eutA | vlan_id=100 |
    ...    | get_igmp_statistics | eutA | vlan | vlan_id=100 |
    [Tags]    @author=AnsonZhang
    ${res}    run keyword if    'summary'=='${type}'    cli    ${device}    show igmp statistics summary
    ...    ELSE IF    'vlan'=='${type}'    cli    ${device}    show igmp statistics vlan ${vlan_id}
    ${g_list}    should match Regexp    ${res}    ${option}\\s+(\\d+)
    ${option_count}    get from list    ${g_list}    1
    log    ${option_count}
    ${cnt}    convert to integer    ${option_count}
    return from keyword    ${cnt}

get_group_count
    [Arguments]    ${device}    ${vlan_id}=${EMPTY}
    [Documentation]    Description: get the group count
    ${res}    CLI    ${device}    show igmp multicast group summary
    # AT-4724 modify by llin for dual card
    ${g_list}    run keyword if    "${vlan_id}"=="${EMPTY}"    Get Regexp Matches    ${res}    (\\d+\\.\\d+\\.\\d+\\.\\d+\\s+\\d+\\s+.*)
    ...    ELSE    Get Regexp Matches    ${res}    (\\d+\\.\\d+\\.\\d+\\.\\d+\\s+${vlan_id}\\s+.*)
    # AT-4724 modify by llin for dual card
    ${group_count}    Get Length    ${g_list}
    return from keyword    ${group_count}

check current groups
    [Arguments]    ${device}    ${group_num}
    [Documentation]    Description: check the groups number
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | group_num | expected number |
    ...    Example:
    ...    | check current groups | eutA | 3 |
    ${num}    get_group_count    eutA
    Should Be True    ${num}==${group_num}