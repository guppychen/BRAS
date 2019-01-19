*** Settings ***
Documentation    parameter file for cmd adapter in different release
Resource         ../base.robot

*** Keywords ***
release_cmd_adapter
    [Arguments]    ${device}    ${cmd_param}    @{cmd_var_item}
    [Documentation]    Description: cmd adapter in different release
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | cmd_param | command parameter in param_release_cmd_adapter.robot |
    ...    | cmd_var_item | command input variable or match item, mapping %s in cmd_param dictionary value, no need to use it if no place holder in ${cmd_param} |
    ...
    ...    Return Value:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | cmd_str | output command config string or Regexp match string |
    ...
    ...    Example:
    ...    | ${mask_str} | release_cmd_adapter | eutA | ${prov_interface_ip_config_mask} | 255.255.255.0 |
    [Tags]    @author=CindyGao
    log    if no 'release' item in topo.yaml set it to DEFAULT
    ${passed}    Run Keyword And Return Status    Dictionary Should Contain Key    ${DEVICES.${device}}    release
    ${release}    Set Variable If    ${passed}     ${DEVICES.${device}.release}   DEFAULT
    log    get release ${release}
    log    set release to 'DEFAULT' if release is not key in cmd_key dictionary
    ${passed}    Run Keyword And Return Status    Dictionary Should Contain Key    ${cmd_param}    ${release}
    ${release}    Set Variable If    ${passed}     ${release}   DEFAULT
    Log List    ${cmd_var_item}
    ${item}    Catenate    SEPARATOR=','    @{cmd_var_item}
    Log Dictionary    ${cmd_param}
    ${cmd_str}    Run Keyword If    "${item}"=="${EMPTY}"    Set Variable    &{cmd_param}[${release}]
    ...    ELSE    evaluate    '&{cmd_param}[${release}]'%('${item}')
    log    return string is "${cmd_str}" for release ${release}
    [Return]    ${cmd_str}

prov_interface_ip_adapter_mask
    [Arguments]    ${device}    ${mask}
    [Documentation]    Description: mask string adapter for prov_interface_ip keyword
    ...    will use format ' mask 255.255.225.0' or '/24' for different release 
    ...    depends on ${prov_interface_ip_config_mask} variabel in param_release_cmd_adapter.robot
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | mask | IP Mask |
    ...
    ...    Example:
    ...    | prov_interface_ip_adapter_mask | eutA | 255.255.255.0 | 
    ...    | prov_interface_ip_adapter_mask | eutA | 24 |
    [Tags]    @author=CindyGao
    ${mask_str}    release_cmd_adapter    ${device}    ${prov_interface_ip_config_mask}
    ${contain_mask}    Run Keyword And Return Status    Should Contain    ${mask_str}    mask
    ${mask}    Set Variable If    ${contain_mask} and ("${mask}"=="24")    255.255.255.0
    ...    "${contain_mask}"=="False" and ("${mask}"=="255.255.255.0")    24
    ...    ${mask}
    ${mask_str}    release_cmd_adapter    ${device}    ${prov_interface_ip_config_mask}    ${mask}
    [Return]    ${mask_str}

get_eut_version
    [Arguments]    ${device}
    [Documentation]      this is the keyword used to get single device's build information
    [Tags]         @author=llin
    ${res}    Cli   ${device}   cli
    ${res}    Cli   ${device}   show version
    ${matches}      Get Regexp Matches     ${res}       (description|details)\\s*(.*)\r    2
    log       we've got the matches: ${matches}              TRACE
    ${build}       Get From List      ${matches}    0
    log       we've got the build informations : ${build}
    [Return]      ${build}

mapping_build_to_release
    [Arguments]       ${build}      ${map}=${CURDIR}/build_release_mapping.txt
    [Documentation]    this is the keyword used to mapping build id to release name
    [Tags]       @author=llin
    # handle the build number, remove the build id from the full build convert to string
    ${build}      Remove string using regexp      ${build}      -\\d+$
    log       the branch of the build is : ${build}

    ${fileHandler}        EVALUATE   open('${map}').readlines()
    log        the mapping file content : ${fileHandler}        TRACE
    convert to list     ${fileHandler}
    ${rowIndex}    set variable     0
    :FOR    ${rowitem}     IN     @{fileHandler}
    \       log       current row item is: ${rowitem}           TRACE
    \       log       current row index is: ${rowIndex}          TRACE
    \       ${result} =   run keyword and ignore error      should contain      ${rowitem}    ${build}
    \       log       the searching result is: ${result}           TRACE
    \       ${rowIndex}   evaluate    ${rowIndex} + 1
    \       exit for loop if       '@{result}[0]'=='PASS'
    # [AT-3619] modify by CindyGao, start
    Return From Keyword If    '@{result}[0]'!='PASS'    NONE
    # [AT-3619] modify by CindyGao, end
    log    we find the release info in ${rowIndex} row.            TRACE
    ${len}     get length       ${fileHandler}
    ${targetIndex}   evaluate   ${rowIndex} - 1
    ${releaseStr}    convert to string   @{fileHandler}[${targetIndex}]
    log     release=${releaseStr}         TRACE
    @{matches}      split string    ${releaseStr}      ,
    log     got the matches: ${matches}           TRACE
    ${release}      get from list       ${matches}      0
    log     we've got the release information: ${release}.
    [Return]      ${release}

get_eut_distro
    [Arguments]    ${device}
    [Documentation]      this is the keyword used to get single device's distro information
    [Tags]         @author=CindyGao
    ${res}    Cli   ${device}   show version
    ${matches}      Get Regexp Matches     ${res}       distro\\s*"(.*)"\r    1
    log       we've got the matches: ${matches}              TRACE
    ${distro}       Get From List      ${matches}    0
    log       we've got the build informations : ${distro}
    [Return]      ${distro}

mapping_distro_to_release
    [Arguments]    ${distro}    ${map}=${CURDIR}/build_release_mapping.txt
    [Documentation]    this is the keyword used to mapping build id to release name
    [Tags]    @author=CindyGao
    # handle the build number, remove the build id from the full build convert to string
    ${build}    Remove string using regexp      ${distro}      \\s+.*$
    log    the branch of the build is : ${build}

    ${fileHandler}    EVALUATE   open('${map}').readlines()
    log    the mapping file content : ${fileHandler}        TRACE
    convert to list     ${fileHandler}
    ${rowIndex}    set variable     0
    :FOR    ${rowitem}     IN     @{fileHandler}
    \    log    current row index:${rowIndex} item:${rowitem}    TRACE
    \    ${contain_build}    Run Keyword And Return Status    Should Contain    ${rowitem}    ${build}
    \    log    build ${build} search result is ${contain_build}
    \    exit for loop if    ${contain_build}
    \    ${rowIndex}   evaluate    ${rowIndex}+1
    Return From Keyword If    '${contain_build}'!='True'    NONE
    log    we find the release info in ${rowIndex} row    TRACE
    ${len}     get length       ${fileHandler}
    ${releaseStr}    convert to string   @{fileHandler}[${rowIndex}]
    log     release=${releaseStr}         TRACE
    @{matches}      split string    ${releaseStr}      ,
    log     got the matches: ${matches}           TRACE
    ${release}      get from list       ${matches}      0
    log     we've got the release information: ${release}.
    [Return]      ${release}

set_eut_version
    [Arguments]    ${device}=${EMPTY}
    [Documentation]  set EUT build and release attribution
    # [EEXA-12631] modify by CindyGao, start
    log    If device is not specified, get it from topo.yaml ${DEVICES} list
    ${keys}    Run Keyword If    '${EMPTY}'!='${device}'    Create List    ${device}
    ...    ELSE    get dictionary keys     ${DEVICES}
    # [EEXA-12631] modify by CindyGao, end
    :FOR    ${eut}    IN    @{keys}
    \    Log    current eut is ${eut}, type is ${DEVICES.${eut}.type}          TRACE
    \    continue for loop if    '${DEVICES.${eut}.type}'!='AXOS'
    \    ${build}       get_eut_version        ${eut}
    \    set to dictionary      ${DEVICES.${eut}}       build       ${build}
    \    Log    eut(${eut})'s build is ${DEVICES.${eut}.build}       TRACE
    \    # [AT-3619] modify by CindyGao, start
    \    ${distro}       get_eut_distro        ${eut}
    \    ${release}      mapping_distro_to_release       ${distro}
    \    Continue For Loop If    'NONE'=='${release}'
    \    # [AT-3619] modify by CindyGao, end
    \    set to dictionary      ${DEVICES.${eut}}       release       ${release}
    \    Log    eut(${eut})'s release is ${DEVICES.${eut}.release}        TRACE

