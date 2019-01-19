*** Settings ***
Resource    ../base.robot


*** Keywords ***
prov_pon_pm
    [Arguments]    ${device}    ${pon_port}    ${rmon_session}    ${bin_count}     ${admin_state}=${EMPTY}    ${session_name}=${EMPTY}    ${bin_gos}=${EMPTY}    ${inter_gos}=${EMPTY}
    [Documentation]
    ...    
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | pon_port | Pon port ID|
    ...    | rmon_session | Interval of rmon_session |
    ...    | bin_count | Max provisioned bin count for rmon_session |
    ...    | admin_state | admin state for rmon_session |
    ...    | session_name | Name of PM session |
    ...    | bin_gos | bin gos state for PM session | 
    ...    | inter_gos | interval gos state for PM session |
    ...
    ...    Example:
    ...    | prov_pon_pm | eutA | 1/1/xp1 | fifteen-minutes | 1440 | admin_state=enable | session_name=test |

    [Tags]    @author=JerryWu
    log    provision a pon pm session
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    interface pon ${pon_port}
    ${bin_cnt_str}    release_cmd_adapter    ${device}    ${prov_interface_pon_config_rmon_session_bin_count}    ${bin_count}
    Axos Cli With Error Check    ${device}    rmon-session ${rmon_session} ${bin_cnt_str}
    run keyword if    "${admin_state}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    admin-state ${admin_state}
    run keyword if    "${session_name}"!="${EMPTY}"    Axos Cli With Error Check    ${device}    session-name ${session_name}
    run keyword if    '${bin_gos}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    bin-gos    ${bin_gos}
    run keyword if    '${inter_gos}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    interval-gos    ${inter_gos}   
    [Teardown]    Axos Cli With Error Check    ${device}    end
 
dprov_pon_pm

    [Arguments]    ${device}    ${pon_port}    ${rmon_session}    ${bin_count}     ${admin_state}=${EMPTY}    ${session_name}=${EMPTY}    ${bin_gos}=${EMPTY}    ${inter_gos}=${EMPTY}
    [Documentation]    deprovision pon pm
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | pon_port | Pon port ID|
    ...    | rmon_session | Interval of rmon_session |
    ...    | bin_count | Max provisioned bin count for rmon_session |
    ...    | admin_state | admin state for rmon_session |
    ...    | session_name | Name of PM session |
    ...    | bin_gos | bin gos state for PM session | 
    ...    | inter_gos | interval gos state for PM session |
    ...
    ...    Example:
    ...    | deprov_pon_pm | eutA | 1/1/xp1 | fifteen-minutes | 1440 |

    [Tags]    @author=JerryWu
    log    deprovision a pon pm session
    Axos Cli With Error Check    ${device}    configure
    Axos Cli With Error Check    ${device}    interface pon ${pon_port}
    ${bin_cnt_str}    release_cmd_adapter    ${device}    ${prov_interface_pon_rmon_session_bin_duration_view}
    Run Keyword If      "bin-count"=="${bin_cnt_str}"    Axos Cli With Error Check    ${device}    no rmon-session ${rmon_session} ${bin_count}
    ...    ELSE    Axos Cli With Error Check    ${device}    no rmon-session ${rmon_session}
    [Teardown]    Axos Cli With Error Check    ${device}    end
   
get_pon_pm_counter
    [Arguments]    ${device}    ${pon_port}    ${rmon_session}    ${rmon_type}    ${num_back}    ${num_show}    ${pon_pm_counter_name}
    [Documentation]    show pon pm by a specific field. This field can be a counter or an opiton.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | pon_port | Pon port ID|
    ...    | rmon_session | Interval of rmon_session |
    ...    | rmon_type | rmon type, indicate as bin or interval |
    ...    | num_back | num_back value |
    ...    | num_show | how many bins to retrieve |
    ...    | pon_pm_counter_name | the counter you want to retrieve |
    
    ...    Example:
    ...    | get_pon_pm_counter | eutA | 1/1/xp1 | fifeen-minutes | bin | 0 | 1 | rx-errors |
    [Tags]    @author=JerryWu
    log    show pon pm results
    ${res}    Cli    ${device}    show interface pon ${pon_port} performance-monitoring rmon-session bin-duration ${rmon_session} bin-or-interval ${rmon_type} num-back ${num_back} num-show ${num_show}
    log    The PM result is ${res}
    ${pon_pm_counter_value}     Should Match Regexp    ${res}     ${pon_pm_counter_name}\\s+(\\d+)\\r\\n
    log    the counter value is ${pon_pm_counter_value}
    [return]    ${pon_pm_counter_value}
    
clear_pon_pm
    [Arguments]    ${device}     ${pon_port}     ${rmon_type}    ${rmon_session}    ${all_or_current} 
    [Documentation]   Clear the current or historical pm statis from the specified rmon-session of PON interface.
    
    [Tags]    @author=JerryWu
    Axos Cli With Error Check    ${device}    clear interface pon ${pon_port} performance-monitoring rmon-session bin-or-interval ${rmon_type} bin-duration ${rmon_session} all-or-current ${all_or_current}
    
    

verify_pon_pm_counters_all_cleared    
    [Arguments]    ${device}    ${pon_port}    ${rmon_session}    ${rmon_type}    ${num_back}    ${num_show}    ${pon_pm_counter_name}
    [Documentation]    show pon pm by a specific field. This field can be a counter or an opiton.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | pon_port | Pon port ID|
    ...    | rmon_session | Interval of rmon_session |
    ...    | rmon_type | rmon type, indicate as bin or interval |
    ...    | num_back | num_back value |
    ...    | num_show | how many bins to retrieve |
    ...    | pon_pm_counter_name | the counter you want to retrieve |
    
    ...    Example:
    ...    | verify_pon_pm_counters_all_cleared | eutA | 1/1/xp1 | fifeen-minutes | bin | 0 | 1 | 
    [Tags]    @author=JerryWu
    log    show pon pm results
    ${res}    Cli    ${device}    show interface pon ${pon_port} performance-monitoring rmon-session bin-duration ${rmon_session} bin-or-interval ${rmon_type} num-back ${num_back} num-show ${num_show}
    log    The PM result is ${res}
    Should Contain    ${res}    suspect TRUE
    Should Contain    ${res}    cause User cleared pm bins
    ${len}    Get Length    ${pon_pm_counter_name}
    : For    ${index}    IN   @{pon_pm_counter_name}
    \    ${pon_pm_counter_value}    get_pon_pm_counter      ${device}    ${pon_port}    ${rmon_session}    ${rmon_type}    ${num_back}    ${num_show}    ${index}   
    \    Set Test Variable    ${value}    @{pon_pm_counter_value}[1]
    \    Convert To Integer    ${value}
    \    Should be equal    ${value}    0
    
get_pon_pm_state
    
    [Arguments]    ${device}    ${pon_port}    ${rmon_session}    ${bin_count}
    [Documentation]    show pon pm by a specific field. This field can be a counter or an opiton.
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | pon_port | Pon port ID|
    ...    | rmon_session | Interval of rmon_session |
    ...    | rmon_type | rmon type, indicate as bin or interval |
    ...    | num_back | num_back value |
    ...    | num_show | how many bins to retrieve |
    ...    | pon_pm_counter_name | the counter you want to retrieve |
    
    ...    Example:
    ...    | show_pon_pm | eutA | 1/1/xp1 | fifeen-minutes | bin | 0 | 1 | 
    [Tags]    @author=JerryWu
    log    show running config of pon pm
    ${bin_cnt_str}    release_cmd_adapter    ${device}    ${prov_interface_pon_rmon_session_bin_duration_view}
    ${res}    Run Keyword If      "${EMPTY}"=="${bin_cnt_str}"    Axos Cli With Error Check    ${device}    show running-config interface pon ${pon_port} rmon-session ${rmon_session} | details
    ...    ELSE    Axos Cli With Error Check    ${device}    show running-config interface pon ${pon_port} rmon-session ${rmon_session} ${bin_count} | details
    log    The PM config is ${res}
    ${pm_state}    Run Keyword And Continue On Failure    Should Match Regexp    ${res}     admin-state\\s+(enable|disable)\\r\\n
    log    the pm session state is @{pm_state}[1]
    Return from keyword If    '@{pm_state}[1]'== 'None'   enable
    [return]    @{pm_state}[1]

show_last_log_event
    [Arguments]    ${device}    ${log_category}
    [Tags]    @author=Jerry Wu
    ${event_log}    Cli    ${device}    show event log category ${log_category} start-value 1 end-value 1
    [Return]    ${event_log}
    
Bin Wait Time
    [Arguments]    ${bin_duration}
    [Documentation]    Wait time for bin to complete
    [Tags]    @author=llim
    ${wait_time}    Evaluate    ${bin_duration} * 60
    sleep    ${wait_time}
    
    
get_latest_pm_bin_number
     [Arguments]    ${device}    ${pon_port}    ${rmon_session}     ${rmon_type}    ${num_back}    ${num_show}
     [Tags]    @author=Jerry Wu
     ${res}    Cli    ${device}     show interface pon ${pon_port} performance-monitoring rmon-session bin-duration ${rmon_session} bin-or-interval ${rmon_type} num-back ${num_back} num-show ${num_show}
     ${bin_number}    Should Match Regexp    ${res}    number\\s+(\\d+)
     [return]    @{bin_number}[1]
 
pon_pm_bin_complete
     [Arguments]    ${device}    ${pon_port}    ${rmon_session}    ${rmon_type}    ${num_back}     ${num_show}    ${input_bin}
     [Tags]    @author=Jerry Wu
     ${num1}    get_latest_pm_bin_number    ${device}    ${pon_port}     ${rmon_session}     ${rmon_type}    ${num_back}    ${num_show}
     ${num1}    Convert To Integer    ${num1}
     ${input_bin}    Convert To Integer    ${input_bin}
     ${num2}    Evaluate    ${num1} - 1
     Should Be Equal    ${num2}    ${input_bin}
     
prov_ont_pm
    [Arguments]    ${device}    ${ont_id}    ${rmon_session}     ${bin_count}    
    [Tags]    @author=Jerry Wu
    Axos Cli With Error Check    ${device}    configure
    ${bin_cnt_str}    release_cmd_adapter    ${device}    ${prov_interface_pon_config_rmon_session_bin_count}    ${bin_count} 
    Cli    ${device}    ont ${ont_id} rmon-session ${rmon_session} ${bin_cnt_str} admin-state enable
    Axos Cli With Error Check    ${device}    end

dprov_ont_pm
    [Arguments]    ${device}    ${ont_id}    ${rmon_session}    ${bin_count}
    [Tags]    @author=Jerry Wu
    Axos Cli With Error Check    ${device}    configure
    ${bin_cnt_str}    release_cmd_adapter    ${device}    ${prov_interface_pon_rmon_session_bin_duration_view}
    Run Keyword If    "${EMPTY}"=="${bin_cnt_str}"    Axos Cli With Error Check    ${device}    no ont ${ont_id} rmon-session ${rmon_session}
    ...    ELSE    Axos Cli With Error Check    ${device}    no ont ${ont_id} rmon-session ${rmon_session} ${bin_count}
    Axos Cli with Error Check    ${device}    end

show_ont_pm
    [Arguments]    ${device}    ${ont_id}    ${rmon_session}    ${bin_type}    ${num_back}    ${num_show}
    [Tags]    @author=Jerry Wu
    ${output}    Cli    ${device}    show ont ${ont_id} performance-monitoring rmon-session bin-duration ${rmon_session} bin-or-interval ${bin_type} num-back ${num_back} num-show ${num_show}
    [return]    ${output}

show_latest_pon_pm
    [Arguments]    ${device}    ${pon_port}    ${rmon_session}    ${bin_type}    ${num_back}
    [Tags]     @author=Jerry Wu
    ${output}    Cli    ${device}    show interface pon ${pon_port} performance-monitoring rmon-session bin-duration ${rmon_session} bin-or-interval ${bin_type} num-back ${num_back} num-show 1
    [return]    ${output}