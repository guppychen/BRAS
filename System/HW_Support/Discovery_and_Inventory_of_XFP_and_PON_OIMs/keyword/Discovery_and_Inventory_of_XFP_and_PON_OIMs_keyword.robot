*** Settings ***
Documentation    test_suite keyword lib

*** Keywords ***
check_inventory
    [Arguments]    ${device}    @{inv_list}
    [Documentation]    show inventory
    [Tags]    @author=PEIJUN LIU
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | inv_list | more option |
    ...    Example:
    ...    | check_inventory | system | chassis | baseboard | fans |
    ${result}    cli    ${device}    show inventory
    :FOR    ${key}    IN    @{inv_list}
    \    Should Contain    ${result}    ${key}


check_inventory_model_name
    [Arguments]    ${device}    ${inventory}    &{dict}
    [Documentation]    check chassis model name
    [Tags]    @author=PEIJUN LIU
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | inventory | inventory name like chassis |
    ...    | dict_cmd | more option |
    ...    Example:
    ...    | check_chassis_model_name | chassis | model-name=E7 SFF Assembly |
    ${result}    Cli    ${device}    show inventory ${inventory}
    @{list_key}    Get Dictionary Keys    ${dict}
    : FOR    ${key}    IN    @{list_key}
    \    ${value}    Get From Dictionary    ${dict}    ${key}
    \    ${res1}    Get Lines Containing String    ${result}    ${key}
    \    Should contain    ${res1}    ${value}
