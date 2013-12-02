paper-wallet.sh
===============

paper-wallet.sh is a simple bash script utilizing libbitcoin and sx to generate paper wallets. When the script is launched, a new 128-bit random seed is generated. You can create a different random seed at any time. Private keys and public addresses are determined by the seed value. 

Each seed value has an associated 12 word, electrum compatible mnemonic. The Electrum Bitcoin client uses a 128-bits random seed to generate its private keys. Show the mnemonic and record or memorize it. Do not loose or share this information - it is the password to spending your bitcoins.

