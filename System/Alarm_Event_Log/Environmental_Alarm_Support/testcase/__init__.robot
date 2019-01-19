*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       environment_alarm_support_suite_provision
Suite Teardown    environment_alarm_support_suite_deprovision
Force Tags        @feature=Alarm_Event_log    @subfeature=Environmental Alarm Support    @author=PEIJUN LIU    @jira=EXA-23158   @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***


*** Keywords ***
environment_alarm_support_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    set eut version

environment_alarm_support_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    Application Restart Check   eutA