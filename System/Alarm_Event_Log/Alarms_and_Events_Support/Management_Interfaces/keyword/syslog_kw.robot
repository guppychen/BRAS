*** Settings ***
Resource          caferobot/cafebase.robot
Library           Collections
Library           String

*** Keywords ***
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

Configure syslog server
    [Arguments]    ${session}    ${ip_address}    @{items}
    [Documentation]    Keyword for configuring a syslog server
    ...    Example:
    ...    Configure syslog server    n1    10.243.10.10  admin-state=ENABLED  log-level=WARN  port=514  Transport=UDP
    [Tags]    @author=sdas
    cli    ${session}    configure
    : FOR    ${arg}    IN    @{items}
    \    ${key}    ${value}=    Evaluate    "${arg}".split("=")
    \    Log    ${key}, ${value}
    \    cli    ${session}    logging host ${ip_address} ${key} ${value}     \\#    30
    cli    ${session}    end
    cli    ${session}    show logging host | nomore    \\#    30
    result should contain    ${ip_address}

Remove syslog server
    [Arguments]    ${session}  ${ip_address}
    [Documentation]    Keyword to remove syslog server
    ...    Example:
    ...    Remove syslog server    n1    10.243.10.10
    [Tags]    @author=sdas
    cli    ${session}    configure
    cli    ${session}    no logging host ${ip_address}    \\#    30
    cli    ${session}    end
    cli    ${session}    show logging host | nomore    \\#    30
    result should not contain    ${ip_address}

Capture syslog
    [Arguments]    ${session1}    ${session2}    ${protocol}    ${interface}    ${filename}     ${event}   ${password}=${DEVICES.h1.password}
    [Documentation]    Key word for generating syslog event
    ...    Example:
    ...    Capture syslog    syslog_server1    n1_session1    tcp    1/1/gp2    syslog_file    shut
    [Tags]    @author=gpalanis

    cli    ${session1}    sudo ls -ltr    prompt=(password|\$)    timeout=30
    cli    ${session1}    ${password}
    # Added sleep as previous TC files are impacting the run
    sleep    10
    cli    ${session1}    sudo tail -f /var/log/syslog/syslog.log | awk '{ print strftime("%c: "), $0; fflush(); }' > /tmp/${filename}

    run keyword if    '${event}' == 'shut'    run keywords
    ...    Unshut Interface    ${session2}    ${protocol}    ${interface}  AND
    ...    Shut Interface    ${session2}    ${protocol}    ${interface}  AND
    ...    sleep    5  AND
    ...    cli    ${session1}    \x03

    run keyword if  '${event}' == 'ont-status'  run keywords
    ...    cli    ${session2}    show ont-upgrade status|nomore    AND
    ...    sleep    5  AND
    ...    cli    ${session1}    \x03

    cli    ${session1}    \x03


Verify syslog
    [Arguments]    ${session1}  ${session2}  ${log_file}  ${int_type}  ${log_filter}  ${transport_protocol}
    ...    ${transport_port}  ${log_server}  ${log_code}  ${log_value}  ${log_fc}  ${event_name}
    ...    ${ID}  ${Category}
    [Documentation]    This KW verifies log level, facility code, event name, category, int port,
    ...    interface type, time of event
    ...    Example:
    ...    Verify syslog  syslog_server1  n1_session1  syslog_file   pon  1/1/gp2  tcp  514
    ...    syslog  0  ALERT  23  Improper-Removal   1203   PORT
    [Tags]    @author=clakshma

    # Step 1
    # Retrieve the configured details from show logging host command
    ${show_run}  cli    ${session2}    show logging host | nomore    \\#    30
    ${res}    Build Response Map    ${show_run}
    @{res}    caferobot.resp.responsemap.ResponseMapAdapter.Parse Table    ${res}    2    \\s+
    ${length}    Get Length    ${res}
    log dictionary    @{res}[0]

    # Validate if all fields are configured correctly
    ${result}    set variable    0
    : FOR    ${index}   IN RANGE    0    ${length}
    \    log many    ${res[${index}]['NAME']}    ${res[${index}]['LEVEL']}    ${res[${index}]['PORT']}    ${res[${index}]['STATE']}    ${res[${index}]['TRANSPORT']}
    \    log many    ${log_server}    ${log_value}    ${transport_port}    ${transport_Protocol}
    \    Run Keyword If    '${res[${index}]['NAME']}' == '${log_server}' and '${res[${index}]['LEVEL']}' == '${log_value}' and '${res[${index}]['PORT']}' == '${transport_port}' and '${res[${index}]['STATE']}' == 'ENABLED' and '${res[${index}]['TRANSPORT']}' == '${transport_Protocol}'
    \    ...    set test variable    ${result}    1
    \    ...    ELSE    Continue For Loop
    \    Exit For Loop

    # Pass the verification if all the parameters in the above Run Keyword If are validated
    Run Keyword If    ${result} != 1    Fail    "Failed - logging host not configured correctly"

    # Step 2
    # Retrieve the severity code, facility code and Event name from the syslog file for verification
    command    ${session1}    cd /var/log/syslog
    #Copy the data into a new file as we dont have permission to get the syslog.log file
    command    ${session1}    sudo cp syslog.log sys.log    timeout_exception=0
    command    ${session1}    ${DEVICES.h1.password}    timeout_exception=0
    command    ${session1}    ll
    command    ${session1}    pwd
    command    ${session1}    sudo chmod 777 sys.log    timeout_exception=0
    command    ${session1}    ${DEVICES.h1.password}    timeout_exception=0
    ${output}    Cli    ${session1}    cat /var/log/syslog/sys.log | grep "Name" | grep "${DEVICES.n1_session1.ip}" | tail -n 30    \\$    30
    @{res}    Split To Lines    ${output}    1
    ${length}    Get Length    ${res}
    ${length}    Evaluate    ${length} - 1
    ${result1}    set variable    False
    :FOR   ${index}    ${line}     IN ENUMERATE    @{res}
    \    Run Keyword If    '${index}' == '${length}'    Exit For Loop
    \    @{match}    Should Match Regexp    ${line}    (\\d),(\\d{1,2}).*(Id:\\d{0,4}).*(Name:\\S+).*(Category:\\w+).*Xpath(.*)
    \    log list    ${match}
    \    log many    ${log_code}    ${event_name}    ${log_filter}    ${int_type}    ${ID}    ${Category}
    \    Should be true    @{match}[1] < ${log_code} or @{match}[1] == ${log_code}
    \    Should be true    @{match}[2] == ${log_fc}
    \    Run Keyword If    '${ID}' in '''@{match}[3]''' and '${event_name}' in '''@{match}[4]''' and '${Category}' in '''@{match}[5]''' and '${log_filter}' in '''@{match}[6]''' and '${int_type}' in '''@{match}[6]'''    set test variable    ${result1}    True
    # Check if Event name and filter applied matched with syslog events
    Run Keyword If    ${result1} != True    Fail

Verify syslog for 119
    [Arguments]    ${session1}  ${session2}  ${log_file}  ${int_type}  ${log_filter}  ${transport_protocol}
    ...    ${transport_port}  ${log_server}  ${log_code}  ${log_value}  ${log_fc}  ${event_name}
    ...    ${ID}  ${Category}
    [Documentation]    This KW verifies log level, facility code, event name, category, int port,
    ...    interface type, time of event
    ...    Example:
    ...    Verify syslog  syslog_server1  n1_session1  syslog_file   pon  1/1/gp2  tcp  514
    ...    syslog  0  ALERT  23  Improper-Removal   1203   PORT
    [Tags]    @author=clakshma

    # Step 1
    # Retrieve the configured details from show logging host command
    ${show_run}  cli    ${session2}    show logging host | nomore    \\#    30
    ${res}    Build Response Map    ${show_run}
    @{res}    caferobot.resp.responsemap.ResponseMapAdapter.Parse Table    ${res}    2    \\s+
    ${length}    Get Length    ${res}
    log dictionary    @{res}[0]

    # Validate if all fields are configured correctly
    ${result}    set variable    0
    : FOR    ${index}   IN RANGE    0    ${length}
    \    log many    ${res[${index}]['NAME']}    ${res[${index}]['LEVEL']}    ${res[${index}]['PORT']}    ${res[${index}]['STATE']}    ${res[${index}]['TRANSPORT']}
    \    log many    ${log_server}    ${log_value}    ${transport_port}    ${transport_Protocol}
    \    Run Keyword If    '${res[${index}]['NAME']}' == '${log_server}' and '${res[${index}]['LEVEL']}' == '${log_value}' and '${res[${index}]['PORT']}' == '${transport_port}' and '${res[${index}]['STATE']}' == 'ENABLED' and '${res[${index}]['TRANSPORT']}' == '${transport_Protocol}'
    \    ...    set test variable    ${result}    1
    \    ...    ELSE    Continue For Loop
    \    Exit For Loop

    # Pass the verification if all the parameters in the above Run Keyword If are validated
    Run Keyword If    ${result} != 1    Fail    "Failed - logging host not configured correctly"

    # Step 2
    # Retrieve the severity code, facility code and Event name from the syslog file for verification
    command    ${session1}    cd /var/log/syslog
    #Copy the data into a new file as we dont have permission to get the syslog.log file
    command    ${session1}    sudo cp syslog.log sys.log    timeout_exception=0
    command    ${session1}    ${DEVICES.h1.password}    timeout_exception=0
    command    ${session1}    ll
    command    ${session1}    pwd
    command    ${session1}    sudo chmod 777 sys.log    timeout_exception=0
    command    ${session1}    ${DEVICES.h1.password}    timeout_exception=0
    ${output}    Cli    ${session1}    cat /var/log/syslog/sys.log | grep "Name" | grep "NGPON2X4" | tail -n 30    \\$    30
    @{res}    Split To Lines    ${output}    1
    ${length}    Get Length    ${res}
    ${length}    Evaluate    ${length} - 1
    ${result1}    set variable    False
    :FOR   ${index}    ${line}     IN ENUMERATE    @{res}
    \    Run Keyword If    '${index}' == '${length}'    Exit For Loop
    \    @{match}    Should Match Regexp    ${line}    (Id:\\d{0,4}).*(Name:\\S+).*(Category:\\w+).*Xpath(.*)
    \    log list    ${match}
    \    log many    ${log_code}    ${event_name}    ${log_filter}    ${int_type}    ${ID}    ${Category}
#    \    Should be true    @{match}[1] < ${log_code} or @{match}[1] == ${log_code}
#    \    Should be true    @{match}[2] == ${log_fc}
    \    Run Keyword If    '${ID}' in '''@{match}[1]''' and '${event_name}' in '''@{match}[2]''' and '${Category}' in '''@{match}[3]''' and '${log_filter}' in '''@{match}[4]''' and '${int_type}' in '''@{match}[4]'''    set test variable    ${result1}    True
    # Check if Event name and filter applied matched with syslog events
    Run Keyword If    ${result1} != True    Fail


