*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       Encryption_for_NG-PON2_OIMs_XGS-PON_OIMS_suite_provision
Suite Teardown    Encryption_for_NG-PON2_OIMs_XGS-PON_OIMS_suite_deprovision
Force Tags        @feature=HW_Suppport    @subfeature=Encryption_for_NG-PON2_OIMs_XGS-PON_OIMs    @author=XUAN_LI
Resource          ./base.robot

*** Variables ***


*** Keywords ***
Encryption_for_NG-PON2_OIMs_XGS-PON_OIMS_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=XUAN_LI
    log    suite provision for sub_feature
    
Encryption_for_NG-PON2_OIMs_XGS-PON_OIMS_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=XUAN_LI
    log    suite deprovision for sub_feature
    