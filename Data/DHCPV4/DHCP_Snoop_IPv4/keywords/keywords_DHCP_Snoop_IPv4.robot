*** Settings ***
Resource    ../base.robot

*** Keywords ***

Get_time
    [Arguments]    ${device}    ${option}
    [Documentation]    [Author:ryi] Description: Get dhcp lease ${option} time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | option| lease-expires, lease-renewed,lease-first-acquired |

    ...    Example:
    ...    | Get_time | eutA | lease-first-acquired

    ${cmd_string}    set variable    show l3-hosts
    ${res}    cli    ${device}    ${cmd_string}
    ${result}    should match regexp    ${res}    ${option}\\s+(\\S+)
    ${Date}    set variable    ${result[1]}
    [Return]    ${Date}
    
Get_dhcp_lease_first_time
    [Arguments]    ${device}    ${vlan}    ${ip}
    [Documentation]    [Author:ryi] Description: Get dhcp lease time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | lease service vlan |
    ...    | ip | dhcp lease ip |
    ...    Example:
    ...    | Get_dhcp_lease_first_time | eutA | 300 | 80.11.1.20

    ${cmd_string}    set variable    show l3-hosts
    ${res}    cli    ${device}    ${cmd_string}
    ${result}    should match regexp    ${res}    l3-host\\s+(\\d+)\\s+(\\S+)
    ${Date}    run keyword if    '${result[1]}'=='${vlan}' and '${result[2]}'=='${ip}'    Get_time    eutA    lease-first-acquired
    ${Date_2}    Replace String    ${Date}    T    ${SPACE}    count=1
    [Return]    ${Date_2}

Get_dhcp_lease_renew_time
    [Arguments]    ${device}    ${vlan}    ${ip}
    [Documentation]    [Author:ryi] Description: Get dhcp lease time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | lease service vlan |
    ...    | ip | dhcp lease ip |
    ...    Example:
    ...    | Get_dhcp_lease_renew_time | eutA | 300 | 80.11.1.20

    ${cmd_string}    set variable    show l3-hosts
    ${res}    cli    ${device}    ${cmd_string}
    ${result}    should match regexp    ${res}    l3-host\\s+(\\d+)\\s+(\\S+)
    ${Date}    run keyword if    '${result[1]}'=='${vlan}' and '${result[2]}'=='${ip}'    Get_time    eutA    lease-renewed
    ${Date_2}    Replace String    ${Date}    T    ${SPACE}    count=1
    [Return]    ${Date_2}
    
Get_dhcp_lease_expire_time
    [Arguments]    ${device}    ${vlan}    ${ip}
    [Documentation]    [Author:ryi] Description: Get dhcp lease time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | lease service vlan |
    ...    | ip | dhcp lease ip |
    ...    Example:
    ...    | Get_dhcp_lease_expire_time | eutA | 300 | 80.11.1.20

    ${cmd_string}    set variable    show l3-hosts
    ${res}    cli    ${device}    ${cmd_string}
    ${result}    should match regexp    ${res}    l3-host\\s+(\\d+)\\s+(\\S+)
    ${Date}    run keyword if    '${result[1]}'=='${vlan}' and '${result[2]}'=='${ip}'    Get_time    eutA    lease-expires
    ${Date_2}    Replace String    ${Date}    T    ${SPACE}    count=1
    [Return]    ${Date_2}    
    
    
expected_lease_expire_time
    [Arguments]    ${device}    ${vlan}    ${ip}    ${lease_time}
    [Documentation]    [Author:ryi] Description: count expected lease expire time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | lease service vlan |
    ...    | ip | dhcp lease ip |
    ...    | lease_time | lease time |
    ...
    ...    Example:
    ...    | expected_lease_expire_time | eutA | 300 | 80.11.1.20 | 8d

    ${Date}    Get_dhcp_lease_first_time    ${device}    ${vlan}    ${ip}
    ${NewDate}    add time to date    ${Date}    ${lease_time}    result_format=%Y-%m-%d %H:%M:%S    date_format=%Y-%m-%d %H:%M:%S
    [Return]    ${NewDate}
    
expected_lease_expire_time_after_renew
    [Arguments]    ${device}    ${vlan}    ${ip}    ${lease_time}
    [Documentation]    [Author:ryi] Description: count expected lease expire time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | lease service vlan |
    ...    | ip | dhcp lease ip |
    ...    | lease_time | lease time |
    ...
    ...    Example:
    ...    | expected_lease_expire_time | eutA | 300 | 80.11.1.20 | 8d

    ${Date}    Get_dhcp_lease_renew_time    ${device}    ${vlan}    ${ip}
    ${NewDate}    add time to date    ${Date}    ${lease_time}    result_format=%Y-%m-%d %H:%M:%S    date_format=%Y-%m-%d %H:%M:%S
    [Return]    ${NewDate} 
    
expected_lease_renew_time
    [Arguments]    ${device}    ${vlan}    ${ip}    ${lease_time}
    [Documentation]    [Author:ryi] Description: count expected lease expire time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | lease service vlan |
    ...    | ip | dhcp lease ip |
    ...    | lease_time | lease time |
    ...
    ...    Example:
    ...    | expected_lease_expire_time | eutA | 300 | 80.11.1.20 | 8d

    ${Date}    Get_dhcp_lease_first_time    ${device}    ${vlan}    ${ip}
    ${time}    	Evaluate    ${lease_time}/2
    ${NewDate}    add time to date    ${Date}    ${lease_time}    result_format=%Y-%m-%d %H:%M:%S    date_format=%Y-%m-%d %H:%M:%S
    [Return]    ${NewDate}
    
check_lease_renew_time
    [Arguments]    ${device}    ${vlan}    ${ip}    ${lease_time}
    [Documentation]    [Author:ryi] Description: count expected lease expire time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | lease service vlan |
    ...    | ip | dhcp lease ip |
    ...    | lease_time | lease time    ...
    ...    Example:
    ...    | check_lease_renew_time | eutA | 300 | 80.11.1.20 | 8d

    ${Date}    Get_dhcp_lease_renew_time    ${device}    ${vlan}    ${ip}
    ${NewDate}    expected_lease_renew_time    ${device}    ${vlan}    ${ip}    ${lease_time}
    should be equal as strings   ${Date}    ${NewDate}
      
    
check_lease_expire_time
    [Arguments]    ${device}    ${vlan}    ${ip}    ${lease_time}
    [Documentation]    [Author:ryi] Description: count expected lease expire time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | lease service vlan |
    ...    | ip | dhcp lease ip |
    ...    | lease_time | lease time    ...
    ...    Example:
    ...    | check_lease_expire_time | eutA | 300 | 80.11.1.20 | 8d

    ${Date}    Get_dhcp_lease_expire_time    ${device}    ${vlan}    ${ip}
    ${NewDate}    expected_lease_expire_time    ${device}    ${vlan}    ${ip}    ${lease_time}
    should be equal as strings   ${Date}    ${NewDate}


check_lease_expire_time_after_renew
    [Arguments]    ${device}    ${vlan}    ${ip}    ${lease_time}
    [Documentation]    [Author:ryi] Description: count expected lease expire time
    [Tags]    @author=Ronnie_yi
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | vlan | lease service vlan |
    ...    | ip | dhcp lease ip |
    ...    | lease_time | lease time    ...
    ...    Example:
    ...    | check_lease_expire_time | eutA | 300 | 80.11.1.20 | 8d

    ${Date}    Get_dhcp_lease_expire_time    ${device}    ${vlan}    ${ip}
    ${NewDate}    expected_lease_expire_time_after_renew    ${device}    ${vlan}    ${ip}    ${lease_time}
    should be equal as strings   ${Date}    ${NewDate}

check_bridge_table_no_entry
    [Arguments]    ${device}
    [Documentation]    show bridge table doesn't include any mac
    [Tags]    @author=Ronnie_yi
    ${result}    CLI    ${device}    show bridge table
    should contain    ${result}    No entries found

#
#Check_counters_for_each_interface
#    [Arguments]   ${device}
#    [Documentation]   check interface counters for ont-ethernet, pon, and ethernet
#    show_interface_counters   ${device}   ${service_model.${service_point}.type}       1/1/x1