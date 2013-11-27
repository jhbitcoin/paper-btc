#!/bin/bash

#
# Script to generate offline Bitcoin addresses 
# 
# Requires libbitcoin and sx
# https://github.com/spesmilo/libbitcoin/
# https://github.com/spesmilo/sx
#
# Console dialogs:
# http://invisible-island.net/dialog/
#
# Qrcode generation: 
# http://fukuchi.org/works/qrencode/


# Generate a new seed
new_seed(){
	m_seed=$(sx "newseed")
}

# Convert seed to 12 words
display_mnemonic(){
	mnemonic=$(echo $m_seed | sx "mnemonic")
	dialog --backtitle "Console Paper Wallet: Mnemonic Seed" --title "Electrum compatible 12-word mnemonic" --msgbox "\n$mnemonic" 9 50
}

# Convert 12 words to seed
mnemonic_to_seed(){
	cmd=(dialog --backtitle "Console Paper Wallet: Mnemonic Seed Entry"  --title "Electrum compatible 12-word mnemonic" --inputbox "Enter 12-word mnemonic (separated by spaces):" 8 75)

	while :
	do
		words=$("${cmd[@]}" 2>&1 >/dev/tty)	
		word_count=$(echo $words | wc -w)

		if [ $word_count -eq 0 ]; then
			break 2
		fi

		if [ $word_count -eq 12 ]; then
			# Verify mnemonic
			tmp_seed=$(echo $words | sx "mnemonic" | tr -d '\n')
			mnemonic=$(echo $tmp_seed | sx "mnemonic")	
			if [ "$words" == "$mnemonic" ]; then
				m_seed=$tmp_seed
				break 2
			else
				dialog --backtitle "Console Paper Wallet: Error" --title "mnemonic error" --msgbox "Invalid mnemonic. Try again." 9 50
			fi	
		else
			dialog --backtitle "Console Paper Wallet: Error" --title "mnemonic error" --msgbox "Mnemonic must be 12 words separated by spaces." 9 50
		fi
		
	done
}

# Display Public Address
pub_addr(){
	re='^[0-9]+$'
	cmd=(dialog --backtitle "Console Paper Wallet: Public Address Select" --keep-tite --title "Address Index" --inputbox "Which public address number?" 10 36)
	while :
	do
		index=$("${cmd[@]}" 2>&1 >/dev/tty)	
		if  [[ $index =~ $re ]]; then
			pub_key=$(echo $m_seed | sx "genaddr" $index)
			qr_code=$(qrencode -s 10 -m 1 -t ASCII "$pub_key")		
			qr_unicode=${qr_code//"#"/$unicode_box_char}
			dialog --backtitle "Console Paper Wallet: Public Address" --no-collapse --keep-tite --title "Address[$index]: $pub_key" --msgbox "$qr_unicode" 36 66
		  	break;
		else break;
		fi
	done
}

# Display Private Key
priv_key(){
	re='^[0-9]+$'
	cmd=(dialog --backtitle "Console Paper Wallet: Private Key Select" --keep-tite --title "Key Index" --inputbox "Which private key number?" 10 36)
	while :
	do
		index=$("${cmd[@]}" 2>&1 >/dev/tty)	
		if  [[ $index =~ $re ]]; then
			priv_key=$(echo $m_seed | sx "genpriv" $index)
			qr_code=$(qrencode -s 10 -m 1 -t ASCII "$priv_key")		
			qr_unicode=${qr_code//"#"/$unicode_box_char}
			dialog --backtitle "Console Paper Wallet: Private Key" --no-collapse --keep-tite --title "Key[$index]: $priv_key" --msgbox "$qr_unicode" 36 66
		  	break;
		else break;
		fi
	done
}

# Main Menu
main_menu(){

	while :
	do
		cmd=(dialog --backtitle "Console Paper Wallet: Main Menu" --keep-tite --no-cancel --menu "Current Seed: $m_seed" 14 55 22)

		options=(1 "Show mnemonic"
				 2 "Show public address"
				 3 "Show private key"
				 4 "Create new random seed"
				 5 "Create seed from mnemonic"			 
				 6 "Quit")

		choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

		for choice in $choices
		do
			case $choice in
				1)    
					display_mnemonic
					break
				    ;;
				2)
					pub_addr
					break
				    ;;
				3)
				    priv_key
					break
				    ;;
				4)
				    new_seed
					break
				    ;;
				5)
				    mnemonic_to_seed
					break
				    ;;
				6)
				    (clear)
				    break 2
					;;
			esac
		done
	done
}


unicode_box_char=$(echo -e "\xE2\x96\x88")
new_seed
main_menu


