*** Settings ***
Force Tags     @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=kshettar
Resource          base.robot

*** Variables ***
${copy}           <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="6"><copy-config><target><url>${upgrade_usr}:${upgrade_pwd}@${upgrade_server}/tftpboot/Image/ROLT_1889_ftp_2</url></target><source><url>ftp://DPU_PROJ:DPU_PROJ@10.243.245.23/tftpboot/Image/ROLT_1889_ftp_1</url></source></copy-config></rpc>]]>]]>

*** Test Cases ***
tc_The_EXA_device_MUST_not_support_a_copy_config_operation_where_both_the_source_and_target_datastores_are_specified_by_remote_URLs
    [Documentation]    EXA device must not support a copy config operation where both the source and target datastores are specified by remote URLs
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1780        @globalid=2322311

    #copy config with target and source remote URLs
    @{res}    Raw netconf configure    n1_session3    ${copy}    error-tag
    should be equal as strings    ${res[0].text}    operation-failed
