*** Settings ***
Resource          caferobot/cafebase.robot
Library           Collections
Library           String
Library           DateTime
Library      XML    use_lxml=True

*** Keywords ***
check clock by dynamic passwaord
    [Arguments]    ${conn}
    [Documentation]    retrieve the elements
    ...    Example:
    ...    Get attributes netconf  n1_session1  //system/images/summary  state
    [Tags]    @author=chxu
    run keyword and ignore error  disconnect     ${conn}
    ${login_date_time}  cli    ${conn}        show clock
    [Return]    ${login_date_time}

Get attributes netconf
    [Arguments]    ${conn}    ${parameter1}    ${parameter2}
    [Documentation]    retrieve the elements
    ...    Example:
    ...    Get attributes netconf  n1_session1  //system/images/summary  state
    [Tags]    @author=clakshma
    log many    ${parameter1}    ${parameter2}
    ${output} =    Netconf Get    ${conn}    filter_type=xpath   filter_criteria=${parameter1}
    log    ${output.data_xml}
    ${root} =    Parse XML    ${output.data_xml}
    @{elem}=    Get Elements    ${root}    .//${parameter2}
    log    ${elem[0].text}
    [Return]    @{elem}

Edit netconf configure
    [Arguments]    ${conn}    ${parameter1}    ${parameter2}
    [Documentation]    configure the elements
    ...    Example:
    ...    Configure attributes netconf   n1_session1  config   error-tag
    [Tags]    @author=clakshma
    log many    ${parameter1}    ${parameter2}
    ${output} =    Netconf Edit Config    ${conn}    target=running    config=${parameter1}
    log    ${output.xml}
    @{elem}=    Get Elements    ${output.xml}    .//${parameter2}
    log    ${elem[0].text}
    [Return]    @{elem}

Raw netconf configure
    [Arguments]    ${conn}    ${parameter1}    ${parameter2}
    [Documentation]    configure the elements
    ...    Example:
    ...    Raw netconf   n1_session1  config   error-tag
    [Tags]    @author=clakshma
    log many    ${parameter1}    ${parameter2}
    ${output} =    Netconf Raw    ${conn}    ${parameter1}
    @{elem}=    Get Elements    ${output.xml}    .//${parameter2}
    log    ${elem[0].text}
    [Return]    @{elem}

Get formatted date time
    [Arguments]    ${login_date_time}
    [Documentation]    Retrieve the time stamp value in particular format
    ...    Example:
    ...    Get formatted date time     2016-11-03 06:45:35 PDT
    [Tags]    @author=lpaul
    ${date}   should match regexp     ${login_date_time}    \\d\\d\\d\\d-\\d\\d-\\d\\d
    ${time}   should match regexp     ${login_date_time}    \\d\\d:\\d\\d
    ${format}    Catenate    SEPARATOR=T   ${date}   ${time}
    [Return]   ${format}

Get Ecrack Password
    [Arguments]    ${conn}   ${ip}   ${hostname}
    [Documentation]    To get the e-crack password
    ...    Example:
    ...    Get Ecrack Password    n1_session1   10.1.0.8   E3-16F
    [Tags]    @author=lpaul
    ${datetime}    cli   ${conn}   show clock
    ${datetime}    Convert Date     ${datetime}    datetime
    ${year}    set variable     ${datetime.year}
    ${Date}    set variable    ${datetime.day}
    ${hour}    set variable    ${datetime.hour}
    ${min}    set variable    ${datetime.minute}
    ${sec}    set variable    ${datetime.second}
    cli   ${conn}   timestamp enable
    ${date_time}    cli   ${conn}   show clock
    ${month_day}   should match regexp     ${date_time}    \\w\\w\\w\\s\\w\\w\\w\\s
    @{words}    Split String    ${month_day}
    ${month}    set variable    @{words}[0]
    ${day}    set variable    @{words}[1]
    ${arg}   set variable   http://${ip}/sandbox/ecrack.pl?Input=${hostname}
    ${format1}    Catenate    SEPARATOR=+   ${Month}   ${Day}
    ${format2}    Catenate    SEPARATOR=+   ${format1}    ${Date}
    ${format3}    Catenate    SEPARATOR=+   ${format2}    ${hour}
    ${format4}     Catenate    SEPARATOR=%3A   ${format3}   ${min}
    ${format5}     Catenate    SEPARATOR=%3A   ${format4}   ${sec}
    ${format6}     Catenate    SEPARATOR=+   ${format5}   ${year}
    ${input}    Catenate    SEPARATOR=+   ${arg}    ${format6}
    Log   ${input}
    cli   ${conn}   timestamp disable
    Go To Page   web   ${input}
    ${elem}    caferobot.web.adapter.WebGuiAdapter.Get Element Text    web  xpath=//html
    ${password}    Should Match Regexp    ${elem}    The password for calixsupport is: ([\\S]+)
    ${calixsupport_pwd}    set variable    @{password}[1]
    [Return]    ${calixsupport_pwd}

Get hostname
    [Arguments]    ${conn}    ${hostname}
    [Documentation]    To get the device hostname
    ...    Example:
    ...    Get hostname    n1_session1
    [Tags]    @author=clakshma
    ${output}    cli    ${conn}    show running-config hostname
    @{hostname}    Run Keyword If    'No entries found' in '''${output}'''    Return From Keyword    ${hostname}
    #...    ELSE    should match regexp    ${output}    hostname ([0-9a-zA-Z\\s\-]+)
    ...    ELSE    should match regexp    ${output}    hostname (\\S*)
    [Return]    @{hostname}[1]

Verify SysLog Entry
    [Arguments]    ${conn}    ${formatted_time}   ${verify}
    [Documentation]   To verify the SysLog entry
    ...    Example:
    ...    Verify SysLog Entry   n1_session1    2016-11-21T23:22   Failed password for ${operator_usr}
    [Tags]    @author=lpaul
    # Retrieving data from syslog file and verifying the log entry for operator user
    cli    ${conn}    show file contents syslog filename sshd.log | begin ${formatted_time}
    Result Match Regexp    ${verify}

Verify AuditLog Entry
    [Arguments]    ${conn}    ${formatted_time}   ${verify}
    [Documentation]   To verify the AuditLog entry
    ...    Example:
    ...    Verify AuditLog Entry   n1_session1    2016-11-21T23:22   audit user: ${operator_usr}
    [Tags]    @author=lpaul

    ${res}    cli    ${conn}    show file contents syslog | include conf
    ${res}    Should match regexp    ${res}    [Cc][Oo][Nn][Ff][Dd]
    # Retrieving data from audit log file and verifying the log entry for operator user
    cli    ${conn}    show file contents syslog filename ${res}/confd.log | begin ${formatted_time}
    Result Match Regexp    ${verify}

Configure SNMPv2
    [Arguments]    ${conn}    ${admin_state}    ${community}
    [Documentation]    To configure SNMP on device
    ...    Example:
    ...    Configure SNMPv2   n1_session1   enable   public
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v2 admin-state ${admin_state}
    cli    ${conn}    snmp v2 community ${community} ro
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v2
    Result should contain    v2 community ${community} ro

Remove SNMPv2
    [Arguments]    ${conn}    ${admin_state}    ${community}
    [Documentation]    To remove SNMP on device
    ...    Example:
    ...    Remove SNMPv2   n1_session1   disable   public
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v2 admin-state ${admin_state}
    cli    ${conn}    no v2 community ${community} ro
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v2
    Result should not contain    v2 community ${community} ro

Configure SNMPv3
    [Arguments]    ${conn}    ${admin_state}    ${user}    ${auth}=NONE    ${auth_key}=${EMPTY}    ${priv}=NONE    ${priv_key}=${EMPTY}
    [Documentation]    To configure SNMPv3 on device
    ...    Example:
    ...    Configure SNMPv3   n1_session1   enable   snmptest
    [Tags]    @author=clakshma
    cli    ${conn}    conf    prompt=\\#
    cli    ${conn}    snmp v3 admin-state ${admin_state} user ${user}

    Run Keyword If    '${auth_key}' != '${EMPTY}'   cli    ${conn}    authentication protocol ${auth} key ${auth_key}
    ...    ELSE IF    '${auth}' != 'NONE'   cli    ${conn}    authentication protocol ${auth}
    ...    ELSE    cli    ${conn}    authentication protocol ${auth}

    Run Keyword If    '${priv_key}' != '${EMPTY}'   cli    ${conn}    privacy protocol ${priv} key ${priv_key}
    ...    ELSE IF    '${priv}' != 'NONE'   cli    ${conn}   privacy protocol ${priv}
    #...    ELSE    cli    ${conn}    privacy protocol ${priv}

    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v3
    Result should contain    v3 user ${user}

Configure V3 trap
    [Arguments]    ${conn}    ${server_ip}     ${user}     @{items}
    [Documentation]    To configure SNMPv3 trap on device
    ...    Example:
    ...    Configure V3 trap    n1_session1    10.243.83.111    snmptest    security-level=authPriv
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v3 trap-host ${server_ip} ${user}
    : FOR    ${arg}    IN    @{items}
    \    ${key}    ${value}=    Evaluate    "${arg}".split("=")
    \    Log    ${key}, ${value}
    \    cli    ${conn}    ${key} ${value}     \\#    30
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v3 trap-host
    Result should contain    v3 trap-host ${server_ip} ${user}

Remove SNMPv3
    [Arguments]    ${conn}    ${admin_state}    ${user}
    [Documentation]    To remove SNMPv3 on device
    ...    Example:
    ...    Remove SNMPv3   n1_session1   disable   snmptest
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v3 admin-state ${admin_state}
    cli    ${conn}    no v3 user ${user}
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v3
    Result should not contain    v3 user ${user}

Remove V3 trap
    [Arguments]    ${conn}    ${server_ip}     ${user}
    [Documentation]    To remove SNMPv3 trap on device
    ...    Example:
    ...    Remove V3 trap    n1_session1    10.243.83.111    snmptest
    [Tags]    @author=clakshma
    cli    ${conn}    conf
    cli    ${conn}    snmp v3 admin-state enable
    cli    ${conn}    no v3 trap-host ${server_ip} ${user}
    cli    ${conn}    end
    cli    ${conn}    show running-config snmp v3 trap-host
    Result should not contain    v3 trap-host ${server_ip} ${user}

ping_dpu
    [Documentation]  Check if DPU is reachable
    [Arguments]    ${session}    ${device_ip}    ${timeout}=30
    ${ret} =    Session Command    h1    ${SPACE}
    ${prompt} =    get last command prompt    h1
    ${prompt} =    regexp escape  ${prompt}
    ${res}    cli    ${session}    ping ${device_ip} -c 4    ${prompt}    ${timeout}
    should Match Regexp      ${res}    ,\\s0% packet loss

Configure radius server
    [Arguments]    ${session}    ${server}    @{items}
    [Documentation]    Keyword for configuring a radius server
    ...    Example:
    ...    Configure radius server  n1  10.243.250.60  secret=test_radius_server  port=1645   priority=1   timeout=5
    [Tags]    @author=clakshma
    cli    ${session}    configure
    : FOR    ${arg}    IN    @{items}
    \    ${key}    ${value}=    Evaluate    "${arg}".split("=")
    \    Log    ${key}, ${value}
    \    cli    ${session}    aaa radius server ${server} ${key} ${value}     \\#    30
    cli    ${session}    end
    cli    ${session}    show running-config aaa radius | nomore    \\#    30
    Result should contain    ${server}


Configure radius retry
    [Arguments]    ${session}    ${retry}
    [Documentation]    Keyword for configuring a radius retry value
    ...    Example:
    ...    Configure radius retry    n1    10
    [Tags]    @author=ysnigdha
    cli    ${session}    configure
    cli    ${session}    aaa radius retry ${retry}    \\#    30
    cli    ${session}    end
    cli    ${session}    show running-config aaa | details | nomore    \\#    30
    Result should contain    retry ${retry}

Configure aaa authentication-order
    [Arguments]    ${session}     ${option}
    [Documentation]    Keyword for configuring aaa authentication-order
    ...    Example:
    ...    Configure aaa authentication-order    n1    radius-then-local
    [Tags]    @author=ysnigdha
    cli    ${session}    configure
    cli    ${session}    aaa authentication-order ${option}    \\#    30
    cli    ${session}    end
    cli    ${session}    show running-config aaa | nomore    \\#    30
    Result should contain    authentication-order

Configure aaa user
    [Arguments]    ${session}    ${user}    ${password}    ${role}
    [Documentation]    Keyword for configuring aaa user
    ...    Example:
    ...    Configure aaa user    n1    ar1_ola    ar1    admin
    [Tags]    @author=ysnigdha
    cli    ${session}    configure
    cli    ${session}    aaa user ${user} password ${password} role ${role}    \\#    30
    cli    ${session}    end
    cli    ${session}    show running-config aaa | nomore    \\#    30
    Result should contain    ${user}

Remove aaa user
    [Arguments]    ${session}    ${user}
    [Documentation]    Keyword for removing aaa user
    ...    Example:
    ...    Remove aaa user    n1    ar1_ola
    [Tags]    @author=ysnigdha
    cli    ${session}    configure
    cli    ${session}    no aaa user ${user}    \\#    30
    cli    ${session}    end
    cli    ${session}    show running-config aaa | nomore    \\#    30
    Result should not contain    ${user}

Remove aaa authentication-order
    [Arguments]    ${session}
    [Documentation]    Keyword for removing authentication-order
    ...    Example:
    ...    Remove aaa authentication-order    n1
    [Tags]    @author=ysnigdha
    cli    ${session}    configure
    cli    ${session}    no aaa authentication-order    \\#    30
    cli    ${session}    end
    cli    ${session}    show running-config aaa | nomore    \\#    30
    Result should not contain    authentication-order

Remove radius retry
    [Arguments]    ${session}
    [Documentation]    Keyword for removing radius retry
    ...    Example:
    ...    Remove radius retry    n1
    [Tags]    @author=ysnigdha
    cli    ${session}    configure
    cli    ${session}    no aaa radius retry    \\#    30
    cli    ${session}    end
    cli    ${session}    show running-config aaa | nomore    \\#    30
    Result should not contain    retry

Remove radius server
    [Arguments]    ${session}
    [Documentation]    Keyword for removing radius server
    ...    Example:
    ...    Remove radius server    n1
    [Tags]    @author=clakshma

    ${res}    cli    ${session}    show running-config aaa radius server | nomore    \\#    30
    @{res}    Split To Lines    ${res}    1
    :FOR    ${var}    IN    @{res}
    \    ${server}    Get Regexp Matches    ${var}    server ([0-9a-zA-Z\.]+) secret    1
    \    ${server}    Evaluate    "${server}".strip("[]'")
    \    Run Keyword If    '${server}' == '${EMPTY}'   Exit For Loop
    \    cli    ${session}    configure
    \    cli    ${session}    no aaa radius server ${server}    \\#    30
    \    cli    ${session}    end
    \    cli    ${session}    show running-config aaa radius server | nomore    \\#    30
    \    Result should not contain    ${server}

Get packet capture
    [Arguments]    ${session1}    ${session2}    ${int}    ${server}    ${file}    ${session_type}=CLI
    [Documentation]    Keyword for getting tcpdump from the server to the mentioned filename
    ...    Example:
    ...    Get tcpdump n2 n1 radiusdump 10.243.250.61
    ...    session1 is the root user
    ...    session2 is the configured radius user
    [Tags]    @author=clakshma
    # Start packet capture
    cli    ${session1}    tcpdump -i ${int} -nnvXSs 0 "host ${server}" -w ${file}.pcap    timeout_exception=0

    # Login to device using Radius user
    #${var}    Get Count    ${session_type}    CLI
    Run Keyword If    '${session_type}' == 'CLI'   cli    ${session2}    configure
    ...    ELSE IF    '${session_type}' == 'NETCONF'    Netconf Get    ${session2}    filter_type=xpath   filter_criteria=//system/version

    sleep    10s

    cli    ${session1}    \x03     \\~#

Get capture
    [Arguments]    ${session1}    ${session2}    ${int}    ${server}    ${file}
    [Documentation]    Keyword for getting tcpdump from the server to the mentioned filename
    ...    Example:
    ...    Get tcpdump n2 n1 radiusdump 10.243.250.61
    ...    session1 is the root user
    ...    session2 is the configured radius user

    # Start packet capture
    cli    ${session1}    tcpdump -i ${int} -nnvXSs 0 host ${server} -w ${file}.pcap    timeout_exception=0

    Run Keyword And Expect Error    SSHLoginException    cli    ${session2}    configure

    sleep    10s

    cli    ${session1}    \x03     \\~#

Verify packet capture
    [Arguments]    ${session}    ${file}    ${src_ip}    ${dst_ip}    @{message}
    [Documentation]    Keyword for verifying pcap file
    ...    Example:
    [Tags]    @author=clakshma

    : FOR    ${arg}    IN    @{message}
    \    ${key}    ${value}=    Evaluate    "${arg}".split("=")
    \    Log    ${key}, ${value}
    \    cli    ${session}    tcpdump -nnvXSs 0 -A -r ${file}.pcap "src host ${src_ip}" and "dst host ${dst_ip}" and "udp[8] == ${key}"    \\~#
    \    Result should contain    ${value}

generate_pcap_name
    [Arguments]    ${up_down}
    ${time}    get time                                                        
    ${tm}    Replace String Using Regexp    ${time}   \\W    _       
    return from keyword    /tmp/${up_down}_data_${tm}.pcap      

Shut Interface
    [Arguments]    ${session}    ${int_type}    ${int_port}
    [Documentation]    Shutdown interface
    ...    Example:
    ...    Shut Interface    n1_session1    Ethernet    1/1/x1
    [Tags]    @author=gpalanis
    cli    ${session}    configure
    cli    ${session}    interface ${int_type} ${int_port}    \\#    30
    cli    ${session}    shutdown
    cli    ${session}    end
    cli    ${session}    show interface ${int_type} ${int_port} configuration| include admin-state | nomore    \\#    30
    Result should contain    disable

Unshut Interface
    [Arguments]    ${session}    ${int_type}    ${int_port}
    [Documentation]    Unshut interface
    ...    Example:
    ...    Unshut Interface    n1_session1    Ethernet    1/1/x1
    [Tags]    @author=gpalanis
    cli    ${session}    configure
    cli    ${session}    interface ${int_type} ${int_port}    \\#     30
    cli    ${session}    no shutdown
    cli    ${session}    end
    cli    ${session}    show interface ${int_type} ${int_port} configuration | include admin-state| nomore    \\#    30
    Result should contain    enable

Get SNMP table Element
    [Arguments]   ${conn}    ${table}    ${parameter}
    [Documentation]   Getting element
    ...    Example:
    ...    Get SNMP table Element    n_snmp_v3     SNMP-NOTIFICATION-MIB::snmpNotifyTable    ${trap_type}
    [Tags]    @author=clakshma
    @{value_list}   Create List
    ${parameter}    convert to string    ${parameter}
    @{output}    snmp Walk   ${conn}     ${table}
    : FOR    ${arg}    IN    @{output}
    \    ${key}    ${value}=    Evaluate    "${arg}".split(",")
    \    ${value}=     Strip String    ${value}    mode=both    characters=)'\u
    \    ${value}=     Remove String Using Regexp    ${value}    [\\s\']    ${EMPTY}
    \    ${val}    Get Count    ${value}    ${parameter}
    \    Run Keyword If   '${parameter}' == '${value}'    Exit For Loop
    \    ...    ELSE    Continue For Loop
    \    Exit For Loop
    [Return]    ${value}

Get Trap-host Element
    [Arguments]   ${conn}    ${snmp_version}   ${trap_host_ip}    ${parameter}
    [Documentation]   Getting element from the cli output of  Show Running-config
    ...    Example:
    ...    Get Trap-host Element   n1_session1   ${snmp_version}   ${DEVICES.n1_session1.ip}   timeout
    [Tags]    @author=clakshma

    ${result}    cli    ${conn}   show running-config snmp ${snmp_version} trap-host ${trap_host_ip}
    ${res}    Build Response Map    ${result}
    ${resp}    Parse Nested Text    ${res}    start_line=3
    ${res}    Get Value From Nested Text    ${resp}    ${parameter}
    [Return]    ${res}
