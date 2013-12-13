paper-btc
=========
paper-btc is a Live Linux ISO (bootable from USB Stick or CD-Rom) which provides a simple, console interface for generating secure Bitcoin paper wallets in an off-line environment. This is a minimalist Debian distribution with all networking code removed. The ISO can be downloaded from: (bitcoin-tools.iso 338.0 MB md5sum 5d6d3f663a459820268803f63f55bea9) https://mega.co.nz/#!VMtizKiS!fb94WEVx3eXkYvfAiWGUUmCzRfMI04dBwv16rMO9LtM

Instructions for building the ISO from scratch using Debian sources are in Instructions.rst. Scripts to automate the distribtion build process are coming soon.


bitcoin-paper-wallet.pdf
------------------------
Download and print a copy of the pdf prior to generating an off-line wallet. Use this paper to record your keys and Electrum compatible random seed. CAUTION: You must record the 12-word mnemonic or seed value in order to recover a private key using this software. If either of these are lost, so are your bitcoins. 

 
paper-wallet.sh
---------------
The Live Linux ISO automatically runs a bash script utilizing libbitcoin and sx to generate paper wallets. When the script is launched, a new 128-bit random seed is generated. You can create a different random seed at any time. Private keys and public addresses are determined by the seed value. 

Each seed value has an associated 12 word, Electrum compatible mnemonic. The Electrum Bitcoin client uses a 128-bits random seed to generate its private keys. Show the mnemonic and record or memorize it. Do not loose or share this information - it is the password to spending your bitcoins.

Screen Shots
------------
http://imgur.com/a/J7rES#0

### Donate
If you find this project useful, consider contributing by making improvements to the software or donating to: 15w4xbWectsupZ8mQjbYiHt7GiFhm6MMQh
