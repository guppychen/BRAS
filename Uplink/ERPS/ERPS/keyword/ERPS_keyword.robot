*** Settings ***
Documentation    test_suite keyword lib

*** Variable ***

*** Keywords ***

check_erps_ring_lccm
    [Arguments]    ${device}    ${erps-ring}   ${interface-role}    &{dict_check}
    [Documentation]   check erps ring lccm
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | dict_check | input dictionary |
    ...
    ...    Example:
    ...    | check_erps_ring_lccm | AXOS | 1 | primary-interface | lccm-rx |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show erps-ring ${erps-ring} lccm ${interface-role}
    @{check_name}    Get Dictionary Keys    ${dict_check}
    : FOR    ${key}   IN    @{check_name}
    \    ${res1}     Get Lines Containing String    ${res}    ${key}
    \    ${check_value}    Get From Dictionary    ${dict_check}   ${key}
    \    should contain    ${res1}    ${check_value}

check_erps_counters_equal_0
    [Arguments]    ${device}    ${erps-ring}   @{list_check}
    [Documentation]   Get erps ring counters value
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | dict_check | input dictionary |
    ...
    ...    Example:
    ...    | get_erps_counters_value | AXOS | 1 | ring-port-up |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show erps-ring ${erps-ring} counters
    : FOR     ${key}    IN    @{list_check}
    \    ${match}    ${num}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    should be equal    ${num}    0

check_erps_counters_increase
    [Arguments]    ${device}    ${erps-ring}   @{list_check}
    [Documentation]   Get erps ring counters value
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | dict_check | input dictionary |
    ...
    ...    Example:
    ...    | get_erps_counters_value | AXOS | 1 | ring-port-up |
    [Tags]    @author=BlairWang
    : FOR     ${key}    IN    @{list_check}
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} counters
    \    ${match}    ${num}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    log     sleep 10s to wait value increase
    \    sleep    10s
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} counters
    \    ${match_1}    ${num_1}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    should be true     ${num_1}>${num}


check_erps_ring_lccm_increase
    [Arguments]    ${device}    ${erps-ring}   ${interface-role}    @{list_check}
    [Documentation]   check erps ring lccm
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | dict_check | input dictionary |
    ...
    ...    Example:
    ...    | check_erps_ring_lccm | AXOS | 1 | primary-interface | lccm-rx |
    [Tags]    @author=BlairWang

    : FOR    ${key}   IN    @{list_check}
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} lccm ${interface-role}
    \    ${match}    ${num}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    log    check lccm value per second three times
    \    sleep    1s
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} lccm ${interface-role}
    \    ${match_1}    ${num_1}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    should be true     ${num_1}>${num}
    \    sleep    1s
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} lccm ${interface-role}
    \    ${match_2}    ${num_2}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    should be true     ${num_2}>${num_1}
    \    sleep    1s
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} lccm ${interface-role}
    \    ${match_3}    ${num_3}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    should be true     ${num_3}>${num_2}

check_erps_ring_lccm_not_change
    [Arguments]    ${device}    ${erps-ring}   ${interface-role}    @{list_check}
    [Documentation]   check erps ring lccm
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | dict_check | input dictionary |
    ...
    ...    Example:
    ...    | check_erps_ring_lccm | AXOS | 1 | primary-interface | lccm-rx |
    [Tags]    @author=BlairWang

    : FOR    ${key}   IN    @{list_check}
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} lccm ${interface-role}
    \    ${match}    ${num}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    log    check lccm value per second three times
    \    sleep    1s
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} lccm ${interface-role}
    \    ${match_1}    ${num_1}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    should be equal as integers     ${num_1}    ${num}
    \    sleep    1s
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} lccm ${interface-role}
    \    ${match_2}    ${num_2}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    should be equal as integers     ${num_2}    ${num_1}
    \    sleep    1s
    \    ${res}    cli    ${device}    show erps-ring ${erps-ring} lccm ${interface-role}
    \    ${match_3}    ${num_3}    should match regexp    ${res}    ${key}\\s+(\\d+)
    \    should be equal as integers     ${num_3}    ${num_2}

check_erps_ring_status
    [Arguments]    ${device}    ${erps-ring}   &{dict_check}
    [Documentation]   check erps ring status
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | dict_check | input dictionary |
    ...
    ...    Example:
    ...    | check_erps_ring_status | AXOS | 1 | configuration-state=resolved | configured-role=master | acting-role=master | primary-interface=1/1/x3 |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show erps-ring ${erps-ring} status
    @{check_name}    Get Dictionary Keys    ${dict_check}
    : FOR    ${key}   IN    @{check_name}
    \    ${res1}     Get Lines Containing String    ${res}    ${key}
    \    ${check_value}    Get From Dictionary    ${dict_check}   ${key}
    \    should contain    ${res1}    ${check_value}


get_hostname
    [Arguments]    ${device}
    [Documentation]   get hostname
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...
    ...    Example:
    ...    | get_hostname | AXOS |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show running-config hostname
    ${result}    Get Regexp Matches    ${res}     \\nhostname\\s+(\\S+)    1
    ${hostname}    set variable    ${result[0]}
    [Return]     ${hostname}

get_baseboard_mac
    [Arguments]    ${device}
    [Documentation]   get baseboard mac
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...
    ...    Example:
    ...    | get_chassis_mac | AXOS |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show inventory baseboard
    ${result}    Get Regexp Matches    ${res}    mac\\s+(\\w+:\\w+:\\w+:\\w+:\\w+:\\w+)    1
    ${mac}    set variable    ${result[0]}
    [Return]    ${mac}


check_environment_input_alarm_name
    [Arguments]    ${device}     @{list_check}
    [Documentation]    show bridge table
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | alarm_name | mac address |
    ...    Example:
    ...    | check_bridge_table | n1 | 00:02:5d:fc:fa:2e | 1/1/x2 | 11 | DYNAMIC |
    [Tags]    @author=BlairWang
    ${result}    CLI    ${device}    show alarm active | include environment-input
    :FOR    ${alarm}    IN     @{list_check}
    \     should contain    ${result}    ${alarm}

Get_erps_neighbor_hostname_port
    [Arguments]    ${device}    ${erps-ring}    ${port}
    [Documentation]    show bridge table
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...
    ...    Example:
    ...    | get_hostname | AXOS |
    [Tags]    @author=BlairWang
    ${res}    cli    ${device}    show erps-ring ${erps-ring} topology ring-node 1
    ${result}    Get Regexp Matches    ${res}     ${port}\\s+(\\S+)\\s+(\\d/\\d/\\w+)\\s+(\\w+)\\s+    1    2    3
    ${res_1}    set variable    ${result[0]}
    ${neighbor_hostname}    set variable    ${res_1[0]}
    ${neighbor_port}    set variable    ${res_1[1]}
    ${neighbor_port_state}    set variable    ${res_1[2]}
    [Return]     ${neighbor_hostname}    ${neighbor_port}    ${neighbor_port_state}

get_erps_last_protocol_state
    [Arguments]    ${device}    ${erps-ring}
    [Documentation]   get last topologe change time on erps-ring status
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...
    ...    Example:
    ...    | get_erps_last_topo_change_time | AXOS | 1 |
    [Tags]    @author=BlairWang
    ${time}    get_erps_last_topo_change_time    ${device}    ${erps-ring}
    ${res}    cli    ${device}    show erps-ring ${erps-ring} history
    ${result}    Get Regexp Matches    ${res}     \\d+\\s+(\\S+)\\s+${time}    1
    ${state}    set variable    ${result[0]}
    [Return]    ${state}


