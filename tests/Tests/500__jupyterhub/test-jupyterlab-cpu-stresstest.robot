*** Settings ***
Resource         ../../Resources/ODS.robot
Resource         ../../Resources/Common.robot
Resource         ../../Resources/Page/ODH/JupyterHub/JupyterHubSpawner.robot
Resource         ../../Resources/Page/ODH/JupyterHub/JupyterLabLauncher.robot
Library          DebugLibrary

#Suite Setup      Begin Web Test
Suite Setup      Accelerated Setup Suite
Suite Teardown   End Web Test


*** Keywords ***
Accelerated Setup Suite
  Set Library Search Order  SeleniumLibrary

  Open Browser  ${ODH_DASHBOARD_URL}  browser=${BROWSER.NAME}  options=${BROWSER.OPTIONS}


*** Variables ***


*** Test Cases ***

Open RHODS Dashboard
  [Tags]  Sanity
  Login To RHODS Dashboard  ${TEST_USER.USERNAME}  ${TEST_USER.PASSWORD}  ${TEST_USER.AUTH_TYPE}
  Wait for RHODS Dashboard to Load

Can Launch Jupyterhub
  [Tags]  Sanity
  ${version-check} =  Is RHODS Version Greater Or Equal Than  1.4.0
  IF  ${version-check}==True
    Launch JupyterHub From RHODS Dashboard Link
  ELSE
    Launch JupyterHub From RHODS Dashboard Dropdown
  END

Can Login to Jupyterhub
  [Tags]  Sanity
  Login To Jupyterhub  ${TEST_USER.USERNAME}  ${TEST_USER.PASSWORD}  ${TEST_USER.AUTH_TYPE}
  ${authorization_required} =  Is Service Account Authorization Required
  Run Keyword If  ${authorization_required}  Authorize jupyterhub service account
  Wait Until Page Contains Element  xpath://span[@id='jupyterhub-logo']

Can Spawn Notebook
  [Tags]  Sanity
  ## I know the below is needed, but it's quite time consuming!
  #Fix Spawner Status
  Spawn Notebook With Arguments  image=s2i-generic-data-science-notebook

Git Clone the notebooks we need
  Wait for JupyterLab Splash Screen  timeout=60
  Maybe Close Popup
  ${is_launcher_selected} =  Run Keyword And Return Status  JupyterLab Launcher Tab Is Selected
  Run Keyword If  not ${is_launcher_selected}  Open JupyterLab Launcher
  Launch a new JupyterLab Document
  Add and Run JupyterLab Code Cell in Active Notebook  !rm -rf ~/PublicNotebooks/
  Close Other JupyterLab Tabs
  Capture Page Screenshot
  Navigate Home (Root folder) In JupyterLab Sidebar File Browser
  Open With JupyterLab Menu  Git  Clone a Repository
  Input Text  //div[.="Clone a repo"]/../div[contains(@class, "jp-Dialog-body")]//input  https://github.com/erwangranger/PublicNotebooks.git
  Click Element  xpath://div[.="CLONE"]
  Sleep  10


Run the 1 core notebook
  [Tags]  CPU StressTest




Run the 1 core notebook
  [Tags]  CPU StressTest
  Open With JupyterLab Menu  File  Open from Path…
  Input Text  xpath=//input[@placeholder="/path/relative/to/jlab/root"]  PublicNotebooks/CPU.Stress.1.core.ipynb
  Click Element  xpath://div[.="Open"]
  Wait Until CPU.Stress.1.core.ipynb JupyterLab Tab Is Selected
  Close Other JupyterLab Tabs
  Sleep  5
  Capture Page Screenshot
  Open With JupyterLab Menu  Run  Run All Cells
  Capture Page Screenshot

  ## because the test will take 10 minutes
  Wait Until JupyterLab Code Cell Is Not Active  timeout=3000
  Capture Page Screenshot
  Run Cell And Check Output  print("done")  done
  Capture Page Screenshot

Run the all cores notebook
  [Tags]  CPU StressTest

  Open With JupyterLab Menu  File  Open from Path…
  Input Text  xpath=//input[@placeholder="/path/relative/to/jlab/root"]  PublicNotebooks/CPU.Stress.all.cores.ipynb
  Click Element  xpath://div[.="Open"]
  Wait Until CPU.Stress.all.cores.ipynb JupyterLab Tab Is Selected

  Close Other JupyterLab Tabs
  Sleep  5
  Capture Page Screenshot
  Open With JupyterLab Menu  Run  Run All Cells
  Capture Page Screenshot

  ## because the test will take 1 minute
  Wait Until JupyterLab Code Cell Is Not Active  timeout=300
  Capture Page Screenshot
  Run Cell And Check Output  print("done")  done
  Capture Page Screenshot
  JupyterLab Code Cell Error Output Should Not Be Visible
  ${output} =  Get Text  (//div[contains(@class,"jp-OutputArea-output")])[last()]
  Should Not Match  ${output}  ERROR*

Clean up the files and folders we created
  Add and Run JupyterLab Code Cell in Active Notebook  !rm -rf ~/Untitled*
  Add and Run JupyterLab Code Cell in Active Notebook  !rm -rf ~/PublicNotebooks/
  Capture Page Screenshot

Can Close Notebook when done
  Clean Up Server
  Stop JupyterLab Notebook Server
  # Capture Page Screenshot
  # Go To  ${ODH_DASHBOARD_URL}
