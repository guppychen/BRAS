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
    [Arguments]    ${device}    ${server_ip}    ${connection_status}    ${synchronize_status}    ${source_status}=${EMPTY}
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

