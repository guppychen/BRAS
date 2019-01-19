*** Settings ***
Documentation   Initialization file of feature_x test suites
...             It is for putting suite level setup and teardown keywords
...             And setting the forced tags for all the test cases in  "feature_x" folder and its subfolder
Force Tags        @require=1eut       @eut=GPON-8r2
Suite Setup       alarm_setup

Suite Teardown    alarm teardown
Resource          ./base.robot

*** Keywords ***
alarm teardown
    [Tags]    @author=chxu
    run keyword and ignore error   Reload The Device With Default Startup   n1
    Application Restart Check   n1

alarm_setup
    [Documentation]    suite provision for MVR support
    [Tags]       @author=CindyGao
    log    set eut version and release
    set_eut_version