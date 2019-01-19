*** Settings ***
Documentation    test_suite keyword lib
Resource         ../base.robot

*** Variable ***


*** Keywords ***
prov_interface_err
    [Arguments]    ${device}    ${port_type}    ${port_name}    ${svc_vlan}=${EMPTY}      &{dict_cmd}
    [Documentation]    Description: interface provision error
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | eut node in topo.yaml |
    ...    | port_type | interface type |
    ...    | port_name | interface name |
    ...    | svc_vlan | Ethernet service vlan |

    [Tags]    @author=joli
    log    ****** [${device}] provision interface ${port_type} ${port_name}: svlan=${svc_vlan} ******
    cli    ${device}    configure
    cli   ${device}    interface ${port_type} ${port_name}
    run keyword if    '${EMPTY}'!='${svc_vlan}'    cli    ${device}    vlan ${svc_vlan}
    Result Should contain  Error
    [Teardown]    cli    ${device}    end


