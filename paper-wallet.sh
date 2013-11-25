#!/bin/bash


# Generate a new seed
new_seed(){
	m_seed=$(sx "newseed")
}

# Convert seed to 12 words
display_mnemonic(){
	mnemonic=$(echo $m_seed | sx "mnemonic")
	dialog --backtitle "Console Paper Wallet: Mnemonic Seed" --title "Electrum Compatible 12 Word mnemonic" --msgbox "\n$mnemonic" 9 50
}

# Convert 12 words to seed
mnemonic_to_seed(){
	cmd=(dialog --backtitle "Console Paper Wallet: Mnemonic Seed Entry"  --title "Electrum 12-word mnemonic" --inputbox "Enter 12 word mnemonic" 8 75)

	while :
	do
		words=$("${cmd[@]}" 2>&1 >/dev/tty)	
		word_count=$(echo $words | wc -w)

		if [ $word_count -eq 0 ]; then
			break 2
		fi

		if [ $word_count -eq 12 ]; then
			tmp_seed=$(echo $words | sx "mnemonic" | tr -d '\n')
			mnemonic=$(echo $tmp_seed | sx "mnemonic")
			# Verify mnemonic		
			if [ "$words" == "$mnemonic" ]; then
				m_seed=$tmp_seed
				break 2
			else
				dialog --backtitle "Console Paper Wallet: Error" --title "mnemonic error" --msgbox "Invalid mnemonic. Try again." 9 50
			fi	
		else
			dialog --backtitle "Console Paper Wallet: Error" --title "mnemonic error" --msgbox "Mnemonic must be 12 words" 9 50
		fi
		
	done
}

# Display Public Keys
pub_key(){
	re='^[0-9]+$'
	cmd=(dialog --backtitle "Console Paper Wallet: Public Key Select" --keep-tite --title "Key Index" --inputbox "Which Public Key Number?" 10 30)
	while :
	do
		index=$("${cmd[@]}" 2>&1 >/dev/tty)	
		if  [[ $index =~ $re ]]; then
			pub_key=$(echo $m_seed | sx "genaddr" $index)
			qr_code=$(qrencode -s 10 -m 1 -t ASCII "$pub_key")		
			qr_unicode=${qr_code//"#"/$unicode_box_char}
			#echo $qr_unicode
			dialog --backtitle "Console Paper Wallet: Public Key" --no-collapse --keep-tite --title "Key[$index]: $pub_key" --msgbox "$qr_unicode" 36 66
		  	break;
		else break;
		fi
	done
}

# Display Private Key
priv_key(){
	re='^[0-9]+$'
	cmd=(dialog --backtitle "Console Paper Wallet: Private Key Select" --keep-tite --title "Key Index" --inputbox "Which Private Key Number?" 10 30)
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
		cmd=(dialog --backtitle "Console Paper Wallet: Main Menu" --keep-tite --no-cancel --menu "Current Seed: $m_seed" 18 70 22)

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
					pub_key
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

