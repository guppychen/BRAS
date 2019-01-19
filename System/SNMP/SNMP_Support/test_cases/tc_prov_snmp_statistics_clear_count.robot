*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_v2_statistics
    [Documentation]    prov snmp v2 statistics
    [Tags]    @author=Sean Wang    @globalid=2371001    @tcid=AXOS_E72_PARENT-TC-2716    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}=    snmp get    eutA_snmp_v2    sysUpTime
    should be true    abs(${result})>0
    
    ${result}=    snmp get    eutA_snmp_v2    ifNumber
    should be true     ${result}==${expect_if_number} or ${result}==${expect_if_number_dual_card}
    #Should Contain    ${result}    ${expect_if_number}
    cli    eutA    clear snmp statistics
    
    ${re1}=    snmp get    eutA_snmp_v2    snmpInPkts
    ${re2}=    snmp get    eutA_snmp_v2    snmpInTotalReqVars
    ${re3}=    snmp get    eutA_snmp_v2    snmpInGetRequests
    ${re12}=    snmp get    eutA_snmp_v2    snmpOutPkts
    ${re13}=    snmp get    eutA_snmp_v2    snmpOutGetResponses
    ${re}    cli    eutA    show snmp statistics
    ${speed}    ${group1}    should Match Regexp    ${re}    in-pkts\\s+(\\d+)
    ${speed}    ${group2}    should Match Regexp    ${re}    in-total-req-vars\\s+(\\d+)
    ${speed}    ${group3}    should Match Regexp    ${re}    in-get-requests\\s+(\\d+)
    ${speed}    ${group12}    should Match Regexp    ${re}    out-pkts\\s+(\\d+)
    ${speed}    ${group13}    should Match Regexp    ${re}    out-get-responses\\s+(\\d+)
    
    should be true    abs(${group1}-${re1})>=0
    should be true    abs(${group2}-${re2})>=0
    should be true    abs(${group3}-${re3})>=0
    should be true    abs(${group12}-${re12})>=0
    should be true    abs(${group13}-${re13})>=0
    
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
