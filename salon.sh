#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Display available services
display_services() {
  echo "Available Services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Get service ID with error handling
get_service_id() {
  read -p "Enter service ID: " SERVICE_ID_SELECTED

  # Check if service ID is valid
  VALID_SERVICE_ID=$($PSQL "SELECT EXISTS(SELECT 1 FROM services WHERE service_id = $SERVICE_ID_SELECTED)")
  if [[ $VALID_SERVICE_ID == 'f' ]]; then
    echo "I could not find that service. What would you like today?"
    display_services
    get_service_id
  fi
}

# Get customer information
get_customer_info() {
  read -p "What's your phone number? " CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # If customer doesn't exist, get their name and add them to the customers table
  if [[ -z $CUSTOMER_NAME ]]; then
    read -p "I don't have a record for that phone number, what's your name? " CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
  fi
}

# Get appointment time
get_appointment_time() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  read -p "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME? " SERVICE_TIME
}

# Main logic
display_services
get_service_id
get_customer_info
get_appointment_time

# Get customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."