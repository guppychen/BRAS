*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_snmp_v2_sysObjectID
    [Documentation]    prov snmp v2 sysObjectID
    [Tags]    @author=Sean Wang    @globalid=2346709    @tcid=AXOS_E72_PARENT-TC-2305    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${re}=    snmp get next    eutA_snmp_v2    sysObjectID
    ${result}=    snmp get    eutA_snmp_v2    snmpEngineID
    ${result}=    snmp get    eutA_snmp_v2    sysUpTime
    should be true    abs(${result})>0
    
    Configure    eutA    contact sean.wang@calix.com
    ${result}=    snmp get display string    eutA_snmp_v2    sysContact
    Should Contain    ${result}    sean.wang@calix.com
    
    Configure    eutA    location Nanjing
    ${result}=    snmp get display string    eutA_snmp_v2    sysLocation
    Should Contain    ${result}    Nanjing
    # ${result}=    Snmp Convert To Timeticks    eutA_snmp_v2    .1.3.6.1.2.1.1.8.0
    
    ${result}=    snmp get    eutA_snmp_v2    ifNumber
    should be true     ${result}==${expect_if_number} or ${result}==${expect_if_number_dual_card}
    #Should Contain    ${result}    ${expect_if_number}
  
    
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
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end
