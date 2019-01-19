*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_v2_iftable_ifOperStatus
    [Documentation]    prov snmp v2 iftable_ifOperStatus
    [Tags]    @author=Sean Wang    @globalid=2358211    @tcid=AXOS_E72_PARENT-TC-2411    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${admin}    cli    eutA    show interface ethernet ${eth_port_3} status
    ${re_m}    ${re_admin}    should match regexp    ${admin}    oper-state\\s+(\\w+)
    ${re_admin}    convert to string    ${re_admin}
    ${re_admin_status}=    set variable if    '${re_admin}'=='${admin_status}'    up    down
    wait until keyword succeeds  30s  1s   port status check   ${re_admin_status}
    ${result}=    snmp get    eutA_snmp_v2    sysUpTime
    should be true    abs(${result})>0
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    snmp
    snmp_admin    eutA    enable
    service_point_prov    service_point_list1
case teardown
    log    Enter case teardown
    service_point_dprov    service_point_list1
    Configure    eutA    snmp
    cli    eutA    config
    cli    eutA    snmp

    # Axos Cli With Error Check    eutA    v2 admin-state disable

snmp_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    snmp
    cli    ${eut}    snmp community public ro
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end

port status check
    [Arguments]   ${re_admin_status}
    [Tags]    @author=chxu
    ${result}=    snmp get    eutA_snmp_v2    ifOperStatus.${port_1_oid}
    ${re}    convert to string    ${result}
    Should Contain    ${re}    ${re_admin_status}