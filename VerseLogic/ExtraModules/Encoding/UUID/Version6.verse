#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                           time_high                           |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |           time_mid            |  ver  |       time_low        |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |var|         clock_seq         |             node              |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                              node                             |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# time_high:    The most significant 32 bits of the 60-bit starting timestamp. Occupies bits 0 through 31 (octets 0-3).
# time_mid:     The middle 16 bits of the 60-bit starting timestamp. Occupies bits 32 through 47 (octets 4-5).
# ver:          The 4-bit version field as defined by Section 4.2, set to 0b0110 (6). Occupies bits 48 through 51 of octet 6.
# time_low:     12 bits that will contain the least significant 12 bits from the 60-bit starting timestamp. Occupies bits 52 through 63 (octets 6-7).
# var:          The 2-bit variant field as defined by Section 4.1, set to 0b10. Occupies bits 64 and 65 of octet 8.
# clock_seq:    The 14 bits containing the clock sequence. Occupies bits 66 through 79 (octets 8-9).
# node:         48-bit spatially unique identifier. Occupies bits 80 through 127 (octets 10-15).

