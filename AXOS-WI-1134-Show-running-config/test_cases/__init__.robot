*** Settings ***
Suite Setup       provision
Suite Teardown    deprovision
Force Tags        @feature=Show-running-config support    @subfeature=Show-running-config support    @priority=P1    @eut=NGPON2-4      @require=1eut  @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***

*** Keywords ***
provision
    [Documentation]    for single ont topo setup
    [Tags]    @author=AnsonZhang
    log    This is just the Keyword template, replace it with your truly keyword.
    provision_class_map    n1_sysadmin    ${class_map_name}    ${g_class_map_type[0]}
    provision_policy_map    n1_sysadmin    ${policy_map_name}
    add_class_map_to_policy_map    n1_sysadmin    ${class_map_name}    ${policy_map_name}    ${g_class_map_type[0]}
    log    add flow to class map
    add_flow_to_class_map    n1_sysadmin    ${class_map_name}    ${g_class_map_type[0]}    ${g_flow_index[0]}
    add_flow_to_policy_map    n1_sysadmin    ${class_map_name}    ${policy_map_name}    ${g_class_map_type[0]}    ${g_flow_index[0]}


deprovision
    [Documentation]    delete the single ont topo provision
    [Tags]    @author=Zhang
    log    This is just the Keyword template, replace it with your truly keyword.
    delete_policy_map    n1_sysadmin    ${policy_map_name}
    delete_class_map    n1_sysadmin    ${class_map_name}    ${g_class_map_type[0]}