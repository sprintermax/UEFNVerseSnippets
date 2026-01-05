#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                           sha1_high                           |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |         sha1_high             |  ver  |      sha1_mid         |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |var|                       sha1_low                            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                           sha1_low                            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# sha1_high:    The first 48 bits of the layout are filled with the most significant, leftmost 48 bits from the computed SHA-1 value. Occupies bits 0 through 47 (octets 0-5).
# ver:          The 4-bit version field as defined by Section 4.2, set to 0b0101 (5). Occupies bits 48 through 51 of octet 6.
# sha1_mid:     12 more bits of the layout consisting of the least significant, rightmost 12 bits of 16 bits immediately following sha1_high from the computed SHA-1 value. Occupies bits 52 through 63 (octets 6-7).
# var:          The 2-bit variant field as defined by Section 4.1, set to 0b10. Occupies bits 64 and 65 of octet 8.
# sha1_low:     The final 62 bits of the layout immediately following the var field to be filled by skipping the two most significant, leftmost bits of the remaining SHA-1 hash and then using the next 62 most significant, leftmost bits. Any leftover SHA-1 bits are discarded and unused. Occupies bits 66 through 127 (octets 8-15).

