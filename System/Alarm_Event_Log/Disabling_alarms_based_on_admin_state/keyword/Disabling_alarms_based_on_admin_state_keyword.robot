*** Settings ***
Documentation    test_suite keyword lib

*** Variable ***


*** Keywords ***

verify_alarm_is_exist
    [Arguments]    ${device}    ${alarm_discription}
    [Documentation]    verify alarm is exist
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | alarm_discription  | distinguish the same alarm with detailed object |
    ...
    ...    Example:
    ...    | verify_alarm_is_exist | eutA | '1/1/gp2' |

    [Tags]    @author=Meiqin_Wang
    
    ${res1}    cli    ${device}    show alarm active
    ${res2}    cli    ${device}    show alarm suppressed
    ${res}    Catenate    ${res1}    ${res2}
    Should Contain    ${res}   ${alarm_discription}
    ${alarm_instance_id}    Get Regexp Matches    ${res}    instance-id\\s+(\\d+\.\\d+).+${alarm_discription}    1
    [Return]    ${alarm_instance_id[0]}
    
verify_alarm_is_cleared
    [Arguments]    ${device}    ${alarm_instance_id}
    [Documentation]   get alarm active time
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | erps-ring | erps ring id |
    ...    | alarm_name  | the alarm need to get the time |
    ...    | alarm_discription  | distinguish the same alarm with detailed object |
    ...
    ...    Example:
    ...    | verify_alarm_is_cleared | eutA | 17.182 | 
    [Tags]    @author=Meiqin_Wang

    ${res1}    cli    ${device}    show alarm active
    ${res2}    cli    ${device}    show alarm suppressed
    ${res}    Catenate    ${res1}    ${res2}
    Should Not Contain Any    ${res}   ${alarm_instance_id} perceived-severity
    [Return]    cli    ${device}    end
    
check_port_admin_status_disable
    [Arguments]    ${device}    ${port_type}    ${port_name}
    [Documentation]   check port admin status is disable
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | master node |
    ...    | port_type | port type |
    ...    | port_name | port name |
    ...
    ...    Example:
    ...    | check_port_admin_status | eutA | pon | 1/1/gp2 |
    [Tags]    @author=Meiqin_Wang
    ${res}    cli    ${device}    show interface ${port_type} ${port_name} status
    ${temp}     Get Lines Containing String    ${res}    admin-state
    should contain    ${temp}    disable
    
check_port_admin_status_enable
    [Arguments]    ${device}    ${port_type}    ${port_name}
    [Documentation]   check port admin status is enable
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | master node |
    ...    | port_type | port type |
    ...    | port_name | port name |
    ...
    ...    Example:
    ...    | check_port_admin_status_enable | eutA | pon | 1/1/gp2 |
    [Tags]    @author=Meiqin_Wang
    ${res}    cli    ${device}    show interface ${port_type} ${port_name} status
    ${temp}     Get Lines Containing String    ${res}    admin-state
    should contain    ${temp}    enable
    