*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_snmp_v2_ifXTable
    [Documentation]    prov snmp v2 ifXTable
    [Tags]    @author=Sean Wang    @globalid=2322223    @tcid=AXOS_E72_PARENT-TC-1701    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}=    snmp get    eutA_snmp_v2    sysUpTime
    should be true    abs(${result})>0
    
    ${result}=    snmp walk    eutA_snmp_v2    ifXTable
    
    ${re1}=    snmp bulk get    eutA_snmp_v2    ifName
    ${re2}=    snmp bulk get    eutA_snmp_v2    ifInMulticastPkts
    ${re3}=    snmp bulk get    eutA_snmp_v2    ifInBroadcastPkts
    ${re4}=    snmp bulk get    eutA_snmp_v2    ifOutMulticastPkts
    ${re5}=    snmp bulk get    eutA_snmp_v2    ifOutBroadcastPkts
    ${re6}=    snmp bulk get    eutA_snmp_v2    ifHCInOctets
    ${re7}=    snmp bulk get    eutA_snmp_v2    ifHCInUcastPkts
    ${re8}=    snmp bulk get    eutA_snmp_v2    ifHCInMulticastPkts
    ${re9}=    snmp bulk get    eutA_snmp_v2    ifHCInBroadcastPkts
    ${re10}=    snmp bulk get    eutA_snmp_v2    ifHCOutOctets
    ${re11}=    snmp bulk get    eutA_snmp_v2    ifHCOutUcastPkts
    ${re12}=    snmp bulk get    eutA_snmp_v2    ifHCOutMulticastPkts
    ${re13}=    snmp bulk get    eutA_snmp_v2    ifHCOutBroadcastPkts
    ${re14}=    snmp bulk get    eutA_snmp_v2    ifLinkUpDownTrapEnable
    ${re15}=    snmp bulk get    eutA_snmp_v2    ifHighSpeed
    ${re16}=    snmp bulk get    eutA_snmp_v2    ifPromiscuousMode
    ${re17}=    snmp bulk get    eutA_snmp_v2    ifConnectorPresent
    ${re18}=    snmp bulk get    eutA_snmp_v2    ifAlias
    ${re19}=    snmp bulk get    eutA_snmp_v2    ifCounterDiscontinuityTime
    
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
