*** Settings ***
Documentation     reboot system with & without ntp server
Resource          ./base.robot


*** Variables ***
${ntp_ip}    192.168.33.10

*** Test Cases ***
tc_reboot_system_with_and_without_ntp_server
    [Documentation]    1	check system time and hardware time	date = hwclock
    ...    2	reboot system without ntp server	date = hwclock
    ...    3	enable ntp server	system time and hardware time is refreshed at the same time by ntp server
    ...    4	reboot system with ntp server	system time and hardware time is refreshed at the same time by ntp server
    [Tags]       @author=blwang    @user=root   @TCID=AXOS_E72_PARENT-TC-74    @GID=2210129    @feature=Real Time Clock Support    @EXA-19456        @subfeature=AXOS-1088-Real_time_clock_support
    [Setup]      AXOS_E72_PARENT-TC-74 setup
    [Teardown]   AXOS_E72_PARENT-TC-74 teardown
    log    STEP:1 check system time and hardware time date = hwclock
    ${timezonediffnumber}      get time diff   ${timezonediff}

    check system time equal hardware time    n4    ${timezonediffnumber}h
    
    log    STEP:2 reboot system without ntp server date = hwclock
    Reload System    n3
    check system time equal hardware time    n4    ${timezonediffnumber}h
    

    log    STEP:3 enable ntp server system time and hardware time is refreshed at same time by ntp server
    Configure    n3    ntp server 1 ${ntp_ip}   ${devices.n3.timeout}
    Wait Until Keyword Succeeds    10 min    5 sec     check_ntp_server    n3    ${ntp_ip}    Connected    "Synchronized 4 (0 is best)"    "Source selected, synchronized"
    Wait Until Keyword Succeeds    60 min    5 sec  check system time equal hardware time    n4    ${timezonediffnumber}h

    log    STEP:4 sleep 5 minutes and reboot system with ntp server system time and hardware time is refreshed at the same time by ntp server
    sleep   5min
    Reload System    n3
    Wait Until Keyword Succeeds    10 min    5 sec     check_ntp_server    n3    ${ntp_ip}    Connected    "Synchronized 4 (0 is best)"    "Source selected, synchronized"
    check system time equal hardware time    n4    ${timezonediffnumber}h


*** Keywords ***
AXOS_E72_PARENT-TC-74 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-74 setup


AXOS_E72_PARENT-TC-74 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-74 teardown
    configure    n3    no ntp server 1


