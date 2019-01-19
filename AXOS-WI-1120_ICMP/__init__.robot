*** Settings ***
Documentation     Setup file for AXOS-WI-1120_ICMP test suites
Resource          ../base.robot
#Resource          keyword/AXOS-WI-1120_ICMP_keywords.robot
Force Tags        @require=1eut   @subfeature=AXOS_WI_1120_icmp         @eut=GPON-8r2

Suite Setup    Basic_Test_Setup
Suite Teardown   Basic_Test_Teardown

*** Keywords ***
Basic_Test_Setup
    [Documentation]    Configure, enable and verify Craft Port Parameters are the same
#    Wait Until Keyword Succeeds    0.2 min    0.2 min    Configure Craft Port    n1    ${craft_port}    ${ipaddr}    ${mask}    ${gateway}
#    Wait Until Keyword Succeeds    0.2 min    0.2 min    Enable Craft Port    n1    ${craft_port}
#    Wait Until Keyword Succeeds    0.2 min    0.2 min    Verify Craft Port Entity    n1    ${craft_port}
    cli   n1_console   cli
    cli   n1_console    show version

Basic_Test_Teardown
    [Documentation]    Verify Craft Port Parameters are the same
    Wait Until Keyword Succeeds    0.2 min    0.2 min    Verify Craft Port Entity    n1    ${craft_port}