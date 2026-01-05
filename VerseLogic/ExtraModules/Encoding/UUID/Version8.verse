#  0                   1                   2                   3
#  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                           custom_a                            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |          custom_a             |  ver  |       custom_b        |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |var|                       custom_c                            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |                           custom_c                            |
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# custom_a:     The first 48 bits of the layout that can be filled as an implementation sees fit. Occupies bits 0 through 47 (octets 0-5).
# ver:          The 4-bit version field as defined by Section 4.2, set to 0b1000 (8). Occupies bits 48 through 51 of octet 6.
# custom_b:     12 more bits of the layout that can be filled as an implementation sees fit. Occupies bits 52 through 63 (octets 6-7).
# var:          The 2-bit variant field as defined by Section 4.1, set to 0b10. Occupies bits 64 and 65 of octet 8.
# custom_c:     The final 62 bits of the layout immediately following the var field to be filled as an implementation sees fit. Occupies bits 66 through 127 (octets 8-15).

