*** Settings ***
Documentation     Suite description
Resource          ../base.robot

*** Keywords ***
check_no_bridge_table_by_mac
    [Arguments]    ${device}        ${mac}
    [Documentation]    check no mac
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | mac | mac address |
    ...    Example:
    ...    | check_no_bridge_table | n1 | 00:02:5d:fc:fa:2e |
     [Tags]    @author=AnneLi
    ${result}    CLI    ${device}    show bridge table
     should not contain      ${result}      ${mac}

















