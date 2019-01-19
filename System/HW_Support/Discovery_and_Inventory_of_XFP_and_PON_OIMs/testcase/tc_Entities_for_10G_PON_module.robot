*** Settings ***
Documentation     Entities for 10G PON module
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Entities_for_10G_PON_module
    [Documentation]    The 10G PON modules may be populated in slots 1 or 2 on card
    [Tags]       @author=PEIJUN LIU     @TCID=AXOS_E72_PARENT-TC-2954     @globalid=2393708
    ...    @subfeature=Discovery_and_Inventory_of_XFP_and_PON_OIMs    @feature=HW_Support    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:The 10G PON modules may be populated in slots 1 or 2 on card
    cli    eutA     show entityPhysical
    Result Should Contain    1/xp1
    Result Should Contain    1/xp2
    Result Should Contain    1/xp3
    Result Should Contain    1/xp4

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    setup

case teardown
    [Documentation]    case teardown
    [Arguments]
    log     teardown
