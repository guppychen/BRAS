*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       support_819g_suite_provision
Suite Teardown    support_819g_suite_deprovision
Force Tags        @feature=ONT support    @subfeature=New premises hardware support (819G)    @author=YUE SUN    
Resource          ./base.robot

*** Keywords ***
support_819g_suite_provision
    [Documentation]    suite provision for sub_feature
    log    set eut version and release
    set_eut_version
    log    set paginate false
    paginate_set    eutA    false
    log    enable pon port  
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    no_shutdown_port    eutA    pon    ${pon_port}

support_819g_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    set paginate true
    paginate_set    eutA    true
    log    disable pon port
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    shutdown_port    eutA    pon    ${pon_port}

