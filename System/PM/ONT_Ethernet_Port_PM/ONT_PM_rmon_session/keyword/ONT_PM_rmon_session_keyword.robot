*** Settings ***
Resource    ../base.robot


*** Keywords ***

check_interface_ont_pm
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${bin-duration}    ${bin-or-interval}    ${num-back}    ${num-show}    ${dict_check_item}
    [Documentation]    Description: check "show interface ${port_type} ${port_name} performance-monitoring rmon-session" information
    ...    query item is: bin-duration ${bin-duration} bin-or-interval ${bin-or-interval} num-back ${num-back} num-show ${num-show}
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | bin-duration | Configured rmon-session bin-duration |
    ...    | bin-or-interval | Keyword bin or interval |
    ...    | num-back | Exact bin or interval which is num-back from current |
    ...    | num-show | How many bins or intervals to display |
    ...    | dict_check_item | dictionary type check item, format as check_item=exp_value or check_item=${EMPTY} |
    ...
    ...    Example:
    ...    | check_interface_ont_pm | eutA | ont-ethernet | 100/x1 | five-minutes | bin | 0 | upstream-packets-64-octets |
    [Tags]    @author=Meiqin_Wang
    ${result}    Cli    ${device}
    ...    show interface ${port_type} ${port_name} performance-monitoring rmon-session bin-duration ${bin-duration} bin-or-interval ${bin-or-interval} num-back ${num-back} num-show ${num-show}
    ${temp}    get regexp matches    ${result}    ${dict_check_item}\\s+(\\d+)\\r\\n    1
    log    the counter value is ${temp[0]}
    ${res}    Convert To Integer    ${temp[0]} 
    [Return]    ${res}
    
check_correct
    [Arguments]    ${total_tx_pkt_bytes}    ${ont_pm_counter}
    [Documentation]    Description: check (${total_tx_counter} - ${ont_pm_counter})/512 <= 5
    [Tags]    @author=Meiqin_Wang
    Should Be True    (${total_tx_pkt_bytes} - ${ont_pm_counter})/512 <= 5

debug_eth_pm
    [Arguments]   ${device}
    [Documentation]    Description: debug command for ont eth pm command, for root user
    ...   dcli ponmgrd omci trace show
    ...    dcli ponmgrd history
    [Tags]    @author=chxu
    Cli    ${device}      dcli ponmgrd omci trace show
    Cli    ${device}       dcli ponmgrd history