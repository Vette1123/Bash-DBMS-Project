# Bash DBMS

A small command-line "database management system" written entirely in Bash. Databases live on disk as directories and tables as files, manipulated through a menu-driven CLI.

## Features

- Create / list / connect to / drop databases
- Create tables with column names, types and a primary key
- Insert, select, update and delete rows
- Input validation (table/column name patterns, type checks, PK uniqueness)
- Drops down into a per-database menu when you "connect"

## Tech

- Bash (POSIX-ish, uses `[[ ]]`, arrays and regex)

## Run it locally

```bash
git clone https://github.com/Vette1123/Bash-DBMS-Project.git
cd Bash-DBMS-Project
chmod +x projectfinal.sh
./projectfinal.sh
```

State is stored under a `DBMS/` folder created next to the script. Each database is a subdirectory; each table is a plain file inside it.

## Notes

This was an academic exercise to model a tiny relational system without any actual database engine. It was useful for learning Bash control flow, file I/O and regex validation.
