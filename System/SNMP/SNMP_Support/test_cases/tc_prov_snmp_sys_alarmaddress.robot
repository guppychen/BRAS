*** Settings ***
Resource          ./base.robot

*** Variables ***
${eth_port}       x1

*** Test Cases ***
tc_prov_snmp_v2_alarma_ddress
    [Documentation]    prov snmp v2 alarm address @EXA-20882
    [Tags]    @author=Sean Wang    @globalid=2322242    @tcid=AXOS_E72_PARENT-TC-1715    @feature=SNMP    @subfeature=SNMP Support    @priority=P1
    [Setup]    case setup
    cli    eutA    config
    cli    eutA    inter eth ${eth_port_1}
    cli    eutA    no shut
    cli    eutA    rmon-session fifteen-minutes 60
    cli    eutA    admin-state disable
    cli    eutA    end
    @{re}    snmp bulk get    eutA_snmp_v2    .1.3.6.1.4.1.6321.1.2.4.2.2.1.1.1.1.9.1
    : FOR    ${i}    IN    @{re}
    \    ${status}    split_array_to_str    ${i}    ${eth_port}
    \    Exit For Loop If    '${status}' == 'PASS'
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    snmp
    cli    eutA    config
    cli    eutA    snmp
    Axos Cli With Error Check    eutA    v2 admin-state enable
    cli    eutA    end
    # ${result}=    snmp walk    eutA_snmp_v2    .1.3.6.1

case teardown
    log    Enter case teardown
    Configure    eutA    snmp
    cli    eutA    end
    cli    eutA    config
    cli    eutA    inter eth ${eth_port_1}
    cli    eutA    no rmon-session
    cli    eutA    shut
    cli    eutA    end
    # Axos Cli With Error Check    eutA    v2 admin-state disable

snmp_admin
    [Arguments]    ${eut}    ${admin}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    snmp
    Axos Cli With Error Check    ${eut}    v2 admin-state ${admin}
    cli    ${eut}    end

split_array_to_str
    [Arguments]    ${arr}    ${port_index}
    [Documentation]    split array to str
    [Tags]    @author=Sewang
    : FOR    ${j}    IN    ${arr}
    \    ${values}=    convert to string    ${j}
    \    ${status}    ${value}    Run Keyword And Ignore Error    check_eth_port_exist    ${values}    ${port_index}
    \    Exit For Loop If    '${status}' == 'PASS'
    [Return]    ${status}

check_eth_port_exist
    [Arguments]    ${values}    ${port_index}
    [Documentation]    check eth port exist
    [Tags]    @author=Sewang
    should contain    ${values}    ${port_index}
