*** Settings ***
Documentation     ntp alarm raise and clear
Resource          ./base.robot


*** Variables ***
${ntp_ip_wrong}    0.0.0.3

*** Test Cases ***
tc_ntp_alarm_raise_and_clear
    [Documentation]    1	doesn't config ntp server	ntp-prov alarm exist
    ...    2	configure ntp server which is not reachable	ntp-server-reachability alarm raise
    ...    3	no ntp server	alarm is cleared
    [Tags]  dual_card_not_support    @jira=EXA-29728      @author=blwang     @TCID=AXOS_E72_PARENT-TC-75    @GID=2210130    @feature=Real Time Clock Support     @subfeature=AXOS-1088-Real_time_clock_support
    [Setup]      AXOS_E72_PARENT-TC-75 setup
    [Teardown]   AXOS_E72_PARENT-TC-75 teardown
    log    STEP:1 doesn't config ntp server ntp-prov alarm exist
    
    Configure    n3    no ntp server 1
    ${res}    cli    n3    show ntp
    should contain    ${res}    ntpd-status "Not configured"    
    ${res}    cli    n3    show alarm active    
    should contain    ${res}    ntp-prov
    
    log    STEP:2 configure ntp server which is not reachable ntp-server-reachability alarm raise

    Configure    n3    ntp server 1 ${ntp_ip_wrong}
    ${res}    cli    n3    show ntp
    should contain    ${res}    ${ntp_ip_wrong}
    ${res}    cli    n3    show alarm active    
    should contain    ${res}    ntp-server-reachability       
    
    
    log    STEP:3 no ntp server alarm is cleared
    
    Configure    n3    no ntp server 1
    ${res}    cli    n3    show alarm active
    should not contain    ${res}    ntp-server-reachability   


*** Keywords ***
AXOS_E72_PARENT-TC-75 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-75 setup


AXOS_E72_PARENT-TC-75 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-75 teardown

