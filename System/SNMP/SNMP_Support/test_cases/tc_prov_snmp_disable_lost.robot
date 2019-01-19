*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_disable_test
    [Documentation]    prov snmp disable_test
    [Tags]    @author=Sean Wang    @globalid=2322248    @tcid=AXOS_E72_PARENT-TC-1720    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}    snmp_admin    eutA    disable
    ${result}    cli    eutA    show run snmp v2 admin
    should contain    ${result}    v2 admin-state disable
    
    ${disable_error}    Run Keyword And Expect Error    *    snmp_walk_check    eutA_snmp_v2
    log    ${disable_error}
    should contain any    ${disable_error}    Could not connect to SNMP host    No SNMP response received
    snmp_admin    eutA    enable
    ${re}    convert to string    ${result}
    ${result}=    snmp walk    eutA_snmp_v2    .1.3.6.1.4.1.6321
    ${result}=    snmp bulk get    eutA_snmp_v2    .1.3.6.1.2.1.11
    ${result}=    snmp bulk get    eutA_snmp_v2    .1.3.6.1.4.1.6321.1.2.4.2.2.1.1.1.1
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
    
snmp_walk_check
    [Arguments]    ${eut_snmp}
    [Tags]    @author=Sewang
    ${result}=    snmp walk    ${eut_snmp}   .1.3.6.1