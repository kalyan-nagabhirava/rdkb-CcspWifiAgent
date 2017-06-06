#!/bin/sh
#This script is used to log parameters for each AP

source /etc/log_timestamp.sh

print_connected_client_info()
{
	AP=$(( $1 + 1 ))
	RADIO=$(( $1 % 2 ))
	sta1=`wifi_api wifi_getApAssociatedDeviceDiagnosticResult $1`

	WIFI_MAC_1_Total_count=`echo "$sta1" | grep Total_STA | cut -d':' -f2`
	if [ "$sta1" != "" ] && [ "$WIFI_MAC_1_Total_count" != "0" ] ; then
		mac1=`echo "$sta1" | grep cli_MACAddress | cut -d ' ' -f3`
		if [ "$mac1" == "" ] ; then
			mac1=`echo "$sta1" | grep cli_MACAddress | cut -d ' ' -f2`
		fi
		mac1=`echo "$mac1" | tr '\n' ','`
		echo_t "WIFI_MAC_$AP:$mac1"
		echo_t "WIFI_MAC_$AP""_TOTAL_COUNT:$WIFI_MAC_1_Total_count"
		rssi1=`echo "$sta1" | grep cli_RSSI | cut -d '=' -f 2 | tr -d ' ' | tr '\n' ','`
		echo_t "WIFI_RSSI_$AP:$rssi1"
		rxrate1=`echo "$sta1" | grep cli_LastDataDownlinkRate | cut -d '=' -f 2 | tr -d ' ' | tr '\n' ','`
		echo_t "WIFI_RXCLIENTS_$AP:$rxrate1"
		txrate1=`echo "$sta1" | grep cli_LastDataUplinkRate | cut -d '=' -f 2 | tr -d ' ' | tr '\n' ','`
		echo_t "WIFI_TXCLIENTS_$AP:$txrate1"
		channel=`wifi_api wifi_getRadioChannel $RADIO`
		ch=`echo "$channel" | grep channel`
		if [ "$ch" != "" ] ; then
			channel=`echo "$ch" | cut -d ' ' -f4`
		fi
		echo_t "WIFI_CHANNEL_$AP:$channel"
		channel_width_1=`echo "$sta1" | grep cli_OperatingChannelBandwidth | cut -d '=' -f 2 | tr -d ' ' | tr '\n' ','`
		echo_t "WIFI_CHANNEL_WIDTH_$AP:$channel_width_1"

		echo "$sta1" | grep cli_LastDataDownlinkRate | cut -d '=' -f 2 | tr -d ' ' > /tmp/rxx1
		echo "$sta1" | grep cli_LastDataUplinkRate | cut -d '=' -f 2 | tr -d ' ' > /tmp/txx1
		rxtxd1=`awk '{printf ("%s ", $0); getline < "/tmp/txx1"; print $0 }' /tmp/rxx1 | awk '{print ($1 - $2)}' |  tr '\n' ','`
		rm /tmp/rxx1 /tmp/txx1
		echo_t "WIFI_RXTXCLIENTDELTA_$AP:$rxtxd1"
	else
		echo_t "WIFI_MAC_$AP""_TOTAL_COUNT:0"
		channel=`wifi_api wifi_getRadioChannel $RADIO`
		ch=`echo "$channel" | grep channel`
		if [ "$ch" != "" ] ; then
			channel=`echo "$ch" | cut -d ' ' -f4`
		fi
		echo_t "WIFI_CHANNEL_$AP:$channel"
	fi

	if [ "$AP" == "1" ] || [ "$AP" == "2" ] ; then
		getmac_1=`psmcli get eRT.com.cisco.spvtg.ccsp.tr181pa.Device.WiFi.AccessPoint.$AP.MacFilterMode`
		echo_t "WIFI_ACL_$AP:$getmac_1"
		getmac_1=`echo "$getmac_1" | grep 0`
		#temporary workaround for ACL disable issue
		buf=`wifi_api wifi_getBandSteeringEnable  | grep "TRUE"`
		if [ "$buf" != "" ] && [ "$getmac_1" != "" ] ; then
			echo_t "Enabling BS to fix ACL inconsitency"
			dmcli eRT setv Device.WiFi.X_RDKCENTRAL-COM_BandSteering.Enable bool false
			dmcli eRT setv Device.WiFi.X_RDKCENTRAL-COM_BandSteering.Enable bool true
		fi
		acs_1=`dmcli eRT getv Device.WiFi.Radio.$AP.AutoChannelEnable | grep true`
		if [ "$acs_1" != "" ]; then
			echo_t "WIFI_ACS_$AP:true"
		else
			echo_t "WIFI_ACS_$AP:false"
		fi
	fi
}

# Print connected client information for required interfaces (eg. ath0 , ath1 etc)

#ath0
print_connected_client_info 0

#ath1
print_connected_client_info 1

#ath2
print_connected_client_info 2

#ath3
print_connected_client_info 3

#ath6
print_connected_client_info 6

#ath7
print_connected_client_info 7

