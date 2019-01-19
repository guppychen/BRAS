*** Settings ***
Documentation    test_suite keyword lib
    
*** Keywords ***
check_vca_rx_packets
    [Arguments]    ${device}    ${pkts_num}=${EMPTY}    ${contain}=yes    &{dict_check_item}
    [Documentation]    Description: show vca and check rx_packets
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | pkts_num | rx-packets number |
    ...    | if pkts_num is EMPTY, check rx-packets bigger than 0, if none, rx-packets is 0 |
    ...    
    ...    Example:
    ...    | check_vca_rx_packets | eutA | 
    ...    | check_vca_rx_packets | eutA | none | rx-packets=0 |
    ...    | check_vca_rx_packets | eutA | multicast-group=225.1.1.2 |
    [Tags]    @author=YUE SUN
    ${res}    cli    ${device}    show vca
    ${match}    ${rx_pkts}    should Match Regexp    ${res}    rx-packets\\s+(\\d+)
    run keyword if    '${EMPTY}'=='${pkts_num}'    should be true    ${rx_pkts}>0
    @{list_key}    Get Dictionary Keys    ${dict_check_item}
    : FOR    ${check_item}   IN    @{list_key}
    \    ${exp_value}    Get From Dictionary    ${dict_check_item}   ${check_item}
    \    ${pattern}    set variable    (?i)${check_item}\\s+${exp_value}
    \    Run Keyword If    "yes"=="${contain}"    Should Match Regexp    ${res}    ${pattern}
    \    ...    ELSE    Should Not Match Regexp    ${res}    ${pattern}
    [Return]    ${res}

check_rx_mcast_packets
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${exp_pkt}=0
    [Documentation]    Description: show vca and check rx_packets
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | port type |
    ...    | port_id | port id |
    ...    | exp_pkt | expect rx-multicast-pkts value |
    ...    
    ...    Example:
    ...    | check_rx_mcast_packets | eutA | ethernet | 1/1/x5 |
    [Tags]    @author=YUE SUN
    ${res}    cli    ${device}    show interface ${port_type} ${port_name} counters
    ${match}    ${rx_pkts}    should Match Regexp    ${res}    rx-multicast-pkts\\s+(\\d+)
    should be true    ${rx_pkts}>${exp_pkt}
    [Return]    ${res}
    