*** Settings ***
Force Tags        @eut=NGPON2-4     @require=1eut     @eut=GPON-8r2
Suite Setup       Ntp_sync_provision
Suite Teardown    Ntp_sync_deprovision
Resource          ./base.robot

*** Variables ***
${ntp1}    1
${ntp2}    2

*** Keywords ***
Ntp_sync_provision
    [Documentation]    suite provision for sub_feature
    set eut version
    Configure    eutA    ntp server ${ntp1} ${server_ip[0]}
    Configure    eutA    timezone Asia/Chongqing
    Wait Until Keyword Succeeds    15 min    15 sec    check_ntp_server    eutA    ${server_ip[0]}    ${connection_status[0]}
    ...    ${synchronize_status[0]}    ${source_status[0]}

Ntp_sync_deprovision
    [Documentation]    suite deprovision for sub_feature
    Configure    eutA    no ntp server ${ntp1}