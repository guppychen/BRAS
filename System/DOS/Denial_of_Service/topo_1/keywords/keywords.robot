*** Settings ***
Documentation     Suite description
Resource          ../base.robot

*** Keywords ***
set_bridge_aging_interval
    [Arguments]    ${device}    ${age}
    [Documentation]    Description: set bridge aging-interval
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | age | age interval for bridge table [60-600] |
    ...
    ...    Example:
    ...    | set_bridge_aging_interval | 300 |
    [Tags]    @author=LincolnYu
    cli    ${device}    configure
    Axos Cli With Error Check    ${device}    bridge aging-interval ${age}
    [Teardown]    cli    ${device}    end
#
#clear_bridge_table
#    [Arguments]    ${device}
#    [Documentation]    Description: clear bridge table
#    [Tags]    @author=LincolnYu
#    Axos Cli With Error Check    ${device}    clear bridge table
#    [Teardown]    cli    ${device}    end
