*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_snmp_v2_ifTable_items
    [Documentation]    prov snmp v2 ifTable_items
    [Tags]    @author=Sean Wang    @globalid=2322217    @tcid=AXOS_E72_PARENT-TC-1697    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${result}=    snmp bulk get    eutA_snmp_v2    ifTable
    ${re}    convert to string    ${result}
    ${re1}    convert to string    ${port_1_oid}
    Should Contain    ${re}    ${re1}
    Should Contain    ${re}    ${eth_port_1}
    Should Contain    ${re}    ${re_default_eth_type}
    Should Contain    ${re}    ${re_default_mtu}
    Should Contain    ${re}    ${re_speed}
    Should Contain    ${re}    ${re_PhysAddress}
    
    # Should Contain    ${result}    NGPON2X4
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
