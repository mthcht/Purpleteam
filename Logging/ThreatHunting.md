### Log investigation

#### Get last 5 minutes generated logs on system:

`$t=(Get-Date).AddMinutes(-5);Get-WinEvent -ListLog * | %{Get-WinEvent -FilterHashtable @{LogName=$_.LogName; StartTime=$t;} -ErrorAction Ignore | Format-Table -AutoSize -Wrap} | Out-File last5minuteslogs.txt`

#### Search for a specific string in all recent generated logs:

`$t=(Get-Date).AddMinutes(-5);Get-WinEvent -ListLog * | %{Get-WinEvent -FilterHashtable @{LogName=$_.LogName; StartTime=$t;} -ErrorAction Ignore  | Where-Object {$_.Message -like "*FIXME*"} | Format-Table -AutoSize -Wrap}` 

####  Get last 5 minutes modified files on system:

`$t = (Get-Date).AddMinutes(-5);Get-ChildItem -Path "$env:HOMEDRIVE\" -Recurse -Force -ErrorAction Ignore | Where-Object { $_.LastWriteTime -gt $t } | Format-Table -AutoSize -Wrap | Out-File last5minutesfiles.txt`

`Get-ChildItem -Path "$env:HOMEDRIVE\" -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMinutes(-5)} | foreach {Write-Host $_.FullName - $_.LastWriteTime}`

Note:  -Attributes with Get-ChildItem can help you find more files

add "-Attributes Hidden" for the last modified hidden files/dir for example...

#### Get Basic Sysmon Event ID 1 Informations ParentImage - Image - CommandLine in powershell
```
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1} | ForEach-Object {
    $eventXml = [xml]$_.ToXml()
    $process = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'Image' }
    $parentProcess = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'ParentImage' }
    $commandLine = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'CommandLine' }
    $timeCreated = $_.TimeCreated

    [PSCustomObject]@{
        TimeCreated = $timeCreated
        Process = $process.'#text'
        ParentProcess = $parentProcess.'#text'
        CommandLine = $commandLine.'#text'
    }
} | Sort-Object TimeCreated
```

### Static analysis

#### Get all hashes on the system:
for windows:
`Get-ChildItem -Path . -Recurse -File | Get-FileHash -Algorithm SHA256`

for linux:
`find ../ -type f -print0 | xargs -0 sha256sum`

#### Extract Informations from powershell scripts:

- extract powershell scripts informations with powershell:

ex: `powershell -ep Bypass keywords_in_powershell_scripts.ps1 c:\users\mthcht\desktop\mimikatz.ps1` 

```powershell
param (
    [Parameter(Mandatory=$true)]
    [string]$ScriptPath
)

function Extract-ScriptInfo {
    param (
        [string]$ScriptPath
    )

    $tokens = $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        $ScriptPath,
        [ref]$tokens,
        [ref]$errors
    )

    # Function names
    $function_definitions = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
    $function_names = $function_definitions.Name

    # Command invocations
    $command_invocations = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true)
    $invoked_commands = $command_invocations | ForEach-Object { $_.CommandElements[0].Value }

    # Available arguments
    $param_blocks = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.ParamBlockAst] }, $true)
    $available_arguments = $param_blocks | ForEach-Object { $_.Parameters.Name.VariablePath.UserPath }

    $script_info = @{
        FunctionNames = $function_names
        InvokedCommands = $invoked_commands
        AvailableArguments = $available_arguments
    }

    return $script_info
}

$script_info = Extract-ScriptInfo -ScriptPath $ScriptPath
Write-Host "Function names:`n $($script_info.FunctionNames -join ',')"
Write-Host "Invoked commands:`n $($script_info.InvokedCommands -join ',')"
Write-Host "Available arguments:`n $($script_info.AvailableArguments -join ',')"
```

- extract powershell scripts informations with python (for analysis on linux):

ex: `python3 keywords_in_powershell_scripts.ps1 /home/mthcht/mimikatz.ps1`

```python
import argparse
import subprocess
import json

def extract_script_info(script_path):
    script = f"""
    $tokens = $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        \"{script_path}\",
        [ref]$tokens,
        [ref]$errors)

    # Function names
    $function_definitions = $ast.FindAll({{ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }}, $true)
    $function_names = $function_definitions.Name

    # Command invocations
    $command_invocations = $ast.FindAll({{ param($node) $node -is [System.Management.Automation.Language.CommandAst] }}, $true)
    $invoked_commands = $command_invocations | ForEach-Object {{ $_.CommandElements[0].Value }}

    # Available arguments
    $param_blocks = $ast.FindAll({{ param($node) $node -is [System.Management.Automation.Language.ParamBlockAst] }}, $true)
    $available_arguments = $param_blocks | ForEach-Object {{ $_.Parameters.Name.VariablePath.UserPath }}

    $script_info = @{{
        FunctionNames = $function_names
        InvokedCommands = $invoked_commands
        AvailableArguments = $available_arguments
    }}
    $script_info | ConvertTo-Json
    """
    result = subprocess.run(
        ["pwsh", "-Command", script],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print("PowerShell Error:", result.stderr)
        raise Exception("Failed to extract script information")

    print("PowerShell Output:", result.stdout)

    if result.stdout.strip() == "null":
        return {}

    script_info = json.loads(result.stdout)
    return script_info

def main():
    parser = argparse.ArgumentParser(description="Extract script information from a PowerShell script.")
    parser.add_argument("script_path", help="Path to the PowerShell script")

    args = parser.parse_args()
    script_path = args.script_path

    script_info = extract_script_info(script_path)
    print("Function names:{}\n".format(script_info.get("FunctionNames", [])))
    print("Invoked commands:{}\n".format(script_info.get("InvokedCommands", [])))
    print("Available arguments:{}\n".format(script_info.get("AvailableArguments", [])))

if __name__ == "__main__":
    main()
```

#### Extract Informations from python scripts:

- extract python scripts informations with python:

ex: `python3 keywords_in_python_scripts.py /home/mthcht/mimikatz.py`

```python
import argparse
import ast

class PythonScriptInfoExtractor(ast.NodeVisitor):
    def __init__(self):
        self.function_names = []
        self.imported_modules = []
        self.function_arguments = {}
        self.script_arguments = []

    def visit_FunctionDef(self, node):
        self.function_names.append(node.name)
        self.function_arguments[node.name] = [arg.arg for arg in node.args.args]
        self.generic_visit(node)

    def visit_Import(self, node):
        for alias in node.names:
            self.imported_modules.append(alias.name)
        self.generic_visit(node)

    def visit_ImportFrom(self, node):
        module_name = node.module
        for alias in node.names:
            self.imported_modules.append(f"{module_name}.{alias.name}")
        self.generic_visit(node)

    def visit_Call(self, node):
        if isinstance(node.func, ast.Attribute):
            if node.func.attr == 'add_argument':
                if isinstance(node.func.value, ast.Name) and node.func.value.id == 'parser':
                    arg = node.args[0].s if node.args else None
                    if arg:
                        self.script_arguments.append(arg)
        self.generic_visit(node)

def extract_python_script_info(script_path):
    with open(script_path, "r") as source:
        node = ast.parse(source.read())

    extractor = PythonScriptInfoExtractor()
    extractor.visit(node)

    return {
        "FunctionNames": extractor.function_names,
        "ImportedModules": extractor.imported_modules,
        "FunctionArguments": extractor.function_arguments,
        "ScriptArguments": extractor.script_arguments,
    }

def main():
    parser = argparse.ArgumentParser(description="Extract script information from a Python script.")
    parser.add_argument("script_path", help="Path to the Python script")

    args = parser.parse_args()
    script_path = args.script_path

    script_info = extract_python_script_info(script_path)
    print("Function names:\n", script_info["FunctionNames"])
    print("Imported modules:\n", script_info["ImportedModules"])
    print("Function arguments:")
    for func_name, args in script_info["FunctionArguments"].items():
        print(f"  {func_name}: {args}")
    print("Script arguments:\n", script_info["ScriptArguments"])

if __name__ == "__main__":
    main()
```

#### Extract Informations from perl scripts:

- extract prel scripts informations with perl PPI:
ex: `perl extract_from_perl.pl bruteforce_test.pl`

```perl
use strict;
use warnings;
use PPI;
use Data::Dumper;

sub extract_info_from_perl {
    my ($perl_script_path) = @_;
    my $document = PPI::Document->new($perl_script_path);

    # Extract function names
    my @function_names = map { $_->name } grep { $_->isa('PPI::Statement::Sub') } @{ $document->find('PPI::Statement::Sub') || [] };

    # Extract function arguments
    my @function_arguments;
    for my $sub (grep { $_->isa('PPI::Statement::Sub') } @{ $document->find('PPI::Statement::Sub') || [] }) {
        my $block = $sub->block;
        my $signature = $block->find('PPI::Statement::Variable');
        my @args;
        if (defined $signature && ref $signature eq 'ARRAY' && scalar @$signature > 0) {
            @args = map { $_->content } @{$signature->[0]->variables} if ref($signature->[0]->variables) eq 'ARRAY';
        }
        push @function_arguments, \@args;
    }

    # Extract invoked commands
    my @invoked_commands = map { $_->content } @{ $document->find('PPI::Token::QuoteLike::Command') || [] };

    # Extract script arguments
    my @script_arguments = map { $_->content } @{ $document->find('PPI::Token::ArrayIndex') || [] };

    return {
        function_names => \@function_names,
        function_arguments => \@function_arguments,
        invoked_commands => \@invoked_commands,
        script_arguments => \@script_arguments,
    };
}

if (@ARGV != 1) {
    print "Usage: $0 path_to_perl_script\n";
    exit 1;
}
```
#### Extract Informations from vbs scripts:

#### Extract Informations from batch scripts:



### Others

#### Get loggedin user

`(Get-ItemProperty "REGISTRY::HKEY_USERS\S-1-5-21-*\Volatile Environment").UserName`

#### Get RecycleBins content
`Get-ChildItem -Path "$env:HOMEDRIVE\$Recycle.Bin" -Force -Recurse`
