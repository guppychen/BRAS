*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_MIB_check_SNMPv3_user
    [Documentation]    MIB check SNMPv3
    [Tags]    @author=Philar Guo    @globalid=2373825    @tcid=AXOS_E72_PARENT-TC-2735    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup
    cli    eutA    config
    cli    eutA    inter eth 1/1/x1
    cli    eutA    shut
    sleep    1s
    cli    eutA    no shut
    sleep    5s
    cli    eutA    end
    wait until keyword succeeds   30sec   10sec   get_and_check_snmp_trap_host_results  n_snmp_v3_auth_priv_3   1/1/x1  no shut


    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    prov_snmpv3_trap_host   eutA   ${trap_host_vm}   ${SNMPv3_user_auth_priv_3}   authPriv
    Snmp Start Trap Host    n_snmp_v3_auth_priv_3


case teardown
    log    Enter case teardown
    snmp stop trap host     n_snmp_v3_auth_priv_3
    delete_snmpv3_trap_host   eutA   ${trap_host_vm}   ${SNMPv3_user_auth_priv_3}




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