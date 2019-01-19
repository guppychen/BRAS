*** Settings ***
Documentation     Show Inventory CLI command
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Show_Inventory_CLI_command
    [Documentation]    Verify the "show inventory" command displays the entire equipment hierarchy, including (system, controller, switch card, power supplies).
    [Tags]    @author=PEIJUN LIU    @TCID=AXOS_E72_PARENT-TC-2957         @globalid=2393711
    ...    @subfeature=Discovery_and_Inventory_of_XFP_and_PON_OIMs    @feature=HW_Support    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]    case setup
    [Teardown]    case teardown
    log    STEP:Verify the "show inventory" command displays the entire equipment hierarchy, including (system, controller, switch card, power supplies).
    check_inventory    eutA    system    chassis    baseboard    fans
    check_inventory_model_name    eutA    chassis    model-name=E7 SFF Assembly
    check_inventory_model_name    eutA    baseboard    model-name=E7-2 NGPON2-4
    check_inventory_model_name    eutA    fans    model-name=E7 Fan Tray Assembly FTA2

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    no case setup

case teardown
    [Documentation]    case teardown
    [Arguments]
    log    no case teardown
