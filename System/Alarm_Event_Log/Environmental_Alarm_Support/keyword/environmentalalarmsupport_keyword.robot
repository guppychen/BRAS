*** Settings ***
Documentation    test_suite keyword lib

*** Variable ***


*** Keywords ***
prov_environment_alarm
    [Arguments]    ${device}    ${alarm_name}    &{dict_cmd}
    [Documentation]    provision environment-alarm
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | alarm_name | environment-alarm name |
    ...    | dict_cmd | more option |
    ...    Example:
    ...    | prov_environment_alarm | n1 | al1 | admin-state=enable | alarm-severity=INFO |

    [Tags]    @author=AnneLi
    cli    ${device}    configure
    cli    ${device}    environment-alarm input ${alarm_name}
    ${cmd_str}    convert_dictionary_to_string    &{dict_cmd}
    run keyword if    '${cmd_str}'!='${EMPTY}'    Axos Cli With Error Check    ${device}    ${cmd_str}
    [Teardown]    cli    ${device}    end

#change as AT-5133
dprov_environment_alarm
    [Arguments]    ${device}    ${alarm_name}
    [Documentation]    provision environment-alarm
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | alarm_name | environment-alarm name |
    ...    Example:
    ...    | dprov_environment_alarm | n1 | al1 |
    [Tags]    @author=AnneLi
    cli    ${device}    configure
    cli    ${device}    no environment-alarm input ${alarm_name}
    [Teardown]    cli     ${device}    end

dprov_environment_alarm2
    [Arguments]    ${device}    ${name}    @{cmd_list}
    [Documentation]    provision environment-alarm
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | name | environment-alarm name |
    ...    | cmd_list | more option |
    ...    Example:
    ...    | dprov_environment_alarm | n1 | al1 | admin-state | alarm-severity |

    [Tags]    @author=AnneLi
    cli    ${device}    configure
    cli    ${device}    environment-alarm input ${name}
    : FOR    ${element}    IN    @{cmd_list}
    \    ${cmd_string}    set variable     no ${element}
    \    Axos Cli With Error Check    ${device}    ${cmd_string}
    [Teardown]    cli     ${device}    end




check_alarm_active_by_subscpoe_insance_id
    [Arguments]    ${device}    ${instance_id}    &{dict}
    [Documentation]    show alarm active subscope instance-id
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | instance_id | instanc id |
    ...    | dict | more option |
    ...    Example:
    ...    | check_alarm_active_by_subscpoe_insance_id | n1 | 21.61 | name=environment-input| alarm-type =ENVIRONMENTAL |
    [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show alarm active subscope instance-id ${instance_id}
    @{list_key}    Get Dictionary Keys    ${dict}
    : FOR    ${key}    IN    @{list_key}
    \    ${value}    Get From Dictionary    ${dict}    ${key}
    \    ${res1}    Get Lines Containing String    ${result}    ${key}
    \    Should contain    ${res1}    ${value}


check_environment_alarm_active
    [Arguments]    ${device}    ${alarm_name}
    [Documentation]    show alarm active and environment alarn exist
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | alarm_severity | environment alarm pin's alarm severity |
    ...    | alarm_name | environment alarm pin's name |
    ...    Example:
    ...    | check_alarm_active_environment_input | eutA | AL2 |

    [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show alarm active
    should match regexp    ${result}    name\\s*environment-input\\s*instance-id\\s*\\d+.\\d+\\s*perceived-severity\\s*\\w*\\s*category\\s*ENVIRONMENTAL\\s*address\\s*\\/config\\/system\\/environment-alarm\\/input\\[name='${alarm_name}'\\]
    ${temp}    get regexp matches    ${result}     name\\s*environment-input\\s*instance-id\\s*(\\d+.\\d+)\\s*perceived-severity\\s*\\w*\\s*category\\s*ENVIRONMENTAL\\s*address\\s*\\/config\\/system\\/environment-alarm\\/input\\[name='${alarm_name}'\\]    1
    [Return]    ${temp[0]}
# name environment-input instance-id 21.63 perceived-severity MAJOR category ENVIRONMENTAL address /config/system/environment-alarm/input[name='AL2']


check_environment_alarm
    [Arguments]    ${device}    ${alarm_name}    ${label}=${EMPTY}    ${admin_state}=${EMPTY}    ${alarm_severity}=${EMPTY}
    ...    ${contact_type}=${EMPTY}    ${alarm}=${EMPTY}    ${external_contact}=${EMPTY}
    [Documentation]    show environment-alarm
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | alarm_name | environment alarm pin's name |
    ...    | label | label |
    ...    | admin_state | admin state |
    ...    | alarm_severity | alarm severity |
    ...    | contact_type | contact type |
    ...    | external_contact | external contact |
    ...    Example:
    ...    | check_evironment_alarm | AL1 | fire | disable | MINOR | normally-closed | open |
    ...    | check_evironment_alarm | AL1 | fire | disable | MINOR | normally-closed |
    [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show environment-alarm
    ${res1}    Get Lines Containing String    ${result}    ${alarm_name}
    ${temp}    get regexp matches    ${res1}    ${alarm_name}\\s+(\\w+-*\\w*-*\\w*)\\s+(\\w+)\\s+(\\w+)\\s+(\\w+-\\w+)\\s+(\\w+)\\s+(\\w+)    1    2    3    4    5    6
    ${temp}    set Variable      ${temp[0]}
    ${label1}    set Variable      ${temp[0]}
    ${admin_state1}    set Variable    ${temp[1]}
    ${alarm_severity1}    set Variable    ${temp[2]}
    ${contact_type1}    set Variable    ${temp[3]}
    ${alarm1}    set Variable    ${temp[4]}
    ${external_contact1}    set Variable    ${temp[5]}
    run keyword if    '${label}'!='${EMPTY}'    Should Be Equal    ${label1}    ${label}
    run keyword if    '${admin_state}'!='${EMPTY}'    Should Be Equal    ${admin_state1}    ${admin_state}
    run keyword if    '${alarm_severity}'!='${EMPTY}'    Should Be Equal    ${alarm_severity1}    ${alarm_severity}
    run keyword if    '${contact_type}'!='${EMPTY}'    Should Be Equal    ${contact_type1}    ${contact_type}
    run keyword if    '${alarm}'!='${EMPTY}'    Should Be Equal    ${alarm1}    ${alarm}
    run keyword if    '${external_contact}'!='${EMPTY}'    Should Be Equal    ${external_contact1}    ${external_contact}




check_running_config_environment_alarm
    [Arguments]    ${device}    ${alarm_name}    &{dict}
    [Documentation]    show running-configure of environment-alarm
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | alarm_name | environment alarm input of pin's name |
    ...    Example:
    ...    | check_environment_alarm_config_input | al1 | label=fire | alarm-sevrity=INOF |
    [Tags]    @author=PEIJUN LIU
    ${cmd_str}    Set Variable    show running-config environment-alarm input ${alarm_name} | details
    ${result}    CLI    ${device}    ${cmd_str}
    @{list_key}    Get Dictionary Keys    ${dict}
    : FOR    ${key}    IN    @{list_key}
    \    ${value}    Get From Dictionary    ${dict}    ${key}
    \    ${res1}    Get Lines Containing String    ${result}    ${key}
    \    Should contain    ${res1}    ${value}

check_environment_alarm_active_iscleared
    [Arguments]    ${device}    ${alarm_name}
    [Documentation]    show alarm active and environment alarm is cleared
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | alarm_name | environment alarm pin's name |
    ...    Example:
    ...    | check_alarm_active_environment_input | eutA | AL2 |

    [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show alarm active
    Should Not Contain    ${result}    ${alarm_name}

check_alarm_history
    [Arguments]    ${device}    @{cmd_list}
    [Documentation]    show alarm history
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    Example:
    ...    | check_alarm_active_environment_input | eutA | AL1 | AL2 | AL3 |

    [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show alarm history
    : FOR    ${element}    IN    @{cmd_list}
    \    should match regexp    ${result}    instance-id\\s*\\d+.\\d+\\s*name\\s*environment-input\\s*perceived-severity\\s*CLEAR\\s*category\\s*ENVIRONMENTAL\\s*address\\s*\\/config\\/system\\/environment-alarm\\/input\\[name='${element}'\\]
    \    should match regexp    ${result}    instance-id\\s*\\d+.\\d+\\s*name\\s*environment-input\\s*perceived-severity\\s*\\w*\\s*category\\s*ENVIRONMENTAL\\s*address\\s*\\/config\\/system\\/environment-alarm\\/input\\[name='${element}'\\]
#    instance-id 180.863 name environment-input perceived-severity CLEAR category ENVIRONMENTAL address /config/system/environment-alarm/input[name='AL2']
