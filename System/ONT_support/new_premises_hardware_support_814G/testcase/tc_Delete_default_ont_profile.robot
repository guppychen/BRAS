*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Delete_default_ont_profile
    [Documentation]
      	
    ...    1	Delete ont-profile 814G	rejected	Check with E7-2	
    

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4676      @globalid=2533406      @priority=P1      @eut=GPON-8r2          @user_interface=CLI    
    [Template]    template_delete_default_ont_profile
    eutA    ${service_model.subscriber_point1.attribute.ont_profile_id}


    