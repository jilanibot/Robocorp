*** Settings ***
Documentation       Build and Order the Robot

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.Desktop
Library             RPA.PDF
Library             OperatingSystem
Library             RPA.Archive


*** Tasks ***
Build and Order the Robot
    Empty the Existing Folder
    Open the robocorp website
    Download the Excel
    Open the Build order Robot website
    Fill the form using the data from the Excel file
    Create ZIP Folder


*** Keywords ***
Empty the Existing Folder
    Empty Directory    ${CURDIR}${/}image
    Empty Directory    ${CURDIR}${/}pdf
    Empty Directory    ${OUTPUT_DIR}${/}file

Open the robocorp website
    Open Available Browser    https://robocorp.com/docs/courses/build-a-robot

Download the Excel
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    Close Browser

Open the Build order Robot website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Maximize Browser Window
    Wait Until Page Contains Element    css:div.modal-content
    Click Button    css:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark

Fill the form using the data from the Excel file
    ${readcsv}=    Read table from CSV    orders.csv    header=True
    FOR    ${row}    IN    @{readcsv}
        Fill Out the Form    ${row}
    END

Fill Out the Form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Sleep    2s
    Select Radio Button    body    ${row}[Body]
    Sleep    1s
    Input Text    css:input[class='form-control']    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Sleep    2s
    Click Button    preview
    Sleep    3s
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]
    WHILE    True
        TRY
            ${Order}=    Get Element Attribute    id:order-completion    outerHTML
        EXCEPT
            Click Button    order
        ELSE
            ${badgeno}=    Get Text    //*[@id="receipt"]/p[1]
            Html To Pdf    ${Order}    ${CURDIR}${/}pdf${/}${badgeno}.pdf
            Set Local Variable    ${screenshot}    //*[@id="robot-preview-image"]
            Screenshot    ${screenshot}    ${CURDIR}${/}image${/}${badgeno}.png
            ${Files}=    Create List
            ...    ${CURDIR}${/}pdf${/}${badgeno}.pdf
            ...    ${CURDIR}${/}image${/}${badgeno}.png
            Add Files To Pdf    ${Files}    ${OUTPUT_DIR}${/}file${/}${badgeno}.pdf
            BREAK
        END
    END
    Sleep    2s
    Click Button    order-another
    Sleep    2s
    Wait Until Keyword Succeeds    10x    3s    Wait Until Page Contains Element    css:div.container
    Sleep    2s
    Wait Until Keyword Succeeds
    ...    5x
    ...    3s
    ...    Click Button
    ...    css:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark

Create ZIP Folder
    Archive Folder With Zip    ${OUTPUT_DIR}${/}file    ${OUTPUT_DIR}${/}RobotTask.zip    True    include=*.pdf
