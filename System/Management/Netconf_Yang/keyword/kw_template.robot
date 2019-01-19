*** Settings ***
Resource          caferobot/cafebase.robot
#Library           robot.libraries.Collections
#Library           robot.libraries.String
#Library           robot.libraries.DateTime
Library      XML    use_lxml=True

*** Keywords ***
Get attributes netconf
    [Arguments]    ${conn}    ${parameter1}    ${parameter2}
    [Documentation]    retrieve the elements
    ...    Example:
    ...    Get attributes netconf  n1_session1  //system/images/summary  state
    log many    ${parameter1}    ${parameter2}
    ${output} =    Netconf Get    ${conn}    filter_type=xpath   filter_criteria=${parameter1}    timeout=60
    log    ${output.data_xml}
    ${root} =    Parse XML    ${output.data_xml}
    @{elem}=    Get Elements    ${root}    .//${parameter2}
    log    ${elem[0].text}
    [Return]    @{elem}

Edit netconf configure
    [Arguments]    ${conn}    ${parameter1}    ${parameter2}
    [Documentation]    configure the elements
    ...    Example:
    ...    Configure attributes netconf   n1_session1  config   error-tag
    log many    ${parameter1}    ${parameter2}
    ${output} =    Netconf Edit Config    ${conn}    target=running    config=${parameter1}
    log    ${output.xml}
    @{elem}=    Get Elements    ${output.xml}    .//${parameter2}
    log    ${elem[0].text}
   [Return]    @{elem}

Raw netconf configure
    [Arguments]    ${conn}    ${parameter1}    ${parameter2}
    [Documentation]    configure the elements
    ...    Example:
    ...    Raw netconf   n1_session1  config   error-tag
    log many    ${parameter1}    ${parameter2}
    ${output} =    Netconf Raw    ${conn}    ${parameter1}
    @{elem}=    Get Elements    ${output.xml}    .//${parameter2}
    log    ${elem[0].text}
    [Return]    @{elem}

Get hostname
    [Arguments]    ${conn}    ${hostname}
    [Documentation]    To get the device hostname
    #...    Example:
    #...    Get hostname    n1_session1
    ${output}    cli    ${conn}    show running-config hostname
    @{hostname}    Run Keyword If    'No entries found' in '''${output}'''    Return From Keyword    ${hostname}
    ...    ELSE    should match regexp    ${output}    hostname ([0-9a-zA-Z\\s\-]+)
    [Return]    @{hostname}[1]
                
