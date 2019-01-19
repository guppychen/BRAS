*** Settings ***
Resource          caferobot/cafebase.robot
Library           Collections
Library           String


*** Keywords ***
Check ARC Registration
    [Arguments]    ${session}    ${manager}
    [Documentation]    Check arc registration
    ...    Example:
    ...    Check ARC Registration
    [Tags]    @author=gpalanis
    cli     ${session}    dcli arcmgrd dump summary    \\~#    30
    Result should contain    ${manager}

Get ARC process
    [Arguments]    ${session}   ${parameter1}    ${parameter2}
    [Documentation]    Retrieve ARC process
    ...    Example:
    ...    Get ARC process  n2   Manager   diagmgrd
    [Tags]    @author=clakshma
    ${output}    cli     ${session}    dcli arcmgrd dump summary    \\~#    30
    ${res}    Build Response Map    ${output}
    @{res}    caferobot.resp.responsemap.ResponseMapAdapter.Parse Table    ${res}    2    \\s+
    log dictionary    @{res}[0]
    ${length}    set variable    0
    : FOR    ${ele}    IN    @{res}
    \    ${length}    Run Keyword If    '${res[${length}]['${parameter1}']}' == 'Used/Total'    Exit For Loop
    \    ...    ELSE    Evaluate    ${length}+1
    log    ${length}
    : FOR    ${index}   IN RANGE    0    ${length}
    \    Wait Until Keyword Succeeds    2 min    5 sec    Check PID    ${session}    ${res[${index}]['${parameter1}']}
    \    Wait Until Keyword Succeeds    2 min    5 sec    Check MEM    ${session}    ${res[${index}]['${parameter1}']}

    ${output}    cli     ${session}    dcli arcmgrd dump summary    \\~#    30
    ${res}    Build Response Map    ${output}
    @{res}    caferobot.resp.responsemap.ResponseMapAdapter.Parse Table    ${res}    2    \\s+
    log dictionary    @{res}[0]
    : FOR    ${index}   IN RANGE    0    ${length}
    \    log    ${res[${index}]['${parameter1}']}
    \    &{result}    Run Keyword If    '${res[${index}]['${parameter1}']}' == '${parameter2}'
    \    ...    Remove From List    ${res}    ${index}
    \    ...    ELSE    Continue For Loop
    \    Exit For Loop
    log list    ${res}    level=DEBUG
    log dictionary    ${result}
    [Return]    ${res}    ${result}

Restart ARC process
    [Arguments]    ${session}   ${parameter1}    ${parameter2}
    [Documentation]    Restart ARC process
    ...    Example
    ...    Restart ARC process    n2    diagmgrd    diagmgr
    [Tags]    @author=clakshma
    ${pid}     cli     ${session}    dcli arcmgrd dump summary | grep -i ${parameter1} | awk '{print $2}'    \\~#    30
    ${pid}     Get Line    ${pid}    1
    ${res}    cli    ${session}    /etc/init.d/${parameter2}
    Run Keyword if    'stop' in '''${res}'''    cli    ${session}    /etc/init.d/${parameter2} stop    \\~#    60
    ...    ELSE    cli    ${session}    kill -9 ${pid}
    Wait Until Keyword Succeeds    5 min    5 sec    Check PID    ${session}    ${parameter1}
    Wait Until Keyword Succeeds    2 min    5 sec    Check MEM    ${session}    ${parameter1}
    cli     ${session}    ls -ltr /FLASH/persist/core


Check PID
    [Arguments]    ${session}   ${parameter1}
    [Documentation]    Check if PID process is up
    ...    Example
    ...    Check PID    n2    diagmgrd
    [Tags]    @author=clakshma
    ${pid}     cli     ${session}    dcli arcmgrd dump summary | grep -i ${parameter1} | awk '{print $2}'    \\~#    30
    ${pid}     Get Line    ${pid}    1
    Should be true    ${pid} > 0

Check MEM
    [Arguments]    ${session}   ${parameter1}
    [Documentation]    Check if MEM is greater than 0
    ...    Example
    ...    Check MEM    n2    diagmgrd
    [Tags]    @author=clakshma
    ${mem}     cli     ${session}    dcli arcmgrd dump summary | grep -i ${parameter1} | awk '{print $6}'    \\~#    30
    ${mem}     Get Line    ${mem}    1
    Should be true    ${mem} > 0

Validate ARC process
    [Arguments]    ${session}    ${arcmgrs_before}     ${arcmgrs_after}    ${module}
    [Documentation]    Validates if 2 list of dictionaries i.e ARC processes before and afterare equal
    ...    Example
    ...    Validate ARC process    ${list1}    ${list2}
    [Tags]    @author=clakshma
    ${len}    Get Length    ${arcmgrs_before}
    ${len}    Evaluate    ${len}-3
    : FOR    ${index}   IN RANGE    0    ${len}
    \    ${mod}    Get From Dictionary    @{arcmgrs_before}[${index}]    Manager
    \    ${mem1}    Pop From Dictionary    @{arcmgrs_before}[${index}]    Mem(KB)
    \    ${mem1}    Evaluate    ${mem1}+(${mem1}/2)
    \    ${mem2}    Pop From Dictionary    @{arcmgrs_after}[${index}]    Mem(KB)
    \    run keyword if    ${mem1} < ${mem2}    Wait Until Keyword Succeeds    1min    10s    check ARC mem    ${session}    ${index}    ${module}    ${mem1}
    \    Remove From Dictionary    @{arcmgrs_before}[${index}]    HB    CPU
    \    Remove From Dictionary    @{arcmgrs_after}[${index}]    HB    CPU
    \    log dictionary    @{arcmgrs_before}[${index}]
    \    log dictionary    @{arcmgrs_after}[${index}]
    \    run keyword if    '${mod}' != 'confd' and '${mod}' != 'rsyslogd'   Dictionaries Should Be Equal    @{arcmgrs_before}[${index}]    @{arcmgrs_after}[${index}]
    # \    Should be true    ${mem1} > ${mem2}

check ARC mem
    [Arguments]    ${session}    ${index}    ${module}    ${mem1}
    [Documentation]    check mem after restart won't be lager than before
    [Tags]    @author=cgao
    log    ${index}
    ${mgrs_after}    ${after}    Get ARC process    ${session}    Manager    ${module}
    ${module2}    Get From Dictionary    @{mgrs_after}[${index}]    Manager
    ${mem2}    Pop From Dictionary    @{mgrs_after}[${index}]    Mem(KB)  
    Should be true    ${mem1} > ${mem2}  

Validate ARC process restart
    [Arguments]    ${mgr_before_restart}     ${mgr_after_restart}
    [Documentation]    Validate if values of ARC manager are restarted correctly
    ...    Example
    ...    Validate ARC process restart    ${dict1}    ${dict2} 
    [Tags]    @author=clakshma
    ${pid1}    Get From Dictionary    ${mgr_before_restart}    Pid
    ${pid2}    Get From Dictionary    ${mgr_after_restart}    Pid
    Should Not Be Equal As Numbers    ${pid1}     ${pid2}
    ${run1}    Get From Dictionary    ${mgr_before_restart}    Run#
    ${run1}    evaluate    ${run1} + 1
    ${run2}    Get From Dictionary    ${mgr_after_restart}    Run#
    Should be true    ${run2} == ${run1}
    ${mem1}    Get From Dictionary    ${mgr_before_restart}    Mem(KB)
    ${mem1}    Evaluate    ${mem1}+(${mem1}/2)
    ${mem2}    Get From Dictionary    ${mgr_after_restart}    Mem(KB)
    #${mem}    evaluate    ${mem2} - ${mem1}
    Should be true    ${mem1} > ${mem2}

Validate ARC Restart event
    [Arguments]    ${session}     ${manager}
    [Documentation]    Validate the ARC Restart event
    ...    Example:
    ...    Validate ARC Restart status  n1    mgr-name
    [Tags]    @author=clakshma
    Wait Until Keyword Succeeds    1 min    5 sec    cli    ${session}    show event detail | begin arcmgrd | until "event "    \\#    30
    Result should contain    ${manager}
    Result Match Regexp    unexpected-exit\|not-running
    Result should contain    ARC

Restart ssh process
    [Arguments]    ${session}    ${local_session}    ${device_ip}    ${parameter1}    ${parameter2}
    [Documentation]  
    ...    Example:
    ...    Restart ssh process    n2    h1    ${DEVICES.n2.ip}
    [Tags]    @author=clakshma
    ${pid}     cli     ${session}    dcli arcmgrd dump summary | grep -i ${parameter1} | awk '{print $2}'    \\~#    30
    ${pid}     Get Line    ${pid}    1
    Run Keyword And Expect Error    ShellTimeoutException    cli    ${session}    /etc/init.d/${parameter2} stop
    wait until keyword succeeds    5 min    30 sec    ARC_kw.ping_device    ${local_session}    ${device_ip}
    Wait Until Keyword Succeeds    2 min    5 sec    Check PID    ${session}    ${parameter1}

ping_device
    [Arguments]    ${session}    ${device_ip}    ${timeout}=30
    [Documentation]  Check if DPU is reachable
    ...    Example:
    ...    ping_device    h1    ${DEVICES.n1_session1.ip}
    [Tags]    @author=clakshma
    ${ret} =    Session Command    h1    ${SPACE}
    ${prompt} =    get last command prompt    h1
    ${prompt} =    regexp escape  ${prompt}
    ${res}    cli    ${session}    ping ${device_ip} -c 4    ${prompt}    ${timeout}
    should Match Regexp      ${res}    ,\\s0% packet loss
