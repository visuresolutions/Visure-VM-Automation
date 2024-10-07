# File: install-postgresql.ps1

# Update and install Chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

# Install PostgreSQL 16
choco install postgresql --version=16.0 -y

# Add PostgreSQL to path (assumes default installation path)
$env:Path += ";C:\Program Files\PostgreSQL\16\bin"

# Start PostgreSQL service
Start-Service -Name "postgresql-x64-16"

# Create Database and Tablespaces
$psqlPath = "C:\Program Files\PostgreSQL\16\bin\psql.exe"
& $psqlPath -U postgres -c "CREATE DATABASE VisureDB WITH ENCODING 'WIN1252';"
& $psqlPath -U postgres -c "CREATE TABLESPACE VisureDB_DATA OWNER postgres LOCATION 'C:\path_to_data';"
& $psqlPath -U postgres -c "CREATE TABLESPACE VisureDB_IDX OWNER postgres LOCATION 'C:\path_to_idx';"
& $psqlPath -U postgres -c "CREATE SCHEMA VisureDB_Schema AUTHORIZATION postgres;"