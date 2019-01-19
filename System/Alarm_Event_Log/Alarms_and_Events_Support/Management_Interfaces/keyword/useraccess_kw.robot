*** Settings ***
Resource          caferobot/cafebase.robot
Library           Collections
Library           String
Library           DateTime
Library      XML    use_lxml=True


*** Keywords ***
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
    log    ${output.xml}
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
    ${elem}    Get Element Text    web  xpath=//html
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
    ...    ELSE    should match regexp    ${output}    hostname ([0-9a-zA-Z\\s\-]+)
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
