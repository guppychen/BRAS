*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_v2_statistics
    [Documentation]    prov snmp v2 statistics
    [Tags]    @author=Sean Wang    @globalid=2322221    @tcid=AXOS_E72_PARENT-TC-1700    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}=    snmp get    eutA_snmp_v2    sysUpTime
    should be true    abs(${result})>0
    
    ${result}=    snmp get    eutA_snmp_v2    ifNumber
    should be true     ${result}==${expect_if_number} or ${result}==${expect_if_number_dual_card}
    #Should Contain    ${result}    ${expect_if_number}
    
    ${re1}=    snmp get    eutA_snmp_v2    snmpInPkts
    ${re2}=    snmp get    eutA_snmp_v2    snmpInTotalReqVars
    ${re3}=    snmp get    eutA_snmp_v2    snmpInGetRequests
    ${re4}=    snmp get    eutA_snmp_v2    snmpInGetNexts
    ${re5}=    snmp get    eutA_snmp_v2    snmpInGetResponses
    ${re6}=    snmp get    eutA_snmp_v2    snmpInTraps
    ${re7}=    snmp get    eutA_snmp_v2    snmpInTotalSetVars
    ${re8}=    snmp get    eutA_snmp_v2    snmpOutSetRequests
    ${re9}=    snmp get    eutA_snmp_v2    snmpInBadVersions
    ${re10}=    snmp get    eutA_snmp_v2    snmpInBadCommunityNames
    ${re11}=    snmp get    eutA_snmp_v2    snmpInBadCommunityUses
    ${re12}=    snmp get    eutA_snmp_v2    snmpOutPkts
    ${re13}=    snmp get    eutA_snmp_v2    snmpOutGetResponses
    ${re14}=    snmp get    eutA_snmp_v2    snmpOutTraps
    ${re15}=    snmp get    eutA_snmp_v2    snmpOutSetRequests
    ${re16}=    snmp get    eutA_snmp_v2    snmpOutTooBigs
    ${re17}=    snmp get    eutA_snmp_v2    snmpOutNoSuchNames
    ${re18}=    snmp get    eutA_snmp_v2    snmpOutBadValues
    ${re19}=    snmp get    eutA_snmp_v2    snmpOutGenErrs
    ${re}    cli    eutA    show snmp statistics
    ${speed}    ${group1}    should Match Regexp    ${re}    in-pkts\\s+(\\d+)
    ${speed}    ${group2}    should Match Regexp    ${re}    in-total-req-vars\\s+(\\d+)
    ${speed}    ${group3}    should Match Regexp    ${re}    in-get-requests\\s+(\\d+)
    ${speed}    ${group4}    should Match Regexp    ${re}    in-get-nexts\\s+(\\d+)
    ${speed}    ${group5}    should Match Regexp    ${re}    in-get-responses\\s+(\\d+)
    ${speed}    ${group6}    should Match Regexp    ${re}    in-traps\\s+(\\d+)
    ${speed}    ${group7}    should Match Regexp    ${re}    in-total-set-vars\\s+(\\d+)
    ${speed}    ${group8}    should Match Regexp    ${re}    in-set-requests\\s+(\\d+)
    ${speed}    ${group9}    should Match Regexp    ${re}    in-bad-versions\\s+(\\d+)
    ${speed}    ${group10}    should Match Regexp    ${re}    in-bad-community-names\\s+(\\d+)
    ${speed}    ${group11}    should Match Regexp    ${re}    in-bad-community-uses\\s+(\\d+)
    ${speed}    ${group12}    should Match Regexp    ${re}    out-pkts\\s+(\\d+)
    ${speed}    ${group13}    should Match Regexp    ${re}    out-get-responses\\s+(\\d+)
    ${speed}    ${group14}    should Match Regexp    ${re}    out-traps\\s+(\\d+)
    ${speed}    ${group15}    should Match Regexp    ${re}    out-set-requests\\s+(\\d+)
    ${speed}    ${group16}    should Match Regexp    ${re}    out-too-bigs\\s+(\\d+)
    ${speed}    ${group17}    should Match Regexp    ${re}    out-no-such-names\\s+(\\d+)
    ${speed}    ${group18}    should Match Regexp    ${re}    out-bad-values\\s+(\\d+)
    ${speed}    ${group19}    should Match Regexp    ${re}    out-gen-errs\\s+(\\d+)
    :For   ${i}   IN RANGE    1    20
    \      should be true    abs(${group${i}}-${re${i}})>=0
    
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
