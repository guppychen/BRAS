*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc1_enable_SNMPv3
    [Documentation]    Enable SNMPv3
    [Tags]    @author=Philar Guo    @globalid=2373808    @tcid=AXOS_E72_PARENT-TC-2718    @feature=SNMP    @subfeature=SNMPv3 Support    @priority=P1
    [Setup]    case setup
    ${result}    snmpv3_admin   eutA    enable
    ${result}    cli    eutA    show run snmp v3 admin
    should contain    ${result}    v3 admin-state enable
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    snmpv3_admin   eutA    disable

case teardown
    log    Enter case teardown


