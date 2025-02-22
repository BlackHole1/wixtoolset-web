@setlocal
@pushd %~dp0

@set _C=Debug
@set _L=%~dp0..\build\logs
@set _T=

:parse_args
@if /i "%1"=="release" set _C=Release
@if not "%1"=="" set _T=%1
@if not "%1"=="" shift & goto parse_args

@echo Building web %_C%

@echo Build and test tools
dotnet build FeedGenerator -c %_C% -nologo
dotnet build XmlDocToMarkdown\XmlDocToMarkdown.csproj -c %_C% -nologo -m -warnaserror -bl:%_L%\buildxmldoc.binlog || exit /b
dotnet test test\XsdToMarkdownTests\XsdToMarkdownTests.csproj -c %_C% -nologo -m -warnaserror -bl:%_L%\build.binlog || exit /b
echo.

@echo Build bundle update feed
..\build\%_C%\FeedGenerator.exe WixAdditionalTools 4.0 feeds\wix-additional-tools-4-0.template Docusaurus\static\releases\feeds\ "%_T%" || exit /b
echo.

@echo Build schema and API reference markdown
dotnet build mkdoc\mkdoc.proj -c %_C% -nologo -m -warnaserror -bl:%_L%\mkdoc.binlog || exit /b
echo.

@echo Build static web site
call npm --prefix Docusaurus run build -- --out-dir ..\..\build\deploy\wwwroot || exit /b
echo.

@popd
@endlocal
