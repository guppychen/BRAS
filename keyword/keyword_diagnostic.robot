*** Settings ***
Documentation    keywords for diagnostic


*** Variables ***


*** Keywords ***
dcli_show_g8032_owner_timmer
    [Arguments]    ${root_device}    ${ring_id}
    [Tags]    @author=llin
    [Documentation]     dcli erpsd show ring-instance ring-id xxx show-opt-attr timers
    # should make sure it is in the root view.
    cli      ${root_device}       pwd
    # send debug command
    ${ring_id}    convert to integer   ${ring_id}
    cli    ${root_device}    dcli erpsd show ring-instance ring-id ${ring_id} show-opt-attr timers


dcli_show_g8032_owner_debug
    [Arguments]    ${root_device}    ${ring_id}
    [Tags]    @author=llin
    [Documentation]     dcli erpsd show ring-instance ring-id xxx show-opt-attr debug
    # should make sure it is in the root view.
    ${ring_id}    convert to integer   ${ring_id}
    # send debug command
    cli    ${root_device}    dcli erpsd show ring-instance ring-id ${ring_id} show-opt-attr debug


dcli_show_g8032_owner_history
    [Arguments]    ${root_device}    ${ring_id}
    [Tags]    @author=llin
    [Documentation]     dcli erpsd show ring-instance ring-id xxx show-opt-attr history
    # should make sure it is in the root view.
    ${ring_id}    convert to integer   ${ring_id}
    # send debug command
    cli    ${root_device}    dcli erpsd show ring-instance ring-id ${ring_id} show-opt-attr history


dcli_show_g8032_owner_stat_log
    [Arguments]    ${root_device}    ${ring_id}
    [Tags]    @author=llin
    [Documentation]     dcli erpsd show ring-instance ring-id xxx show-opt-attr state-log
    # should make sure it is in the root view.
    ${ring_id}    convert to integer   ${ring_id}
    # send debug command
    cli    ${root_device}    dcli erpsd show ring-instance ring-id ${ring_id} show-opt-attr state-log

diagnostic_g8032
    [Arguments]    @{args}
    [Tags]    @author=llin
    [Documentation]     debug for g8032 status if you need.
    ...   diagnostic_g8032    eutA    ringId    eutB   ringId

    log    Calling diagnostic_g8032 keyword start ...

    ${len}   set variable   0
    :FOR  ${para}   IN   @{args}
    \     log     ${para}
    \     ${len}=    evaluate   ${len} + 1
    log   the parameter length is:${len}


    ${index}    set variable  0
    :FOR  ${item}   IN   @{args}
    \    ${arg1}    set variable  ${args[${index}]}
    \    ${arg2}    set variable  ${args[${index} + 1]}
    \    dcli_show_g8032_owner_timmer      ${arg1}    ${arg2}
    \    dcli_show_g8032_owner_debug      ${arg1}    ${arg2}
    \    dcli_show_g8032_owner_history      ${arg1}    ${arg2}
    \    dcli_show_g8032_owner_stat_log      ${arg1}    ${arg2}
    \    ${index}    set variable    ${index} + 2
    \    exit for loop if  ${index} >= ${len}

    log    Calling diagnostic_g8032 keyword end ...
