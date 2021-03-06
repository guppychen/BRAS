*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_v2_iftable_ifdesc
    [Documentation]    prov snmp v2 iftable_ifdesc
    [Tags]    @author=Sean Wang    @globalid=2358202   @tcid=AXOS_E72_PARENT-TC-2405    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}=    snmp bulk get    eutA_snmp_v2    ifDescr
    ${re}    convert to string    ${result}
    Should Contain    ${re}    1/1/x1
    Should Contain    ${re}    1/1/x2
    Should Contain    ${re}    1/1/x3
    Should Contain    ${re}    1/1/x4

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
