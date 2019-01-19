*** Settings ***
Documentation     Suite description
Resource          ../base.robot

*** Keywords ***
prov_aaa_user
    [Arguments]    ${device}    ${user}    ${password}    ${role}=oper
    [Documentation]    Description: Keyword for configuring aaa user
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | user | aaa user |
    ...    | password | user password |
    ...    | role | user role |
    ...
    ...    Example:
    ...    | prov_aaa_user | n1 | ar_ola | ar1 | admin |
    [Tags]    @author=YUE SUN
    cli    ${device}    configure
    cli    ${device}    aaa user ${user} password ${password} role ${role}    \\#    30
    cli    ${device}    end
    cli    ${device}    show running-config aaa | nomore    \\#    30
    Result should contain    ${user}
    
dprov_aaa_user
    [Arguments]    ${device}    ${user}
    [Documentation]    Description: Keyword for removing aaa user
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | user | aaa user |
    ...
    ...    Example:
    ...    | dprov_aaa_user | n1 | ar_ola |
    [Tags]    @author=YUE SUN
    cli    ${device}    configure
    cli    ${device}    no aaa user ${user}    \\#    30
    cli    ${device}    end
    cli    ${device}    show running-config aaa | nomore    \\#    30
    Result should not contain    aaa user ${user} password

prov_aaa_authentication_order
    [Arguments]    ${device}     ${auth_order}
    [Documentation]    Description: Keyword for configuring aaa authentication-order
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |    
    ...    | auth_order | authentication-order |
    ...    
    ...    Example:
    ...    | prov_aaa_authentication_order | n1 | radius-then-local |
    [Tags]    @author=YUE SUN
    cli    ${device}    configure
    cli    ${device}    aaa authentication-order ${auth_order}    \\#    30
    cli    ${device}    end
    cli    ${device}    show running-config aaa | nomore    \\#    30
    Result should contain    authentication-order    
    
dprov_aaa_authentication_order
    [Arguments]    ${device}    ${unexpt_item}
    [Documentation]    Description: Keyword for removing authentication-order
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |    
    ...    
    ...    Example:
    ...    | dprov_aaa_authentication_order | n1 |
    [Tags]    @author=YUE SUN
    cli    ${device}    configure
    cli    ${device}    no aaa authentication-order
    cli    ${device}    end
    cli    ${device}    show running-config aaa authentication-order 
    Result should not contain    ${unexpt_item}
    
prov_radius_retry
    [Arguments]    ${device}    ${retry}
    [Documentation]    Description: Keyword for configuring a radius retry value
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |    
    ...    | retry | retry time |
    ...    
    ...    Example:
    ...    | prov_radius_retry | n1 | 10 |
    [Tags]    @author=YUE SUN
    cli    ${device}    configure
    cli    ${device}    aaa radius retry ${retry}    \\#    30
    cli    ${device}    end
    cli    ${device}    show running-config aaa | details | nomore    \\#    30
    Result should contain    retry ${retry}   
    
dprov_radius_retry
    [Arguments]    ${device}    ${unexp_retry}
    [Documentation]    Description: Keyword for removing radius retry
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |    
    ...    
    ...    Example:
    ...    | dprov_radius_retry | n1 |
    [Tags]    @author=YUE SUN
    cli    ${device}    configure
    cli    ${device}    no aaa radius retry    \\#    30
    cli    ${device}    end
    cli    ${device}    show running-config aaa | nomore    \\#    30
    Result should not contain    radius retry ${unexp_retry}
    
prov_radius_server
    [Arguments]    ${device}    ${server}    @{items}
    [Documentation]    Description: Keyword for configuring a radius server
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |    
    ...    | server | radius server | secret=
    ...    
    ...    Example:
    ...    | prov_radius_server | n1 | 10.245.249.153 |
    ...    | prov_radius_server | n1 | 10.245.249.153 | secret=test_radius_server | port=1645 | priority=1  timeout=5 |
    [Tags]    @author=YUE SUN
    Run Keyword And Ignore Error    cli    ${device}    cli
    cli    ${device}    configure
    : FOR    ${arg}    IN    @{items}
    \    ${key}    ${value}=    Evaluate    "${arg}".split("=")
    \    Log    ${key}, ${value}
    \    cli    ${device}    aaa radius server ${server} ${key} ${value}     \\#    30
    cli    ${device}    end
    cli    ${device}    show running-config aaa radius | nomore    \\#    30
    Result should contain    ${server}

dprov_radius_server
    [Arguments]    ${device}    ${server}
    [Documentation]    Description: Keyword for removing radius server
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |    
    ...    
    ...    Example:
    ...    | dprov_radius_server | n1 |
    [Tags]    @author=YUE SUN
    Run Keyword And Ignore Error    cli    ${device}    cli
    cli    ${device}    show running-config aaa radius server
    cli    ${device}    configure
    cli    ${device}    no aaa radius server ${server}
    cli    ${device}    end
    ${res}    cli    ${device}    show running-config aaa radius server
    should not contain    ${res}    ${server}

get_packet_capture
    [Arguments]    ${device1}    ${device2}    ${craft}    ${server_ip}    ${file}    ${commend_type}=CLI    ${timeout}=10
    [Documentation]    Description: Keyword for getting tcpdump from the server to the mentioned filename
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device1 | device name setting in your yaml, ROOT device |
    ...    | device2 | device name setting in your yaml, configured radius user |
    ...    | craft | craft port |
    ...    | server_ip | radius server ip |
    ...    | file | packet name |
    ...    | commend_type | commend type |
    ...    
    ...    Example:
    ...    | get_packet_capture | eutB_root | euta_radius | craft2 | 10.245.250.112 | /tmp/radius_data_2018_12_18_19_10_48.pcap |
    [Tags]    @author=YUE SUN
    # exit to root
    Run Keyword And Ignore Error    cli    ${device1}    exit    timeout=${timeout}
    # Start packet capture
    cli    ${device1}    tcpdump -i ${craft} -nnvXSs 0 "host ${server_ip}" -w ${file}    timeout_exception=0
    # Login to device using Radius user
    Run Keyword If    '${commend_type}' == 'CLI'   cli    ${device2}    configure    timeout=${timeout}
    ...    ELSE IF    '${commend_type}' == 'NETCONF'    Netconf Get    ${device2}    filter_type=xpath   filter_criteria=//system/version
    sleep    10s
    [Teardown]    cli    ${device1}    \x03
    
get_capture
    [Arguments]    ${device1}    ${device2}    ${craft}    ${server_ip}    ${file}    ${exp_error}=SSHLoginException
    [Documentation]    Description: Keyword for getting tcpdump from the server to the mentioned filename
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device1 | device name setting in your yaml, ROOT device |
    ...    | device2 | device name setting in your yaml, configured radius user |
    ...    | craft | craft port |
    ...    | server_ip | radius server ip |
    ...    | file | packet name |
    ...    | exp_error | except error |
    ...    
    ...    Example:
    ...    | get_capture | eutB_root | euta_radius | craft2 | 10.245.250.112 | /tmp/radius_data_2018_12_18_19_10_48.pcap |
    [Tags]    @author=YUE SUN
    log    Start packet capture
    Run Keyword And Ignore Error    cli    ${device1}    exit    timeout=${timeout}
    cli    ${device1}    tcpdump -i ${craft} -nnvXSs 0 host ${server_ip} -w ${file}    timeout_exception=0
    Run Keyword And Expect Error    ${exp_error}    cli    ${device2}    configure
    sleep    10s
    [Teardown]    cli    ${device1}    \x03
    
generate_pcap_name
    [Arguments]    ${sub_name}
    [Documentation]    Description: Keyword for getting current time for tcpdump file
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | sub_name | subfeature to name file |
    ...    
    ...    Example:
    ...    | generate_pcap_name | radius |
    [Tags]    @author=YUE SUN
    ${time}    get time                                                        
    ${tm}    Replace String Using Regexp    ${time}   \\W    _       
    ${pcap_name}    set variable    /tmp/${sub_name}_data_${tm}.pcap     
    [Return]    ${pcap_name}

analyze_packet_capture
    [Arguments]    ${device}    ${file}    ${src_ip}    ${dst_ip}    @{message}
    [Documentation]    Description: Keyword for verifying pcap file
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml, storing file device |
    ...    | file | tcpdump packet file |
    ...    | src_ip | source ip |
    ...    | dst_ip | destination ip |
    ...    
    ...    Example:
    ...    | analyze_packet_capture | eutB_root | /tmp/radius_data_2018_12_18_19_10_48.pcap | 10.245.46.215 | 10.245.250.112 | 1=Access-Request |
    [Tags]    @author=YUE SUN
    : FOR    ${arg}    IN    @{message}
    \    ${key}    ${value}=    Evaluate    "${arg}".split("=")
    \    Log    ${key}, ${value}
    \    log    Ctrl+C to break the tcpdump packet capture
    \    cli    ${device}    tcpdump -nnvXSs 0 -A -r ${file} "src host ${src_ip}" and "dst host ${dst_ip}" and "udp[8] == ${key}"
    \    Result should contain    ${value}
    [Teardown]    cli    ${device}    \x03
    
analyze_packet_uncapture
    [Arguments]    ${device}    ${file}    ${src_ip}    ${dst_ip}    @{message}
    [[Documentation]    Description: Keyword for verifying pcap file
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml, storing file device |
    ...    | file | tcpdump packet file |
    ...    | src_ip | source ip |
    ...    | dst_ip | destination ip |
    ...    
    ...    Example:
    ...    | analyze_packet_uncapture | eutB_root | /tmp/radius_data_2018_12_18_19_10_48.pcap | 10.245.250.112 | 10.245.46.215 | 2=Access-Accept |
    [Tags]    @author=YUE SUN
    : FOR    ${arg}    IN    @{message}
    \    ${key}    ${value}=    Evaluate    "${arg}".split("=")
    \    Log    ${key}, ${value}
    \    log    Ctrl+C to break the tcpdump packet capture
    \    cli    ${device}    tcpdump -nnvXSs 0 -A -r ${file} "src host ${src_ip}" and "dst host ${dst_ip}" and "udp[8] == ${key}"
    \    Result should not contain    ${value}
    [Teardown]    cli    ${device}    \x03
    
show_alarm_authentication
    [Arguments]    ${device}    ${exp_alarm}
    [Documentation]    show alarm active
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | exp_alarm | expect alarm |
    
    ...    Example:
    ...    | exp_alarm | n1 | fallback-to-localauthentication |		
    [Tags]     @author=YUE SUN  
    ${res}    cli    ${device}    show alarm active
    should contain    ${res}   ${exp_alarm}
    
show_user_sessions_nocontain
    [Arguments]    ${device}    ${unexp_item}
    [Documentation]    show alarm active
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | unexp_item | unexpect item |
    
    ...    Example:
    ...    | show_user_sessions_nocontain | n1 | calix1 |		
    [Tags]     @author=YUE SUN  
    ${res}    cli    ${device}    show user-sessions
    Should Not Match Regexp    ${res}    session-login\\s+${unexp_item}
    
show_user_sessions_contain
    [Arguments]    ${device}    ${exp_item}
    [Documentation]    show alarm active
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | exp_item | expect item |
    
    ...    Example:
    ...    | show_user_sessions_contain | n1 | calix1 |		
    [Tags]     @author=YUE SUN  
    ${res}    cli    ${device}    show user-sessions
    Should Match Regexp    ${res}    session-login\\s+${exp_item}