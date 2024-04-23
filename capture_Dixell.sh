#!/bin/bash

# Connect to database de run sql command
PSQL="psql -X --username=monitoruser --dbname=monitor --no-align --tuples-only -c"

# Some constants
# IP address for Dixell XWeb300D
IP='192.168.0.15'
# Time in seconds, how long we captured packets using tshark command
CAPTURETIME=15
# Interface used for captures packages
INTERFACE=tun0

# Run in infinite loop
while true; do
  # Put current date as dd-mm-YYYY HH:MM:SS in $DATETIME, in sql insert can be used also now() for datetime
  DATETIME=$(date '+%d-%m-%Y %H:%M:%S')

  # sniffing data from arrived from $IP using tshark command
  tshark -V -i $INTERFACE -Y "ip.addr==$IP and http.response.line" -F k12text -a duration:$CAPTURETIME | while read -r; do
    # Find line what start with '    2' or [3456789] and the trim spaces and delete chars '\n'
    grep '^    [23456789]' | tr -d ' ' | sed 's/[\]n//g'
  done | while IFS="|" read -r VAL_1 VAL_2 VAL_3 VAL_4 VAL_5 VAL_6 VAL_7 VAL_8 VAL_9 VAL_10 VAL_11 VAL_12 VAL_13 VAL_14 VAL_15 VAL_16 VAL_17 VAL_18 VAL_19; do
    # First values is address for controller connected at XWeb300D RS485 serial line
    ADDRESS=$VAL_1
    # At address 5, 6, 7 and 8 I have XR60CX controller connected at XWeb300D using RS485 line and I prepare variable for this tables (cc - frost and refrigerator chambers)
    if [ "$ADDRESS" = 5 ] || [ "$ADDRESS" = 6 ] || [ "$ADDRESS" = 7 ] || [ "$ADDRESS" = 8 ]; then
      # Replace value 0 with FALSE and value 1 with TRUE for better debug and to be sure not using value where is not necessary
      case $VAL_2 in [1]) CODE_1=TRUE ;; [0]) CODE_1=FALSE ;; esac
      case $VAL_3 in [1]) CODE_2=TRUE ;; [0]) CODE_2=FALSE ;; esac
      # Define variables with numbers
      PROBE_1=$VAL_4
      PROBE_2=$VAL_5
      PROBE_3=$VAL_6
      PROBE_R=$VAL_7
      SETPOINT_R=$VAL_8
      SETPOINT=$VAL_9
      # Replace value 0 with FALSE and value 1 with TRUE for better debug and to be sure not using value where is not necessary
      case $VAL_10 in [1]) FAN_OUT=TRUE ;; [0]) FAN_OUT=FALSE ;; esac
      case $VAL_11 in [1]) COMPRESSOR_OUT=TRUE ;; [0]) COMPRESSOR_OUT=FALSE ;; esac
      case $VAL_12 in [1]) GDI=TRUE ;; [0]) GDI=FALSE ;; esac
      case $VAL_13 in [1]) ON_STATUS=TRUE ;; [0]) ON_STATUS=FALSE ;; esac
      case $VAL_14 in [1]) DEFROST_STATUS=TRUE ;; [0]) DEFROST_STATUS=FALSE ;; esac
      case $VAL_15 in [1]) CODE_8=TRUE ;; [0]) CODE_8=FALSE ;; esac
      case $VAL_16 in [1]) CODE_9=TRUE ;; [0]) CODE_9=FALSE ;; esac
      # Define variables with string (this string it's for error codes)
      CODE_10=$VAL_17
      # Run sql insert command
      INSERT_CC_RESULT=$($PSQL "INSERT INTO cc$ADDRESS(datetime,address,code_1,code_2,probe_1,probe_2,probe_3,probe_r,setpoint_r,setpoint,fan_out,compressor_out,gdi,on_status,defrost_status,code_8,code_9,code_10) VALUES('$DATETIME','$ADDRESS','$CODE_1','$CODE_2','$PROBE_1','$PROBE_2','$PROBE_3','$PROBE_R','$SETPOINT_R','$SETPOINT','$FAN_OUT','$COMPRESSOR_OUT','$GDI','$ON_STATUS','$DEFROST_STATUS','$CODE_8','$CODE_9','$CODE_10')")
      # Print message 'INSERT 0 1' for success insert. Later I used result variables for an if
      echo "$INSERT_CC_RESULT"
    fi
    # At address 2, 3, 4 and 9 I have XH260L controller connected at XWeb300D using RS485 line and I prepare variable for this tables (cr - refrigerators chambers)
    if [ "$ADDRESS" = 2 ] || [ "$ADDRESS" = 3 ] || [ "$ADDRESS" = 4 ] || [ "$ADDRESS" = 9 ]; then
      # Replace value 0 with FALSE and value 1 with TRUE for better debug and to be sure not using value where is not necessary
      case $VAL_2 in [1]) CODE_1=TRUE ;; [0]) CODE_1=FALSE ;; esac
      case $VAL_3 in [1]) CODE_2=TRUE ;; [0]) CODE_2=FALSE ;; esac
      # Define variables with numbers
      PROBE_1=$VAL_4
      PROBE_2=$VAL_5
      PROBE_3=$VAL_6
      TEMP_SET=$VAL_7
      HUMID_SET=$VAL_8
      # Replace value 0 with FALSE and value 1 with TRUE for better debug and to be sure not using value where is not necessary
      case $VAL_9 in [1]) COMPRESSOR_OUT=TRUE ;; [0]) COMPRESSOR_OUT=FALSE ;; esac
      case $VAL_10 in [1]) HEATER_OUT=TRUE ;; [0]) HEATER_OUT=FALSE ;; esac
      case $VAL_11 in [1]) FAN_OUT=TRUE ;; [0]) FAN_OUT=FALSE ;; esac
      case $VAL_12 in [1]) HUMIDIFIER_OUT=TRUE ;; [0]) HUMIDIFIER_OUT=FALSE ;; esac
      case $VAL_13 in [1]) DEFROST_OUT=TRUE ;; [0]) DEFROST_OUT=FALSE ;; esac
      case $VAL_14 in [1]) LIGHT_OUT=TRUE ;; [0]) LIGHT_OUT=FALSE ;; esac
      case $VAL_15 in [1]) GDI=TRUE ;; [0]) GDI=FALSE ;; esac
      case $VAL_16 in [1]) ON_STATUS=TRUE ;; [0]) ON_STATUS=FALSE ;; esac
      case $VAL_17 in [1]) DEFROST_STATUS=TRUE ;; [0]) DEFROST_STATUS=FALSE ;; esac
      case $VAL_18 in [1]) KEYBOARD_STATUS=TRUE ;; [0]) KEYBOARD_STATUS=FALSE ;; esac
      # Define variables with string (this string it's for error codes)
      CODE_13=$VAL_19
      # Run sql insert command
      INSERT_CR_RESULT=$($PSQL "INSERT INTO cr$ADDRESS(datetime,address,code_1,code_2,probe_1,probe_2,probe_3,temp_set,humid_set,compressor_out,heater_out,fan_out,humidifier_out,defrost_out,light_out,gdi,on_status,defrost_status,keyboard_status,code_13) VALUES('$DATETIME','$ADDRESS','$CODE_1','$CODE_2','$PROBE_1','$PROBE_2','$PROBE_3','$TEMP_SET','$HUMID_SET','$COMPRESSOR_OUT','$HEATER_OUT','$FAN_OUT','$HUMIDIFIER_OUT','$DEFROST_OUT','$LIGHT_OUT','$GDI','$ON_STATUS','$DEFROST_STATUS','$KEYBOARD_STATUS','$CODE_13')")
      # Print message 'INSERT 0 1' for success insert. Later I used result variables for an if
      echo "$INSERT_CR_RESULT"
    fi
  done
done
