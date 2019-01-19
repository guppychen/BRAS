*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_snmp_v2_sysSnmpCommunityTable
    [Documentation]    prov snmp v2 sysSnmpCommunityTable
    [Tags]    @author=Sean Wang    @globalid=2322233    @tcid=AXOS_E72_PARENT-TC-1709    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${re}=    snmp get next    eutA_snmp_v2    sysObjectID
    cli    eutA    config
    cli    eutA    snmp
    cli    eutA    v2 community ${community} ro
    cli    eutA    v2 community ${community_1} ro
    cli    eutA    v2 community ${community_2} ro
    cli    eutA    v2 community ${community_3} ro
    cli    eutA    v2 community ${community_4} ro
    cli    eutA    v2 community ${community_5} ro
    cli    eutA    v2 community ${community_6} ro
    cli    eutA    v2 community ${community_7} ro
    cli    eutA    end
    ${result}=    snmp bulk get   eutA_snmp_v2    .1.3.6.1.6.3.18.1.1.1.2
    ${re}    convert to string    ${result}
    should contain    ${re}    ${community} 
    should contain    ${re}    ${community_1}
    should contain    ${re}    ${community_2}
    should contain    ${re}    ${community_3}
    should contain    ${re}    ${community_4}
    should contain    ${re}    ${community_5}
    should contain    ${re}    ${community_6}
    should contain    ${re}    ${community_7}    
    # .1.3.6.1.6.3.18.1.1.1.2.112.117.98.108.105.99
    ${result}=    snmp get    eutA_snmp_v2    sysUpTime
    should be true    abs(${result})>0
    
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
    # cli    eutA    no v2 community ${community} ro
    cli    eutA    no v2 community ${community_1} ro
    cli    eutA    no v2 community ${community_2} ro
    cli    eutA    no v2 community ${community_3} ro
    cli    eutA    no v2 community ${community_4} ro
    cli    eutA    no v2 community ${community_5} ro
    cli    eutA    no v2 community ${community_6} ro
    cli    eutA    no v2 community ${community_7} ro
    cli    eutA    end
    # snmp_admin    eutA    disable
    
snmp_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    snmp
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end
