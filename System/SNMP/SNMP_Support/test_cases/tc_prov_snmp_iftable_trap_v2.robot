*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_snmp_v2_iftable_trap
    [Documentation]    prov snmp v2 iftable_trap
    [Tags]    @author=Sean Wang    @globalid=2375701    @tcid=AXOS_E72_PARENT-TC-2740    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    # ${result}=    snmp get    eutA_snmp_v2    .1.3.6.1.2.1.2.2.1.6
    # Should Contain    ${result}    X1
    ${result}=    snmp get    eutA_snmp_v2    sysUpTime
    should be true    abs(${result})>0
    
    comment   Start trap,shutdown NGPON2-4 and stop trap
    Snmp Start Trap Host    eutA_snmp_v2
    cli    eutA    config
    cli    eutA    inter eth ${eth_port_1}
    cli    eutA    shut
    sleep    1s
    cli    eutA    no shut
    sleep    5s
    cli    eutA    end
    ${re_alarm}    cli    eutA    show alarm his
    should contain    ${re_alarm}    ${eth_port_1}
    wait until keyword succeeds   3min   5sec   check_port_down  eutA    ${eth_port_1}

    comment   Get trap host result and check it
    wait until keyword succeeds   30sec   10sec   get_and_check_snmp_trap_host_results  eutA_snmp_v2   ${port_x3}  no shut
    snmp stop trap host     eutA_snmp_v2 
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    snmp
    cli    eutA    paginate false
    cli    eutA    config
    cli    eutA    snmp
    Axos Cli With Error Check   eutA    v2 admin-state enable
    cli    eutA    v2 trap-host ${vm_ip} public
    cli    eutA    end

case teardown
    log    Enter case teardown
    Configure    eutA    snmp
    cli    eutA    config
    cli    eutA    snmp
    # Axos Cli With Error Check   eutA    v2 admin-state disable
    # cli    eutA    no v2 trap-host 10.245.249.8 public
    
snmp_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    snmp
    cli    ${eut}    v2 community public ro
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end

get_and_check_snmp_trap_host_results
    [Documentation]   get snmp trap host result,check it correctly
    [Arguments]   ${snmp_verion}    ${port_index}    ${status}
    [Tags]    @author=Sewang
    @{res}=    snmp Get Trap Host Results     ${snmp_verion}
    :For   ${i}   IN    @{res}
    \      split_array_to_str    ${i}    ${port_index}

split_array_to_str
    [Documentation]   split array to str
    [Arguments]   ${arr}    ${port_index}
    [Tags]    @author=Sewang
    :For   ${j}   IN    ${arr}
    \      ${values}=    Get Dictionary Values    ${j}
    \      ${val}    convert to string    ${values}
    \      should contain    ${val}    ${port_index}
    \      should contain Any    ${val}    improper-removal    loss-of-signal

    
check_port_down
    [Documentation]   check port shut
    [Arguments]   ${eut}    ${port_no}
    [Tags]    @author=Sewang
    ${re}    cli    ${eut}    show run inter eth ${port_no}
    should contain    ${re}    no shut