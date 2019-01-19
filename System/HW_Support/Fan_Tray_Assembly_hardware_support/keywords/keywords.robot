*** Settings ***
Documentation     Suite description
Resource          ../base.robot

*** Keywords ***
check_ntp_status
    [Arguments]    ${device}    ${ntp_staus}
    ${result}    cli    ${device}    show ntp
    ${res1}    Get Lines Containing String    ${result}    ntpd-status
    Should contain    ${res1}    ${ntp_staus}

check_ntp_server
    [Arguments]    ${device}    ${server_ip}    ${connection_status}    ${synchronize_status}    ${source_status}
    ${result}    cli    ${device}    show ntp server ${server_ip}
    ${res1}    Get Lines Containing String    ${result}    remote-reference-id
    ${res2}    Get Lines Containing String    ${result}    connection-status
    ${res3}    Get Lines Containing String    ${result}    synchronize-status
    ${res4}    Get Lines Containing String    ${result}    source-status
    should Match Regexp    ${res1}    (\\d*\.\\d*\.\\d*\.\\d)
    Should contain    ${res2}    ${connection_status}
    Should contain    ${res3}    ${synchronize_status}
    Should contain    ${res4}    ${source_status}

get_device_clock
    [Arguments]    ${device}
    ${result}    cli    ${device}    show clock
    ${time}    Get Regexp Matches    ${result}    (\\d\\d\\d\\d-\\d\\d-\\d\\d\\s+\\d\\d:\\d\\d:\\d\\d)
    [Return]    ${time}[0]
    
check sensors fan low
    [Arguments]    ${device}    ${max_speed}
    ${result}    cli    ${device}    show sensors fan
    : FOR    ${n}    IN RANGE    1    ${fan_num}+1
    \    ${match}    ${speed}    should Match Regexp    ${result}    fan-${n}.*\\s+(\\d+)\\s+%
    \    should be true    ${speed}<${max_speed}