*** Settings ***
Resource          ./base.robot

*** Variables ***
${ntp1}    1
${ntp2}    2

*** Test Cases ***
tc_prov_ntp_1
    [Documentation]    The device shall support an RFC 5904 NTP v4 compliant client
    [Tags]    @author=Sean Wang    @globalid=2313904    @tcid=AXOS_E72_PARENT-TC-910    @feature=Timing    @subfeature=NTP
    [Setup]    case setup
    log    STEP:2 (Client/Server)Verify Show ntp associations/details
    check_ntp_status    eutA    ${ntp_staus[0]}
    Configure    eutA    timezone Asia/Chongqing
    Wait Until Keyword Succeeds    15 min    15 sec    check_ntp_server    eutA    ${server_ip[0]}    ${connection_status[0]}
    ...    ${synchronize_status[0]}    ${source_status[0]}
    ${system_time}    get current date
    ${device_time}    get_device_clock    eutA
    ${result1}    convert Date    ${system_time}    epoch
    ${result2}    convert Date    ${device_time}    epoch
    should be true    abs(${result2}- ${result1})<${timegap}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    timezone Africa/Algiers

case teardown
    log    Enter 2143103 teardown
