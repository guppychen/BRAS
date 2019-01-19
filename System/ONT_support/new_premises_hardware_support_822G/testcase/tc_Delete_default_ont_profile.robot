*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Delete_default_ont_profile
    [Documentation]
      
    ...    1	Delete ont-profile 822G	rejected		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4311      @globalid=2531496      @priority=P1      @eut=GPON-8r2          @user_interface=CLI    
    [Template]    template_delete_default_ont_profile
    eutA    ${service_model.subscriber_point1.attribute.ont_profile_id}