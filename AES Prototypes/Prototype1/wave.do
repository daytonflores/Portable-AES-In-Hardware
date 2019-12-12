onerror {resume}
quietly virtual signal -install /aes/aesEncrypt/rounds/mixColumns { (concat_range (0 to 7) )( (context /aes/aesEncrypt/rounds/mixColumns )&{state[7] , state[6] , state[5] , state[4] , state[3] , state[2] , state[1] , state[0] } )} Byte0
quietly WaveActivateNextPane {} 0
add wave -noupdate /aes/rst
add wave -noupdate /aes/encOrDec
add wave -noupdate /aes/start
add wave -noupdate -radix binary /aes/keySize
add wave -noupdate -radix hexadecimal /aes/messageInE
add wave -noupdate -radix hexadecimal /aes/messageOutE
add wave -noupdate /aes/doneE
add wave -noupdate -radix hexadecimal /aes/messageInD
add wave -noupdate -radix hexadecimal /aes/messageOutD
add wave -noupdate /aes/doneD
add wave -noupdate -group Encrypt /aes/aesEncrypt/done
add wave -noupdate -group Encrypt -radix unsigned /aes/aesEncrypt/countRounds
add wave -noupdate -group Encrypt /aes/aesEncrypt/checkingDone
add wave -noupdate -group Encrypt /aes/aesEncrypt/roundsDone
add wave -noupdate -group Encrypt /aes/aesEncrypt/keyExpansion/enableKeyExpansion
add wave -noupdate -group Encrypt -radix unsigned /aes/aesEncrypt/keyExpansion/numRounds
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/keyExpansion/key
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/keyExpansion/keyExp
add wave -noupdate -group Encrypt /aes/aesEncrypt/keyExpansion/keyExpDone
add wave -noupdate -group Encrypt /aes/aesEncrypt/keyControl/enableKeyControl
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/keyControl/keyExp
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/keyControl/newKey
add wave -noupdate -group Encrypt /aes/aesEncrypt/keyControl/keyControlDone
add wave -noupdate -group Encrypt -radix unsigned /aes/aesEncrypt/keyControl/bottom
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/enableRounds
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/initialRound
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/finalRound
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/enableSubBytes
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/messageInSB
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/subBytesDone
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/messageOutSB
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/subBytes/state
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/subBytes/stateOut
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/enableShiftRows
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/messageInSR
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/shiftRowsDone
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/messageOutSR
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/enableMixColumns
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/messageInMC
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/mixColumnsDone
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/messageOutMC
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/enableAddRoundKey
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/messageInARK
add wave -noupdate -group Encrypt /aes/aesEncrypt/rounds/addRoundKeyDone
add wave -noupdate -group Encrypt -radix hexadecimal /aes/aesEncrypt/rounds/messageOutARK
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/done
add wave -noupdate -expand -group Decrypt -radix unsigned /aes/aesDecrypt/countRounds
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/checkingDone
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRoundsDone
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invKeyControl/enableInvKeyControl
add wave -noupdate -expand -group Decrypt -radix hexadecimal /aes/aesDecrypt/invKeyControl/keyExp
add wave -noupdate -expand -group Decrypt -radix hexadecimal /aes/aesDecrypt/invKeyControl/invNewKey
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invKeyControl/invKeyControlDone
add wave -noupdate -expand -group Decrypt -radix unsigned /aes/aesDecrypt/invKeyControl/bottom
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/enableInvRounds
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/initialRound
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/finalRound
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/enableInvShiftRows
add wave -noupdate -expand -group Decrypt -radix ascii /aes/aesDecrypt/invRounds/messageInISR
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/invShiftRowsDone
add wave -noupdate -expand -group Decrypt -radix ascii /aes/aesDecrypt/invRounds/messageOutISR
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/enableInvSubBytes
add wave -noupdate -expand -group Decrypt -radix ascii /aes/aesDecrypt/invRounds/messageInISB
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/invSubBytesDone
add wave -noupdate -expand -group Decrypt -radix ascii /aes/aesDecrypt/invRounds/messageOutISB
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/enableInvAddRoundKey
add wave -noupdate -expand -group Decrypt -radix ascii /aes/aesDecrypt/invRounds/messageInIARK
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/invAddRoundKeyDone
add wave -noupdate -expand -group Decrypt -radix ascii /aes/aesDecrypt/invRounds/messageOutIARK
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/enableInvMixColumns
add wave -noupdate -expand -group Decrypt -radix ascii /aes/aesDecrypt/invRounds/messageInIMC
add wave -noupdate -expand -group Decrypt /aes/aesDecrypt/invRounds/invMixColumnsDone
add wave -noupdate -expand -group Decrypt -radix ascii /aes/aesDecrypt/invRounds/messageOutIMC
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3295 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 304
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {3278 ps} {3818 ps}
