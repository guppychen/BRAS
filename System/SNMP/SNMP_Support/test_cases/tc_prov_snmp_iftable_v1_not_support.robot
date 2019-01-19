*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_snmp_v1_not_support
    [Documentation]    prov snmp v1 not support
    [Tags]    @author=Sean Wang    @globalid=2322252    @tcid=AXOS_E72_PARENT-TC-1724    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${re}=    snmp get next    eutA_snmp_v2    sysObjectID
    cli    eutA    config
    cli    eutA    snmp
    ${result}    cli    eutA    v2 admin-state en
    ${result}    cli    eutA    v1 admin-state en
    should contain    ${result}    syntax error
    cli    eutA    end
    ${result}=    snmp bulk get    eutA_snmp_v2    .1.3.6.1.6.3
    ${re}    convert to string    ${result}  
    
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
    # cli    eutA    no v2 community ${community} ro
    cli    eutA    end
    # Axos Cli With Error Check   eutA    v2 admin-state disable
    
snmp_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    snmp
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end
