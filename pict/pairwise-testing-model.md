## How to work with Pairwise Independent Combinatorial Testing tool ([PICT](https://github.com/Microsoft/pict/blob/main/doc/pict.md))

`PICT` is a command-line tool that accepts a plain-text model file as an input and produces a set of test cases.
`PICT` allows you to specify variations for each of your parameter separately. 

**The task is:** 
1. Download `Microsoft PICT`.
2. Create model according to the following inputs:

   | **App Type** | **Mobile Platform** | **Browser** | **Programming Language** | **Unit FWK** | **Web FWK** | **Mobile FWK** | **Infrastructure** |
   | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
   | Web | iOS | Chrome | Java | Test NG | Selenide | Appium | Selenium Grid |
   | Mobile Native  | Android  | Firefox | JS | JUnit | Serenity | Expresso | Selenoid |
   | Hybrid | Safari | | Python | Mocha | WebdriverIO | XCUITest | 
   | | | | Swift| Jest | Cypress | Detox |
   | | | | C# | Jasmine | CodeceptJS | Xamarin | 
   | | | | | PyTest | Puppeteer |
   | | | | | Unittest | Playwright | 
   | | | | | Nose2 | Helium | 
  
3. Provide **restrictions** to examine the above inputs to define values that can live together and which are mutually exclusive.
4. Add `PICT` raw output.
5. Convert result to `JSON` array.

### Downloading and using PICT tool

`PICT` is a single executable that runs from a shell command line. 
`PICT` is very fast, very powerful and should meet your pairwise testing needs in most situations.

[`PICT`](https://github.com/Microsoft/pict/blob/main/doc/pict.md) is available only for Windows. 
If you have a different OS, you have to build it from sources by cloning this project from **GitHub** and following the **README** instructions.

After the download is completed, the installation process does not require special attention:
 1. Create folder `pict` and move `pict.exe` to this folder.
 2. Navigate to the `pict` directory and create a new **test.txt** text file and fill in the parameters.
 3. Open the command line and switch to the installation directory.
 4. Generate use case: Enter the command: `pict test.txt` to generate use cases.
 5. Save the use case: Enter the command: `pict test.txt > test.xls`.
 
### Creation model with restrictions

The restrictions for the above inputs see below:

 - The **General** restriction according to `Application type`.
 - `Web Frameworks` restrictions for `Programming language`.
 - `Unit Frameworks` restrictions for `Programming language`.
 - `Mobile Frameworks` restrictions for `Programming language`.
 - Unique restrictions.
 
### Final model with restrictions

```bash
Application Type:     Web, Mobile Native, Hybrid
Mobile Platform:      iOS, Android,  , 
Browser:              Chrome, Firefox, Safari,  ,
Programming Language: Java, JS, Python, Swift, C#
Unit Framework:       TestNG, JUnit, Mocha, Jest, Jasmine, PyTest, Unittest, Nose2, xUnit,  , 
Web Frameworks:       Selenide, Serenity, WebdriverIO, Cypress, CodeceptJS, Puppeteer, Playwright, Helium,  ,
Mobile Frameworks:    Appium, Espresso, XCUITest, Detox, Xamarin,  , 
Infrastructure:       Selenium Grid, Selenoid

# Restrictions for Application type
IF [Application Type] in {"Mobile Native", "Hybrid"} THEN [Browser] = "" AND [Web Frameworks] = "" AND NOT [Mobile Frameworks] = "";
IF [Application Type] = "Web" THEN NOT [Browser] = "" AND [Mobile Platform] = "" AND [Mobile Frameworks] = "" AND NOT [Web Frameworks] = "";
IF [Application Type] in {"Mobile Native", "Hybrid"} THEN NOT [Mobile Platform] = "";

# Web Framewors restrictions for Programming language
IF [Programming Language] = "Java" AND [Application Type] = "Web" THEN  [Web Frameworks] in {"Playwright", "Selenide", "Serenity"};
IF [Programming Language] = "JS" AND [Application Type] = "Web" THEN  [Web Frameworks] in {"WebdriverIO", "Cypress", "CodeceptJS", "Puppeteer", "Playwright"};
IF [Programming Language] = "Python" AND [Application Type] = "Web" THEN  [Web Frameworks] in {"Playwright", "Helium"};
IF [Programming Language] = "C#" AND [Application Type] = "Web" THEN  [Web Frameworks] in { "Playwright"};

# Unit Framewors restrictions for Programming language
IF [Programming Language] = "Java" THEN [Unit Framework] in {"TestNG", "JUnit"} AND NOT [Unit Framework] = "";
IF [Programming Language] = "JS" THEN [Unit Framework] in {"Mocha", "Jest", "Jasmine"} AND NOT [Unit Framework] = "";
IF [Programming Language] = "Python" THEN [Unit Framework] in {"PyTest", "Nose2", "Unittest"} AND NOT [Unit Framework] = "";
IF [Programming Language] = "Swift" THEN [Unit Framework] = "" AND NOT [Application Type] = "Web";
IF [Programming Language] = "C#" THEN [Unit Framework] in {"xUnit"} AND NOT [Unit Framework] = "";

# Mobile Framewors restrictions for Programming language
IF [Mobile Frameworks] = "Appium" THEN [Programming Language] in {"Java", "JS", "Python", "C#"};
IF [Mobile Frameworks] = "Espresso" THEN NOT [Mobile Platform] = "iOS" AND [Programming Language] = "Java";
IF [Mobile Frameworks] = "Detox" THEN [Programming Language] = "JS" AND NOT [Unit Framework] = "Mocha" AND [Application Type] = "Mobile Native";
IF [Mobile Frameworks] = "XCUITest" THEN [Programming Language] = "Swift" AND [Mobile Platform] = "iOS" AND NOT [Application Type] = "Hybrid";
IF [Mobile Frameworks] = "Xamarin" THEN [Programming Language] = "C#";

# Unique restrictions
IF [Web Frameworks] in {"Helium", "CodeceptJS", "Cypress", "Serenity"} THEN NOT [Browser] = "Safari";
IF [Web Frameworks] = "Puppeteer" THEN [Browser] = "Chrome";
```
 
Also, the `pairwise-testing-of-automation-tools.txt` is available [here](https://github.com/mkgerasimenko/TIL/blob/main/pict/pairwise-testing-of-automation-tools.txt)

To perform calculation we should use next command:

```powershell
.\pict.exe pairwise-testing-of-automation-tools.txt /o:1
```
Why we should use `\o:1`? In our case, we should use `order of combination = 1` to reduce the tests.

The final output is:

![PICT output](https://github.com/mkgerasimenko/TIL/blob/main/pict/PICT-output.png)

### Converting output from PICT to JSON

Firstly we should save output into a `CSV` file: 

```powershell
.\pict.exe pairwise-testing-of-automation-tools.txt > pairwise-testing-of-automation-tools.csv /o:1
```

Next we can use the `ConvertTo-Json` cmdlet to convert our `CSV` file into a `JSON`:

```powershell
Import-Csv -Path "CSV.csv"|ConvertTo-Json| Out-File -FilePath "pairwise-testing-of-automation-tools.json"
```

Also, we can create a simple `generate-JSON-from-CSV.ps1` script to perform those actions:

```powershell
$path=[Environment]::GetFolderPath('Desktop')
$content = Import-Csv -Path "$path\pairwise-testing-of-automation-tools.csv"
$content|ConvertTo-Json| Out-File -FilePath "$path\pairwise-testing-of-automation-tools.json"
```

The `pairwise-testing-of-automation-tools.json` is available [here](https://github.com/mkgerasimenko/TIL/blob/main/pict/pairwise-testing-of-automation-tools.json)

#### For more information about this topic, please use the links below: 
 
[PICT](https://github.com/microsoft/pict) \
[ConverTo-Json](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-json?view=powershell-7.1)  
 