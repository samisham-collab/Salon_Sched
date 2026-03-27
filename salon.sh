#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
SALON="SAM'S SUPER SALON"
echo -e "\n~~~~~ $SALON ~~~~~\n"
echo -e "Welcome to $SALON, how can I help you today?\n"

MAIN_PAGE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #Services
  LIST_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$LIST_SERVICES" | while read DIRTY_SERVICE_ID BAR SERVICE
  do
    CLEAN_SERVICE_ID=$(echo $DIRTY_SERVICE_ID | sed 's/ //g')
    echo "$CLEAN_SERVICE_ID) $SERVICE"
  done

  read SERVICE_INPUT
  case $SERVICE_INPUT in
    [1-5]) FORM ;;
        *) MAIN_PAGE "I could not find that service. What would you like today?" ;;
  esac
}


FORM() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_PHONE_FORMATTED=$(echo $CUSTOMER_PHONE | sed 's/[^0-9]*//g')
  NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $NAME | sed 's/ //g')
  if [[ -z $NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" > /dev/null
  fi

  DIRTY_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_INPUT")

  CLEAN_SERVICE_NAME=$(echo $DIRTY_SERVICE_NAME | sed 's/ //g')

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your $CLEAN_SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  SAVED_TO_TABLE_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_INPUT, '$SERVICE_TIME')")
  if [[ $SAVED_TO_TABLE_APPOINTMENTS == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $CLEAN_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
MAIN_PAGE