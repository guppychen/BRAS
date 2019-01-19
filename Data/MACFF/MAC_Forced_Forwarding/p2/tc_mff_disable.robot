   
*** Settings ***
Documentation     disable mff on Vlan.Show mff status.-> mff is disabled on the Vlan successfully.
Resource          ./base.robot
Force Tags     @feature=MACFF    @author=wchen


*** Variables ***


*** Test Cases ***
tc_mff_disable
    [Documentation]    disable mff on Vlan.Show mff status.-> mff is disabled on the Vlan successfully.
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1379    @subFeature=MAC_Forced_Forwarding    @globalid=2286148    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1379 setup
    [Teardown]   AXOS_E72_PARENT-TC-1379 teardown
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=DISABLED
    ${res}    cli    eutA    show running-config vlan ${service_vlan1} | detail
    should match regexp    ${res}    mff\\s+DISABLED

*** Keywords ***
AXOS_E72_PARENT-TC-1379 setup
    [Documentation]    setup
    [Arguments]
    log    setup

AXOS_E72_PARENT-TC-1379 teardown
    [Documentation]    teardown
    [Arguments]
    log    teardown
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
