*** Settings ***
Resource    ../base.robot
Resource          caferobot/cafebase.robot
Library           Collections
Library           String
Library           DateTime
Library      XML    use_lxml=True


*** Keywords ***

Prov_syslog_server
    [Arguments]    ${session}    ${ip_address}    &{items}
    [Documentation]    Keyword for configuring a syslog server
    ...    Example:
    ...    Configure syslog server    n1    10.243.10.10  admin-state=ENABLED  log-level=WARN  port=514  Transport=UDP
    [Tags]    @author=sdas
    cli    ${session}    configure
    Axos Cli With Error Check    ${session}    logging host ${ip_address}
    ${cmd_str}    convert_dictionary_to_string    &{items}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${session}    ${cmd_str}
    [Teardown]    cli    ${session}    end


dprov_syslog_server
    [Arguments]    ${session}    ${ip_address}    ${delete_server}=YES    @{list}
    [Documentation]    Keyword to remove syslog server
    ...    Example:
    ...    Remove syslog server    n1    10.243.10.10
    [Tags]    @author=sdas
    cli    ${session}    configure
    Axos Cli With Error Check    ${session}    logging host ${ip_address}
    : FOR    ${key}   IN    @{list}
    \    run keyword if    '${key}'!='${EMPTY}'   Axos Cli With Error Check    ${session}    no ${key}
    Axos Cli With Error Check    ${session}    top
    run keyword if    '${delete_server}'=='YES'    Axos Cli With Error Check    ${session}    no logging host ${ip_address}
    [Teardown]    cli    ${session}    end



check_logging_config
    [Arguments]    ${device}    ${ip_address}    ${protocol}=${EMPTY}    ${port}=${EMPTY}    ${level}=${EMPTY}    ${status}=${EMPTY}
    [Documentation]    Keyword to check syslog server configuration
    [Tags]    @author=Ronnie_yi
    ...    Example:
    ...    check_logging_config   n1    10.243.10.10
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    cli show-defaults enable
    cli    ${device}    end
    sleep    5s
    ${tmp}    Axos Cli With Error Check    ${device}    show running-config logging host ${ip_address}
    run keyword if    '${protocol}'!= '${EMPTY}'    should match regexp    ${tmp}    transport\\s+${protocol}
    run keyword if    '${port}'!= '${EMPTY}'    should match regexp    ${tmp}    port\\s+${port}
    run keyword if    '${level}'!= '${EMPTY}'    should match regexp    ${tmp}    log-level\\s+${level}
    run keyword if    '${status}'!= '${EMPTY}'    should match regexp    ${tmp}    admin-state\\s+${status}
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    cli show-defaults disable
    [Teardown]    cli    ${device}    end

check_log_result
    [Arguments]    ${device}    ${log_path}    ${name}    ${expect_result}
    [Documentation]    Keyword to check syslog content
    [Tags]    @author=Ronnie_yi
    ...    Example:
    ...    check_log_result   h1    should contain    NGPON2X4
    sleep    5s
    ${tmp}    cli    ${device}    cat ${log_path}${name}.log
    should match regexp    ${tmp}    ${expect_result}

check_log_empty_file
    [Arguments]    ${device}    ${path}    ${name}    ${content}
    [Documentation]    Keyword to check syslog content
    [Tags]    @author=Ronnie_yi
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | path | log path |
    ...    | name | log file name |
    ...    | content | card type |
    ...    Example:
    ...    check_log_result   h1    ./    log    NGPON2X4
    ${tmp}    cli    h1    cat ${path}${name}.log
    should not contain    ${tmp}    ${content}


clear_log_file
    [Arguments]    ${device}    ${path}    ${name}    ${content}
    [Documentation]    Keyword to check syslog content
    [Tags]    @author=Ronnie_yi
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | path | log path |
    ...    | name | log file name |
    ...    | content | card type |
    ...    Example:
    ...    check_log_result   h1    ./    log    NGPON2X4
    cli    ${device}    echo > ${path}${name}.log
    sleep    5s
    check_log_empty_file    ${device}    ${path}    ${name}    ${content}
