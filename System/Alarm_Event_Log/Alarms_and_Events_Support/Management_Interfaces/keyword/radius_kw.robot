*** Settings ***
Resource          caferobot/cafebase.robot
Library           Collections
Library           String
Library           DateTime


*** Keywords ***
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
    cli    ${session1}    tcpdump -i ${int} -nnvXSs 0 "host ${server}" -w /tmp/${file}.pcap    timeout_exception=0

    # Login to device using Radius user
    #${var}    Get Count    ${session_type}    CLI
    Run Keyword If    '${session_type}' == 'CLI'   cli    ${session2}    configure
    ...    ELSE IF    '${session_type}' == 'NETCONF'    Netconf Get    ${session2}    filter_type=xpath   filter_criteria=//system/version
    
    # Packet capture and hence waiting
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
    \    cli    ${session}    tcpdump -nnvXSs 0 -A -r /tmp/${file}.pcap "src host ${src_ip}" and "dst host ${dst_ip}" and "udp[8] == ${key}"    \\~#
    \    Result should contain    ${value}
