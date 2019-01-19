*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_snmp_v2_iftable_ifLastChange
    [Documentation]    prov snmp v2 iftable_ifLastChange
    [Tags]    @author=Sean Wang    @globalid=2358306   @tcid=AXOS_E72_PARENT-TC-2418    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}=    snmp get    eutA_snmp_v2    ifLastChange.110010101
    ${re}    convert to string    ${result}
    should not be empty    ${re}
    ${result}=    snmp get    eutA_snmp_v2    ifLastChange.110010102
    ${re}    convert to string    ${result}
    should not be empty    ${re}
    ${result}=    snmp get    eutA_snmp_v2    ifLastChange.110010103
    ${re}    convert to string    ${result} 
    should not be empty    ${re}
    ${result}=    snmp get    eutA_snmp_v2    ifLastChange.110010104
    ${re}    convert to string    ${result}
    should not be empty    ${re}
    ${result}=    snmp get    eutA_snmp_v2    sysUpTime

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
