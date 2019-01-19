*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_v2_sysdesc
    [Documentation]    prov snmp v2 sysdesc
    [Tags]    @author=Sean Wang    @globalid=2322213    @tcid=AXOS_E72_PARENT-TC-1694    @feature=SNMP    @subfeature=SNMP Support
    [Setup]    case setup
    ${result}=    snmp get display string    eutA_snmp_v2    sysDescr
    Should Contain    ${result}    Calix
    Should Contain    ${result}    E7-2
    Should Contain    ${result}    ${sysdesc}
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
    Axos Cli With Error Check   eutA    v2 admin-state disable

snmp_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    snmp
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end