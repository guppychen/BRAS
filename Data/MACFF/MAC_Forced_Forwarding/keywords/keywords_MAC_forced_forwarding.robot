*** Settings ***
Resource          ../base.robot



*** Keywords ***
wait_mff_dynamic_host_table
    [Documentation]  this is the keyword to wait the MFF dynamic host take effort, to fix issue AT-3139
    ...  l3-host 2111 172.30.101.1
    ...  interface     1/1/x3
    ...    mac           00:06:f6:f1:1d:c2
    ...    host-type     mff-dynamic
    ...    up-down-state up
    [Tags]     @author=llin
    [Arguments]          ${device}      ${interface}
    log    wait the MFF dynamic host take effor
    cli       ${device}      end
    wait until keyword succeeds      1 min      3 sec      get_l3_host     ${device}      ${interface}

get_l3_host
    [Documentation]  this is the keyword to get l3 host prepare for keyword wait_mff_dynamic_host_table , to fix issue AT-3139
    [Tags]     @author=llin
    [Arguments]          ${device}      ${interface}
    ${res}    cli    ${device}    show l3-host
    should Match Regexp      ${res}      interface\\s*${interface}\\s*\\n
    [Return]    ${res}
