*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_snmp_v2_trap_8_host
    [Documentation]    prov snmp v2 trap 8 host
    [Tags]    @author=Sean Wang    @globalid=2375501    @tcid=AXOS_E72_PARENT-TC-2739    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    ${re}=    snmp get next    eutA_snmp_v2    sysObjectID
    cli    eutA    config
    cli    eutA    snmp
    cli    eutA    v2 community ${community} ro
    cli    eutA    v2 trap-host ${host_1} ${community}
    cli    eutA    trap-type inform
    cli    eutA    exit
    cli    eutA    v2 trap-host ${host_2} ${community}
    cli    eutA    trap-type inform
    cli    eutA    exit
    cli    eutA    v2 trap-host ${host_3} ${community}
    cli    eutA    trap-type inform
    cli    eutA    exit
    cli    eutA    v2 trap-host ${host_4} ${community}
    cli    eutA    trap-type inform
    cli    eutA    v2 trap-host ${host_5} ${community}
    cli    eutA    v2 trap-host ${host_6} ${community}
    cli    eutA    v2 trap-host ${host_7} ${community}
    ${result}    cli    eutA    v2 trap-host ${host_8} ${community}
    should contain    ${result}    at most 8 must be configured
    cli    eutA    end
    ${result}=    snmp bulk get    eutA_snmp_v2    .1.3.6.1.6.3
    ${re}    convert to string    ${result}
    should contain    ${re}    ${host_1}
    should contain    ${re}    ${host_2}
    should contain    ${re}    ${host_3}
    should contain    ${re}    ${host_4}
    should contain    ${re}    inform

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
    cli    eutA    no v2 trap-host ${host_1} ${community}
    cli    eutA    no v2 trap-host ${host_2} ${community}
    cli    eutA    no v2 trap-host ${host_3} ${community}
    cli    eutA    no v2 trap-host ${host_4} ${community}
    cli    eutA    no v2 trap-host ${host_5} ${community}
    cli    eutA    no v2 trap-host ${host_6} ${community}
    cli    eutA    no v2 trap-host ${host_7} ${community}
    cli    eutA    no v2 trap-host ${host_8} ${community}
    cli    eutA    end
    # Axos Cli With Error Check   eutA    v2 admin-state disable
    
snmp_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    snmp
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end
