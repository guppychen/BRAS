*** Settings ***
Resource          ./base.robot

*** Variables ***
${admin_status_cli}    enable

*** Test Cases ***
tc_prov_snmp_v2_iftable_ififAdminStatus
    [Documentation]    prov snmp v2 iftable_ififAdminStatus
    [Tags]    @author=Sean Wang    @globalid=2358210   @tcid=AXOS_E72_PARENT-TC-2410    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${admin}    cli    eutA    show interface ethernet ${eth_port_3} status
    ${re_m}    ${re_admin}    should match regexp    ${admin}    admin-state\\s+(\\w+)
    ${re_admin}    convert to string    ${re_admin}
    ${re_admin_status}=    set variable if    '${re_admin}'=='${admin_status_cli}'    up    down
    ${result}=    snmp get    eutA_snmp_v2    ifAdminStatus.${port_1_oid}
    ${re}    convert to string    ${result}
    Should Contain    ${re}    ${re_admin_status}

    ${result}=    snmp get    eutA_snmp_v2    sysUpTime
    should be true    abs(${result})>0
    
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    snmp
    snmp_admin    eutA    enable

case teardown
    log    Enter case teardown
    Configure    eutA    snmp
    cli    eutA    config
    cli    eutA    snmp
    # Axos Cli With Error Check   eutA    v2 admin-state disable
    
snmp_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    snmp
    cli    ${eut}    v2 community public ro
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end
