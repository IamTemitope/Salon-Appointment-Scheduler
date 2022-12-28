#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Welcome to My Salon ~~~\n"

echo -e "How can we be of Service?\n"


MAIN_MENU() {
  
  if [[ $1 ]]
    then 
      echo -e "\n$1"
  fi
  
  
  SERVICE_RENDERED=$($PSQL "select service_id, name from services order by service_id")
    
  if [[ -z $SERVICE_RENDERED ]]
   then 
      echo -e "\nSorry we don't have any available service right now"
   else 
        echo "$SERVICE_RENDERED" | while read SERVICE_ID BAR NAME
    do
        echo "$SERVICE_ID) $NAME"
    done
  fi

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]  
    then
      MAIN_MENU "Invalid Option"
    else
    SERVICE_AVAILABLE=$($PSQL "select service_id from services where service_id = '$SERVICE_ID_SELECTED'")
    SERVICE_AVAILABLE2=$($PSQL "select name from services where service_id = '$SERVICE_ID_SELECTED'")
    if [[ -z $SERVICE_AVAILABLE ]] 
     then
        MAIN_MENU "I could not find that service. What would you like today?"
     else
     echo -e "\nWhat's your phone number?"
     read CUSTOMER_PHONE
     CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
       if [[ -z $CUSTOMER_NAME ]] 
         then 
           echo -e "\nI don't have a record for that phone number, what's your name?"
           read CUSTOMER_NAME
           INSERT_CUSTOMER_NAME=$($PSQL "insert into customers(phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi
      
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'") 
      if [[ $SERVICE_TIME ]]
        then
          CUSTOMER_SERVICE_TIME=$($PSQL "insert into appointments(customer_id, service_id, time) values ('$CUSTOMER_ID', '$SERVICE_AVAILABLE', '$SERVICE_TIME')")
          if [[ $CUSTOMER_SERVICE_TIME ]]
            then
              echo "I have put you down for a $SERVICE_AVAILABLE2 at $SERVICE_TIME, $CUSTOMER_NAME."
          fi
      fi       
    fi 
  fi

}

MAIN_MENU
