*** Settings ***
Documentation   Common keywords
Library         Collections
Library         String
Library         XML
Library         Telnet
Library      OperatingSystem
Library      DateTime



Resource        caferobot/cafebase.robot
Resource        keyword/keyword_common.robot
Resource        keyword/keyword_command.robot
Resource        keyword/keyword_svc.robot
Resource        keyword/keyword_service_model.robot
Resource        keyword/keyword_tg.robot
Resource        keyword/release_adapter.robot
Resource        keyword/param_release_adapter.robot


