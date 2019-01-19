*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_snmp_v2_iftable_ifMtu
    [Documentation]    prov snmp v2 iftable_ifMtu
    [Tags]    @author=Sean Wang    @globalid=2358207   @tcid=AXOS_E72_PARENT-TC-2407    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${mtu}    cli    eutA    show interface ethernet ${eth_port_1} status mtu
    ${re_m}    ${re_mtu}    should match regexp    ${mtu}    mtu\\s+(\\d+)
    ${result}=    snmp bulk get    eutA_snmp_v2    ifMtu
    ${re}    convert to string    ${result}
    Should Contain    ${re}    ${re_mtu}
    Should Contain    ${re}    ${re_mtu} 
    Should Contain    ${re}    ${re_mtu}
    Should Contain    ${re}    ${re_mtu}

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
