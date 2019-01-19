*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       Inband_Management_Support_suite_provision
Suite Teardown    Inband_Management_Support_suite_deprovision
Force Tags        @feature=Management    @subfeature=Inband_Management_Support    @author=Ronnie_Yi   @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***


*** Keywords ***
Inband_Management_Support_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=Yeast Jiang
#    run keyword and ignore error    cli    n1_console    sysadmin    retry=0    timeout=0    timeout_exception=0
#    run keyword and ignore error    Axos Cli With Error Check    n1_console    cli
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
#    run keyword and ignore error    Axos Cli With Error Check    n1_console    cli
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    Axos Cli With Error Check    n1_console    paginate false
    Axos Cli With Error Check    n1_console    idle-time 0
    service_point_prov    service_point_list1
    Unconfigure Craft Port    n1_console    ${craft}
    Disable Craft Port    n1_console    ${craft}
    cli    n1_console         show user-sessions
    cli    n1_console         show running-config |nomore  timeout=30




Inband_Management_Support_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=Yeast Jiang
    run keyword and ignore error    cli    n1_console    sysadmin    retry=0    timeout=0    timeout_exception=0
    run keyword and ignore error    cli    n1_console    sysadmin    retry=0    timeout=0    timeout_exception=0
    run keyword and ignore error    Axos Cli With Error Check    n1_console    cli
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    run keyword and ignore error    Axos Cli With Error Check    n1_console    cli
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    Axos Cli With Error Check    n1_console    paginate false
    Axos Cli With Error Check    n1_console    idle-time 0
    service_point_dprov    service_point_list1
    Configure Craft Port    n1_console    ${craft}    ${ssh_ip}    24    ${gateway}
    Enable Craft Port    n1_console    ${craft}
    ${tmp}    cli    eutA    show running-config interface craft ${craft}
    should contain    ${tmp}    ${ssh_ip}
    # add by llin @2017.10.13 for AT-3199
#    Axos Cli With Error Check    n1_console    copy running-config startup-config
    # add by llin @2017.10.13 for AT-3199
    Copy Running Config To Startup Config      n1_console