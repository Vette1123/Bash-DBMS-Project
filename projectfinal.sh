#!/bin/bash
  mkdir DBMS 2>> .error.log
  clear
  echo "Welcome to our Database system!"
function mainMenu {
  echo -e "\n---------Main Menu-------------\n"
  echo "| 1. Create a Database          |"
  echo "| 2. List Databases             |"
  echo "| 3. Connect to a Database      |"
  echo "| 4. Drop Database              |"
  echo "| 5. Exit                       |"
  echo "-------------------------------"
  echo -e "Please Enter Your Choice: \c"
  read choice
  case $choice in
    1)  createDB ;;
    2)  ls DBMS ; mainMenu;;
    3)  ConnectToDB ;;
    4)  dropDB ;;
    5) exit ;;
    *) echo "Wrong Choice, Please choose from 1 to 5 only." ; mainMenu;;
  esac
}
function createDB {
  echo -e "Please enter your database name: \c"
  read DBName
  if [[ $DBName =~ ^[a-zA-Z]+$ ]]; then  # =~ match string to its left to the extended regular expression to its right
     mkdir ./DBMS/$DBName  # $ in regular expression means from beginning to end
          if [[ $? == 0 ]] # match everything from stand to end of the string, its a regex
          then
          echo "Database $DBName was Created Successfully"
          else
          echo "Error Creating $DBName Database"
          fi
  else
         echo "Pattern Doesn't Match, Please choose a wise name."
  fi
  mainMenu
}

function ConnectToDB {
     while [[ true ]] 
      do
      echo -e "Enter Database Name: \c" #\c exscape character to signal continue, no automatic line break
      read DBName
      if [ -z $DBName ]; then 
        echo "Can't be empty, please enter smth."
        elif ! [[ $DBName =~ ^[a-zA-Z]+$ ]]; then
        echo "Can't be numbers, Please enter text only."
      else break;
      fi
      done
  cd ./DBMS/$DBName 2>> ./.error.log
  if [[ $? == 0 ]]; then
    echo "Database $DBName was Successfully Selected."
    tablesMenu
  else
    echo "Database $DBName does not exist."
    mainMenu
  fi
}

function dropDB {
  echo -e "Enter Database Name: \c"
  read DBName
  rm -r ./DBMS/$DBName 2>> ./.error.log
  if [[ $? == 0 ]]; then
    echo "Database dropped successfully."
  else
    echo "Database $DBName was not found."
  fi
  mainMenu
}

function tablesMenu {
  echo -e "\n--------Tables Menu------------"
  echo "| 1. Create Table               |"
  echo "| 2. List Tables                |"
  echo "| 3. Drop Table                 |"
  echo "| 4. Insert Into Table          |"
  echo "| 5. Select From Table          |"
  echo "| 6. Delete From Table          |"
  echo "| 7. Update Table               |"
  echo "| 8. Back To Main Menu          |"
  echo "| 9. Exit                       |"
  echo "-------------------------------"
  echo -e "Please Enter Your Choice: \c"
  read choice
  case $choice in
    1)  createTable ;;
    2)  ls ; tablesMenu ;;
    3)  dropTable;;
    4)  insertIntoTable;;
    5)  clear; selectMenu ;;
    6)  deleteFromTable;;
    7)  updateTable;;
    8) clear; cd ../.. 2>> ./.error.log; mainMenu ;;
    9) exit ;;
    *) echo " Wrong Choice, Please select from 1 to 9 only." ; tablesMenu;
  esac
}

function createTable {
  echo -e "Please enter table name: \c"
  read tableName
  if ! [[ $tableName =~ ^[a-zA-Z]+$ ]]; then
      echo "$tableName is not a string value, please try again!"
      tablesMenu
  elif [ -f $tableName ]; then
      echo "table already exits,please choose another name."
      tablesMenu
  fi

   while [[ true ]] 
    do
      echo -e "Please enter number of columns: \c"
      read colsNum
      if ! [[ $colsNum =~ ^[0-9]+$ ]]; then
      echo "Please enter only numbers."
      else break;
      fi
   done

  counter=1
  seperator="|"
  rowSeperator="\n"
  primaryKey=""
  metaData="Field"$seperator"Type"$seperator"Key"
  temp=""

  while [ $counter -le $colsNum ]
   do
        while [[ true ]] 
        do
        echo -e "Name of Column No.$counter: \c"
        read colName
        if [[ "$temp" == *"$colName"* ]]
        then
        echo "Column name $colName was entered before."
        elif ! [[ $colName =~ ^[a-zA-Z]+$ ]]; then 
        echo "Can't be empty or numbers."
        else
        break;
        fi
        done
    echo -e "Type of $colName Column: "
    select var in "int" "str"
    do
      case $var in
        int ) colType="int";break;;
        str ) colType="str";break;;
        * ) echo "Wrong Choice" ;;
      esac
    done
    if [[ $primaryKey == "" ]]; then
      echo -e "Do you want to assign primary key?"
      select var in "yes" "no"
      do
        case $var in
          yes ) primaryKey="PK";
          metaData+=$rowSeperator$colName$seperator$colType$seperator$primaryKey;
          break;;
          no )
          metaData+=$rowSeperator$colName$seperator$colType$seperator;
          break;;
          * ) echo "Wrong Choice" ;;
        esac
      done
    else
      metaData+=$rowSeperator$colName$seperator$colType$seperator
    fi
    
    if [[ $counter == $colsNum ]]; then ## last column
      temp=$temp$colName
    else
      temp=$temp$colName$seperator
    fi
    ((counter++))
  done
  touch .$tableName                 #create metadata file
  echo -e $metaData  >> .$tableName #metadata output re-direction
  touch $tableName
  echo -e $temp >> $tableName       #data file
  if [[ $? == 0 ]]
  then
    echo "Table $colName was successfully created."
    tablesMenu
  else
    echo "Error Creating $tableName Table."
    tablesMenu
  fi
}

function dropTable {
  echo -e "Please enter a table name to drop: \c"
  read dropTable
  rm $dropTable .$dropTable 2>> ./.error.log
  if [[ $? == 0 ]]
  then
    echo "Table dropped successfully."
  else
    echo "Error Dropping $dropTable Table"
  fi
  tablesMenu
}

function insertIntoTable {
  echo -e "Please enter table name: \c"
  read tableName
  if ! [ -f $tableName ]; then
    echo "Table $tableName doesn't exist, please choose another table."
    tablesMenu
  fi
  colsNum=`awk 'END{print NR}' .$tableName`
  seperator="|"
  rowSeperator="\n"
  for (( i = 2; i <= $colsNum; i++ )); do
    colName=`awk "-F|" '{if(NR=='$i') print $1}' .$tableName`  #get column name
    colType=`awk "-F|" '{if(NR=='$i') print $2}' .$tableName`  #get column type
    colKey=`awk "-F|" '{if(NR=='$i') print $3}' .$tableName`   #get column key

    # Validate Input
     while [[ true ]]
     do
        echo -e "$colName ($colType) = \c"
        read data
        if [[ $colType == "int" ]]; then        ##int check
             if ! [[ $data =~ ^[0-9]*$ ]]; then
                echo -e "invalid DataType!"
                continue
             fi
         fi

         if [[ $colType == "str" ]]; then       ##str check
             if ! [[ $data =~ ^[a-zA-Z]*$ ]]; then
              echo -e "invalid DataType!"
              continue;
             fi
        fi

         if [[ $colKey == "PK" ]]; then
             if [[ "$data" =~ [`awk "-F|" '{if(NR != 1) print $(('$i'-1))}' $tableName | grep $data 2>> ./.error.log`] ]]; then
             echo -e "Repeated value for primary key, please enter a unique value."
             continue;
             fi
         fi

        if [[ $data == "" ]] && [[ $colKey == "PK" ]]; then
             echo "Please enter some value, Primary key can't be empty."
             continue;
         fi
             break;
    done
 ##############################
    #Set row
    if [[ $i == $colsNum ]]; then
      row=$row$data$rowSeperator
    else
      row=$row$data$seperator
    fi
  done
  echo -e $row"\c" >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Data Inserted Successfully"
  else
    echo "Error Inserting Data into Table $tableName"
  fi
  row=""
  tablesMenu
}

function updateTable {
  echo -e "Enter Table Name: \c"
  read tableName
  echo -e "Please enter conditionl column name: \c"
  read field
  fieldID=$(awk "-F|" '{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tableName) #print field number
  if [[ $fieldID == "" ]]
  then
    echo "Field doesn't exist"
    tablesMenu
  else
    echo -e "Enter Conditionl Value: \c"
    read value
    fieldValue=$(awk "-F|" '{if ($'$fieldID'=="'$value'") print $'$fieldID'}' $tableName 2>>./.error.log)
    if [[ $fieldValue == "" ]]
    then
      echo "Value doesn't exist"
      tablesMenu
    else
      echo -e "Enter FIELD name to set: \c"
      read setField
      setFieldID=$(awk "-F|" '{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$setField'") print i}}}' $tableName)
      if [[ $setFieldID == "" ]]
      then
        echo "Not Found"
        tablesMenu
      else
        echo -e "Enter new Value to set: \c"
        read newValue
        oldValueNR=($(awk "-F|" '{if ($'$fieldID' == "'$value'") print NR}' $tableName 2>>./.error.log))
        oldValue=$(awk "-F|" '{if(NR=='$oldValueNR'){for(i=1;i<=NF;i++){if(i=='$setFieldID') print $i}}}' $tableName 2>>./.error.log)
        for i in "${oldValueNR[@]}"
        do
        sed -i ''$i's/'$oldValue'/'$newValue'/g' $tableName 2>>./.error.log
        echo "Row updated Successfully"
        done
        tablesMenu
      fi
    fi
  fi
}

function deleteFromTable {
  echo -e "Enter Table Name: \c"
  read tableName
  echo -e "Please enter conditionl column name: \c"
  read field
  fieldID=$(awk -F '|' '{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tableName)
  if [[ $fieldID == "" ]]
  then
    echo "Not Found"
    tablesMenu
  else
    echo -e "Enter Conditionl Value: \c"
    read value
    result=$(awk -F '|' '{if ($'$fieldID'=="'$value'") print $'$fieldID'}' $tableName 2>>./.error.log)
    if [[ $result == "" ]]
    then
      echo "Value Not Found"
      tablesMenu
    else
    # In case there are more records satisfy the condition
    # We will delete all those records
        temp=""
        sep="d;"
      valueNR=($(awk -F '|' '{if ($'$fieldID'=="'$value'") print NR}' $tableName 2>>./.error.log))
      for i in "${valueNR[@]}"
      do
        temp=$temp$i$sep   ##1d;2d;3d;$d
      echo "Row Deleted Successfully"
      done
      sed -i $temp $tableName 2>>./.error.log
      tablesMenu
    fi
  fi
}

function selectMenu {
  echo -e "\n\n---------------Select Menu--------------------"
  echo "| 1. Select Columns of a table                  |"
  echo "| 2. Select Specific Column from a table        |"
  echo "| 3. Select From Table under condition          |"
  echo "| 4. Back To Tables Menu                        |"
  echo "| 5. Back To Main Menu                          |"
  echo "| 6. Exit                                       |"
  echo "----------------------------------------------"
  echo -e "Enter Choice: \c"
  read choice
  case $choice in
    1) selectAllColumns ;;
    2) selectSpecficColumn ;;
    3) clear; selectUnderCondition ;;
    4) clear; tablesMenu ;;
    5) clear; cd ../.. 2>>./.error.log; mainMenu ;;
    6) exit ;;
    *) echo " Wrong Choice " ; selectMenu;
  esac
}

function selectAllColumns {
  echo -e "Enter Table Name: \c"
  read tableName
  column -t -s '|' $tableName 2>> ./.error.log ## command to display as table, -s delimiter -t as table
  if [[ $? != 0 ]]
  then
    echo "Error Displaying Table $tableName"
  fi
  selectMenu
}

function selectSpecficColumn {               #based on col number
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter Column Number: \c"
  read colNum
  awk -F '|' '{print $'$colNum'}' $tName
  selectMenu
}

function selectUnderCondition {
  echo -e "\n\n--------Select Under Condition Menu-----------"
  echo "| 1. Select All Columns Matching Condition(Row)   |"
  echo "| 2. Back To Selection Menu                       |"
  echo "| 3. Back To Main Menu                            |"
  echo "| 4. Exit                                         |"
  echo "---------------------------------------------"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1) clear; allCUnderCondition ;;
    2) clear; selectMenu ;;
    3) clear; cd ../.. 2>>./.error.log; mainMenu ;;
    4) exit ;;
    *) echo " Wrong Choice " ; selectUnderCondition;
  esac
}

function allCUnderCondition {
  echo -e "Select all columns from TABLE Where Field-Operator-Value \n"
  echo -e "Enter Table Name: \c"
  read tableName
  echo -e "Enter required field name: \c"
  read field
  fieldID=$(awk -F '|' '{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tableName)
  if [[ $fieldID == "" ]]
  then
    echo "Field name doesn't exist."
    selectUnderCondition
  else
    echo -e "\nSupported Operators: [==, !=, >, <, >=, <=] \nSelect OPERATOR: \c"
    read operator
    if [[ $operator == "==" ]] || [[ $operator == "!=" ]] || [[ $operator == ">" ]] || [[ $operator == "<" ]] || [[ $operator == ">=" ]] || [[ $operator == "<=" ]]
    then
      echo -e "\nEnter required value: \c"
      read value
      ## if value is string please enter it between " ",else just enter it.
      result=$(awk -F '|' '{if ($'$fieldID$operator$value') print $0}' $tableName 2>>./.error.log |  column -t -s '|')
      if [[ $result == "" ]]
      then
        echo "Value doesn't exist."
        selectUnderCondition
      else
        awk "-F|" '{if ($'$fieldID$operator$value') print $0}' $tableName 2>>./.error.log |  column -t -s '|'
        selectUnderCondition
      fi
    else
      echo "Unsupported Operator\n, please select from above"
      selectUnderCondition
    fi
  fi
}
mainMenu