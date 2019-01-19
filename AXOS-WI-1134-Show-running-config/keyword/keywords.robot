*** Settings ***
Documentation    Suite description
Resource         ../base.robot

*** Keywords ***
provision_policy_map
    [Arguments]    ${axos}    ${pmap_name}
    [Documentation]    [Author:anzhang] Description: provision the policy-map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | pmap_name | policy-map name |
    ...
    ...    Example:
    ...    | provision_policy_map | axos | policymap |
    ${status}    Run Keyword And Return Status    Axos Cli With Error Check    ${axos}    show running-config policy-map ${pmap_name}
    Should Not Be True    ${status}
    log    provision the policy-map
    ${status}    Run Keyword And Return Status    Axos Cli With Error Check    ${axos}    config
    Axos Cli With Error Check    ${axos}    policy-map ${pmap_name}
    Axos Cli With Error Check    ${axos}    end
    ${res}    cli    ${axos}    show running-config policy-map ${pmap_name}
    should contain    ${res}    policy-map ${pmap_name}

provision_class_map
    [Arguments]    ${axos}    ${cmap_name}    ${cmap_type}
    [Documentation]    [Author:anzhang] Description: provision the class-map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | cmap_name | class-map name |
    ...    | cmap_type | class-map type,ip or ethernet |
    ...
    ...    Example:
    ...    | provision_class_map | axos | classmap | ethernet |
    ${status}    Run Keyword And Return Status    Axos Cli With Error Check    ${axos}    show running-config class-map ${cmap_type} ${cmap_name}
    Should Not Be True    ${status}
    log    provision class-map
    ${res}    cli    ${axos}    config
    Axos Cli With Error Check    ${axos}    class-map ${cmap_type} ${class_map_name}
    log    check running-config
    ${res}    cli    ${axos}    end
    ${res1}    cli    ${axos}    show running-config class-map ${cmap_type} ${cmap_name}
    should contain    ${res1}    class-map ethernet ${cmap_name}

add_class_map_to_policy_map
    [Arguments]    ${axos}    ${cmap_name}    ${pmap_name}    ${cmap_type}
    [Documentation]    [Author:anzhang] Description: add class map to policy map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | cmap_name | class-map name |
    ...    | pmap_name | policy-map name |
    ...    | cmap_type | class-map type,ip or ethernet |
    ...
    ...    Example:
    ...    | add_class_map_to_policy_map | axos | classmap | policymap | ethernet |
    ${tmp}    cli    ${axos}    config
    Axos Cli With Error Check    ${axos}    policy-map ${pmap_name}
    Axos Cli With Error Check    ${axos}    class-map-${cmap_type} ${cmap_name}
    log    check policy map includ class map
    ${tmp}    cli    ${axos}    end
    ${res}    cli    ${axos}    show running-config policy-map ${pmap_name}
    should contain    ${res}    policy-map ${pmap_name}
    should contain    ${res}    class-map-${cmap_type} ${cmap_name}

add_flow_to_class_map
    [Arguments]    ${axos}    ${cmap_name}    ${cmap_type}    ${flow_index}
    [Documentation]    [Author:anzhang] Description: add flow to class map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | cmap_name | class-map name |
    ...    | cmap_type | class-map type,ip or ethernet |
    ...    | flow_index | flow_index |
    ...
    ...    Example:
    ...    | add_flow_to_class_map | axos | classmap | ethernet | 1 |
    Axos Cli With Error Check    ${axos}    config
    Axos Cli With Error Check    ${axos}    class-map ${cmap_type} ${class_map_name}
    Axos Cli With Error Check    ${axos}    flow ${flow_index}
    ${res}    show_running_with_parameter    ${axos}    class-map ${cmap_type} ${cmap_name}
    should contain    ${res}    flow ${flow_index}

add_flow_to_policy_map
    [Arguments]    ${axos}    ${cmap_name}    ${pmap_name}    ${cmap_type}    ${flow_index}
    [Documentation]    [Author:anzhang] Description: add flow to policy map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | cmap_name | class-map name |
    ...    | pmap_name | policy-map name |
    ...    | cmap_type | class-map type,ip or ethernet |
    ...    | flow_index | flow_index |
    ...
    ...    Example:
    ...    | add_flow_to_policy_map | axos | classmap | policymap | ethernet | 1 |
    Axos Cli With Error Check    ${axos}    config
    Axos Cli With Error Check    ${axos}    policy-map ${pmap_name}
    Axos Cli With Error Check    ${axos}    class-map-${cmap_type} ${cmap_name}
    Axos Cli With Error Check    ${axos}    flow ${flow_index}
    ${tmp}    cli    ${axos}    end
    ${res}    show_running_with_parameter    ${axos}    policy-map ${pmap_name}
    should contain    ${res}    flow ${flow_index}

delete_class_map
    [Arguments]    ${axos}    ${cmap_name}    ${cmap_type}
    [Documentation]    [Author:anzhang] Description: delete class map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | cmap_name | class-map name |
    ...    | cmap_type | class-map type,ip or ethernet |
    ...
    ...    Example:
    ...    | delete_class_map | axos | classmap | ethernet | 1 |
    Axos Cli With Error Check    ${axos}    config
    Axos Cli With Error Check    ${axos}    no class-map ${cmap_type} ${cmap_name}
    ${res}    cli    ${axos}    end
    ${status}    Run Keyword And Return Status    Axos Cli With Error Check    ${axos}    show running-config class-map ${cmap_type} ${cmap_name}
    Should Not Be True    ${status}

delete_policy_map
    [Arguments]    ${axos}    ${pmap_name}
    [Documentation]    [Author:anzhang] Description: delete policy map
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | pmap_name | policy-map name |
    ...
    ...    Example:
    ...    | delete_policy_map | axos | policymap |
    Axos Cli With Error Check    ${axos}    config
    Axos Cli With Error Check    ${axos}    no policy-map ${pmap_name}
    ${tmp}    cli    ${axos}    end
    ${status}    Run Keyword And Return Status    Axos Cli With Error Check    ${axos}    show running-config policy-map ${pmap_name}
    Should Not Be True    ${status}

show_running_with_parameter
    [Arguments]    ${axos}    ${parameter}=None
    [Documentation]    [Author:anzhang] Description: show running config with the parameter
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | parameter | parameter |
    ...
    ...    Example:
    ...    | show_running_with_parameter | axos | policy-map map |
    cli    ${axos}    cli
    ${tmp}    cli    ${axos}    end
    ${res}    Run keyword if    "None"=="${parameter}"    cli    ${axos}    show running-config
    ...    ELSE    cli    ${axos}    show running-config ${parameter}
    return from keyword    ${res}

clear_the_file
    [Arguments]    ${axos}    ${file_name}
    [Documentation]    [Author:anzhang] Description: clear the file content under linux
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | file_name | file name |
    ...
    ...    Example:
    ...    | clear_the_file | axos | /tmp/log |
    go_to_linux    ${axos}
    cli    ${axos}    cd /home/root
    cli    ${axos}    > ${file_name}

delete_file
    [Arguments]    ${axos}    ${file_name}
    [Documentation]    [Author:anzhang] Description: delete file under linux
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | file_name | file name |
    ...
    ...    Example:
    ...    | delete_file | axos | /tmp/log |
    go_to_linux    ${axos}
    cli    ${axos}    cd /home/root
    cli    ${axos}    ll
    cli    ${axos}    rm -rf ${file_name}

show_file_content
    [Arguments]    ${axos}    ${file_name}
    [Documentation]    [Author:anzhang] Description: return the file content as string
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...    | file_name | file name |
    ...
    ...    Example:
    ...    | show_file_content | axos | /tmp/log |
    go_to_linux    ${axos}
    cli    ${axos}    cd /home/root
    cli    ${axos}    ll
    ${res}    cli    ${axos}    cat ${file_name}
    return from keyword    ${res}

is_on_linux
    [Arguments]    ${axos}
    [Documentation]    [Author:anzhang] Description: fails if is on linux
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...
    ...    Example:
    ...    | is_on_linux | axos |
    ${res}    cli     ${axos}    uname
    should contain    ${res}    Linux

go_to_linux
    [Arguments]    ${axos}
    [Documentation]    [Author:anzhang] Description: go to linux view from current view
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | axos | device name setting in your yaml |
    ...
    ...    Example:
    ...    | go_to_linux | axos |
    ${status}    Run Keyword And Return Status    is_on_linux    ${axos}
    Run Keyword If    "${status}" == "False"    cli    ${axos}    end
    Run Keyword If    "${status}" == "False"    cli    ${axos}    exit
    cli    ${axos}    cd
