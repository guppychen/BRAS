*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_v2_iftable_index
    [Documentation]    prov snmp v2 iftable_index
    [Tags]    @author=Sean Wang    @globalid=2358201   @tcid=AXOS_E72_PARENT-TC-2404    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}=    snmp bulk get    eutA_snmp_v2    ifTable
    ${re}    convert to string    ${result}
    Should Contain    ${re}    110010101
    Should Contain    ${re}    110010102
    Should Contain    ${re}    110010103
    Should Contain    ${re}    110010104

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
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end
