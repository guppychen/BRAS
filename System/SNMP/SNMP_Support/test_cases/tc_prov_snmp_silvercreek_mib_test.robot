*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_silvercreek_mib_test
    [Documentation]    prov snmp silvercreek_mib_test
    [Tags]    @author=Sean Wang    @globalid=2322237    @tcid=AXOS_E72_PARENT-TC-1712    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}    snmp_admin    eutA    enable
    ${result}    cli    eutA    show run snmp v2 admin
    should contain    ${result}    v2 admin-state enable
    ${result}=    snmp walk    eutA_snmp_v2    .1.3.6.1
    ${re}    convert to string    ${result}
    ${result}=    snmp walk    eutA_snmp_v2    .1.3.6.1.4.1.6321
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    snmp
    cli    eutA    end

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
    cli    ${eut}    v2 community public ro
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end