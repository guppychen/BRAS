*** Settings ***
Documentation    test_suite keyword lib

*** Keywords ***

Check system time equal hardware time

    [Arguments]    ${device}    ${changetime}
    [Documentation]    check system time and hardware time date = hwclock
    ${res1}    Get DateTime    ${device}
    ${res2}    convert Date    ${res1}    epoch
    ${res3}    Get hwclock Time with Changetime    ${device}    ${changetime}
    ${res4}    convert Date    ${res3}    epoch
    should be true   abs(${res4}- ${res2})<15

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
    should Match Regexp      ${res1}    (\\d*\.\\d*\.\\d*\.\\d)
    Should contain    ${res2}    ${connection_status}
    Should contain    ${res3}    ${synchronize_status}
    Should contain    ${res4}    ${source_status} 

get_ntp_config
    [Arguments]    ${device}
    ${result}    cli    ${device}   show running-config ntp | detail

get time diff
    [Documentation]   get the timezone different from PST time, the diff will be different in summer or winter clock
    [Tags]    @author=chxu
    [Arguments]    ${wintertimediff}
    ${date} =	Get Current Date
    ${date} =	Convert Date	${date}	 datetime
    log    ${date}
    ${summertimediff}      evaluate  ${wintertimediff}+1
    ${cur_month}     convert to integer    ${date.month}
    ${cur_day}     convert to integer    ${date.day}
    ${timezonediff}      set variable if
    ...        3 < ${cur_month} < 11    ${summertimediff}
    ...           ${cur_month} == ${11} and ${cur_day} <=7    ${summertimediff}
    ...           ${cur_month} == ${3} and ${cur_day} >=11    ${summertimediff}
    ...           ${wintertimediff}    # Add by AT-5721
    [Return]   ${timezonediff}

