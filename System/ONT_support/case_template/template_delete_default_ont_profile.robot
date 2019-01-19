*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
template_delete_default_ont_profile
    [Arguments]    ${device}    ${profile_id}
    [Documentation]
    ...    1	Delete default ont-profile	rejected		
    [Tags]     @author=YUE SUN    @user_interface=CLI    
    
    log    STEP:1 Delete default ont-profile rejected
    check_running_configure    ${device}    ont-profile    ${profile_id}
    dprov_object_invaild    ${device}    ont-profile    ${profile_id}
    check_running_configure    ${device}    ont-profile    ${profile_id}