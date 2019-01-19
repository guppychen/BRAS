*** Settings ***
Documentation     The purpose of this test is to Check cross card's ethernet mtu 9000
...               1.set cross card ethernet mtu 9000
...               2.check cross card ethernet mtu 9000
...

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Cross_card_INNI_9K_MTU_to_INNI.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-4715     @globalid=2533450   @eut=GPON-8r2    @eut=10GE-12    @feature=HW_Support    @subfeature=MTU_size_of_9k     @author=pzhang
    [Documentation]     The purpose of this test is to Check cross card's ethernet mtu 9000
    ...               1.set cross cards ethernet mtu 9000
    ...               2.check cross cards ethernet mtu 9000
    [Setup]      setup
    log     check card 1_2 mtu
    check_running_config_interface    eutA     ${service_model.service_point1.type}    ${service_model.service_point1.member.interface1}    mtu=9000
    check_running_config_interface    eutA     ${service_model.service_point3.type}    ${service_model.service_point2.member.interface1}    mtu=9000

    log     check card 2_1 mtu
    check_running_config_interface    eutA     ${service_model.service_point4.type}    ${service_model.service_point3.member.interface1}    mtu=9000
    check_running_config_interface    eutA     ${service_model.service_point2.type}    ${service_model.service_point4.member.interface1}    mtu=9000

    log     success

    [Teardown]   teardown


*** Keywords ***
setup
    log     set card 1_2 ethernet mtu
    Prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    speed=auto     mtu=9000
    Prov_interface_ethernet    eutA    ${service_model.service_point3.member.interface1}    speed=auto     mtu=9000

    log     set card 2_1 ethernet mtu
    Prov_interface_ethernet    eutA    ${service_model.service_point2.member.interface1}    speed=auto     mtu=9000
    Prov_interface_ethernet    eutA    ${service_model.service_point4.member.interface1}    speed=auto     mtu=9000

teardown
    log      reset card 1 ethernet to default 2000
    dprov_interface_ethernet    eutA     ${service_model.service_point1.member.interface1}    mtu
    dprov_interface_ethernet    eutA     ${service_model.service_point2.member.interface1}    mtu

    log      reset card 2 ethernet to default 2000
    dprov_interface_ethernet    eutA     ${service_model.service_point3.member.interface1}    mtu
    dprov_interface_ethernet    eutA     ${service_model.service_point4.member.interface1}    mtu