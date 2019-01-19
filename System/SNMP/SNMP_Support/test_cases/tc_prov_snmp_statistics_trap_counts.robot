*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_v2_statistics
    [Documentation]    prov snmp v2 statistics
    [Tags]    @author=Sean Wang    @globalid=2371101    @tcid=AXOS_E72_PARENT-TC-2717    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}=    snmp get    eutA_snmp_v2    sysUpTime
    should be true    abs(${result})>0
    
    ${result}=    snmp get    eutA_snmp_v2    ifNumber
    should be true     ${result}==${expect_if_number} or ${result}==${expect_if_number_dual_card}
    #Should Contain    ${result}    ${expect_if_number}
    cli    eutA    clear snmp statistics
    cli    eutA    config
    cli    eutA    inter eth ${eth_port_1}
    cli    eutA    shut
    cli    eutA    no shut
    cli    eutA    end
    sleep    5
    ${re12}=    snmp get    eutA_snmp_v2    snmpOutPkts
    ${re14}=    snmp get    eutA_snmp_v2    snmpOutTraps
    ${re}    cli    eutA    show snmp statistics
    ${speed}    ${group12}    should Match Regexp    ${re}    out-pkts\\s+(\\d+)
    ${speed}    ${group14}    should Match Regexp    ${re}    out-traps\\s+(\\d+)
    
    should be true    abs(${group12}-${re12})>=0
    should be true    abs(${group14}-${re14})>=0
    
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
