*** Settings ***
Documentation     check system time and hw time without ntp server
Resource          ./base.robot
Resource           DateTime

*** Variables ***


*** Test Cases ***
tc_check_system_time_and_hw_time_without_ntp_server
    [Documentation]    1	login system with root/root	success
    ...    2	check system time and hardware time	date = hwclock
    ...    3	check time format	Provide year/month/ day/ hours/minutes and seconds information based upon an accurate integrated crystal
    [Tags]       @author=blwang     @user=root   @TCID=AXOS_E72_PARENT-TC-73    @GID=2210128    @feature=Real Time Clock Support      @subfeature=AXOS-1088-Real_time_clock_support
    [Setup]      AXOS_E72_PARENT-TC-73 setup
    [Teardown]   AXOS_E72_PARENT-TC-73 teardown
    log    STEP:1 login system with root/root success
    ${timezonediffnumber}      get time diff   ${timezonediff}
    ${res1}    Get DateTime    n4
    ${res2}    convert Date    ${res1}    epoch

    log    STEP: 2 check system time and hardware time date = hwclock
    ${res3}    Get hwclock Time with Changetime    n4    ${timezonediffnumber}h
    ${res4}    convert Date    ${res3}    epoch

    log    STEP:3 check time format Provide year/month/ day/ hours/minutes and seconds information based upon an accurate integrated crystal
    should be true   abs(${res4}- ${res2})<5



*** Keywords ***
AXOS_E72_PARENT-TC-73 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-73 setup


AXOS_E72_PARENT-TC-73 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-73 teardown


