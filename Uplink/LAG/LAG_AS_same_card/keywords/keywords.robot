*** Settings ***
Documentation     Suite description
Resource          ../base.robot

*** Keywords ***
lag_prov
    [Arguments]    ${eut}    ${lag_no}    ${lacp_mode}    ${max_port}    ${min_port}    ${hash_mode}='src-dst-ip'
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    inter la ${lag_no}
    cli    ${eut}    switchport enable
    cli    ${eut}    lacp-mode ${lacp_mode}
    cli    ${eut}    hash-method ${hash_mode}
    cli    ${eut}    max-port ${max_port}
    cli    ${eut}    min-port ${min_port}
    cli    ${eut}    no shut
    cli    ${eut}    end


lag_inter_unprov
    [Arguments]    ${eut}    ${eth_port_1}    ${lag_no}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    inter eth ${eth_port_1}
    cli    ${eut}    shut
    cli    ${eut}    no group
    cli    ${eut}    no role
    cli    ${eut}    end


lag_inter_deprov
    [Arguments]    ${eut}    ${eth_port_1}    ${lag_no}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    inter eth ${eth_port_1}
    cli    ${eut}    shut
    cli    ${eut}    no group
    cli    ${eut}    no role
    cli    ${eut}    end

get_lag_interface_status
    [Arguments]     ${eut}    ${lag_no}
    [Tags]    @author=llin
    ${res}     cli     ${eut}    show inter la ${lag_no} status
    [Return]    ${res}

check_lag_interface_status
    [Arguments]     ${eut}    ${lag_no}    ${expect_admin_status}     ${expect_oper_status}
    [Tags]    @author=llin
    ${res}     get_lag_interface_status    ${eut}  ${lag_no}
    ${real_admin_status}    should Match Regexp    ${res}    admin-state\\s+(\\w+)
    ${real_oper_status}    should Match Regexp    ${res}    oper-state\\s+(\\w+)
    log  real_admin_status=${real_admin_status}
    log  real_oper_status=${real_oper_status}
    should contain    ${real_admin_status}    ${admin_state}
    should contain    ${real_oper_status}    ${opr_state}
